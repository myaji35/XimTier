require "rails_helper"

RSpec.describe GoogleSheetExportJob, type: :job do
  it "일시적 타임아웃이면 잡을 재시도한다" do
    inquiry = instance_double(ContactInquiry)
    allow(ContactInquiry).to receive(:find).with(123).and_return(inquiry)
    allow(GoogleSheetExporter).to receive(:export_contact).and_raise(Net::ReadTimeout)

    expect do
      described_class.perform_now("contact", 123)
    end.to have_enqueued_job(described_class).with("contact", 123)
  end

  it "레코드가 없으면 재시도 없이 폐기한다" do
    allow(ContactInquiry).to receive(:find).with(123).and_raise(ActiveRecord::RecordNotFound)

    expect do
      expect { described_class.perform_now("contact", 123) }.not_to raise_error
    end.not_to have_enqueued_job(described_class)
  end
end
