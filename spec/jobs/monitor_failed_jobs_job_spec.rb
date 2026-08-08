require "rails_helper"

RSpec.describe MonitorFailedJobsJob, type: :job do
  Job = Struct.new(:class_name)
  FailedExecution = Struct.new(:id, :job, :exception_class, :message)

  let(:cache) { ActiveSupport::Cache::MemoryStore.new }
  let(:mailer) { instance_double(ActionMailer::MessageDelivery, deliver_now: true) }
  let(:failed_executions) { [] }

  before do
    allow(Rails).to receive(:cache).and_return(cache)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("ADMIN_EMAIL").and_return("admin@example.com")
    allow(FailedJobsMailer).to receive(:alert).and_return(mailer)
    failed_execution_class = Class.new
    executions = failed_executions
    relation_builder = method(:relation_for)
    failed_execution_class.define_singleton_method(:includes) do |_association|
      relation_builder.call(executions)
    end
    stub_const("SolidQueue::FailedExecution", failed_execution_class)
  end

  def create_failed_execution(class_name: "BusinessJob")
    failed_executions << FailedExecution.new(
      failed_executions.length + 1,
      Job.new(class_name),
      "StandardError",
      "failed"
    )
  end

  def relation_for(executions)
    relation = double
    allow(relation).to receive(:order).and_return(relation)
    allow(relation).to receive(:count).and_return(executions.count)
    allow(relation).to receive(:where) do |_condition, last_notified_id|
      relation_for(executions.select { |execution| execution.id > last_notified_id })
    end
    allow(relation).to receive(:partition) { |&block| executions.reverse.partition(&block) }
    allow(relation).to receive(:limit) { |limit| executions.reverse.first(limit) }
    allow(relation).to receive(:maximum).with(:id).and_return(executions.map(&:id).max)
    relation
  end

  it "같은 실패만 남아 있으면 두 번째 실행에서 메일을 보내지 않는다" do
    2.times { create_failed_execution }

    described_class.new.perform
    described_class.new.perform

    expect(FailedJobsMailer).to have_received(:alert).once
  end

  it "새 실패가 추가되면 그 건만 보고한다" do
    create_failed_execution
    described_class.new.perform
    create_failed_execution(class_name: "AnotherBusinessJob")

    described_class.new.perform

    expect(FailedJobsMailer).to have_received(:alert).with(
      new_count: 1,
      total_count: 2,
      summary: include("AnotherBusinessJob")
    )
  end

  it "실패가 없으면 메일을 보내지 않는다" do
    described_class.new.perform

    expect(FailedJobsMailer).not_to have_received(:alert)
  end

  it "감시 잡 자체 실패만 있으면 메일을 보내지 않는다" do
    create_failed_execution(class_name: described_class.name)

    described_class.new.perform
    described_class.new.perform

    expect(FailedJobsMailer).not_to have_received(:alert)
    expect(cache.read(described_class::LAST_NOTIFIED_ID_CACHE_KEY)).to eq(1)
  end

  it "최근 실패 다수가 감시 잡 실패여도 업무 잡 실패를 본문에 포함한다" do
    create_failed_execution(class_name: "BusinessJob")
    10.times { create_failed_execution(class_name: described_class.name) }

    described_class.new.perform

    expect(FailedJobsMailer).to have_received(:alert).with(
      new_count: 11,
      total_count: 11,
      summary: include("BusinessJob", "감시 잡 자체 실패: 10건")
    )
  end

  it "메일 발송의 SMTP 예외를 전파한다" do
    create_failed_execution
    allow(mailer).to receive(:deliver_now).and_raise(Net::SMTPServerBusy.new("try later"))

    expect { described_class.new.perform }.to raise_error(Net::SMTPServerBusy)
  end
end
