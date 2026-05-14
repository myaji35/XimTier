require "rails_helper"

RSpec.describe AdminKpiSnapshot do
  let!(:demo_user) { create(:user, industry: :manufacturing, locale: "ko") }

  before do
    create(:demo_request, user: demo_user, locale: "ko", status: :pending)
    create(:demo_request, user: demo_user, locale: "en", status: :scheduled)
    create(:contact_inquiry, industry: :hospital, locale: "en", handled: false)
    create(:contact_inquiry, industry: :manufacturing, locale: "ko", handled: true)
    create(:download, asset: :ir_deck_ko, locale: "ko", downloaded_count: 2)
    create(:download, asset: :ir_deck_en, locale: "en", downloaded_count: 3)
  end

  it "returns counts for demo, contact and IR" do
    k = described_class.build
    expect(k[:counts][:demo][:total]).to eq(2)
    expect(k[:counts][:contact][:total]).to eq(2)
    expect(k[:counts][:ir_download][:total]).to eq(2)
    expect(k[:counts][:ir_download][:clicks_total]).to eq(5)
  end

  it "groups industry distribution with human labels" do
    k = described_class.build
    expect(k[:industry][:demo].keys).to include("manufacturing")
    expect(k[:industry][:contact].keys).to include("hospital", "manufacturing")
  end

  it "splits locale (ko/en) per channel" do
    k = described_class.build
    expect(k[:locale][:demo]).to include("ko" => 1, "en" => 1)
    expect(k[:locale][:contact]).to include("ko" => 1, "en" => 1)
    expect(k[:locale][:ir]).to include("ko" => 1, "en" => 1)
  end

  it "exposes a 14-day trend with one bucket per day" do
    k = described_class.build
    expect(k[:trend_14d][:days].size).to eq(14)
    expect(k[:trend_14d][:demo].size).to eq(14)
    expect(k[:trend_14d][:contact].size).to eq(14)
    expect(k[:trend_14d][:ir].size).to eq(14)
  end

  it "computes conversion metrics" do
    k = described_class.build
    expect(k[:conversion][:demo_to_scheduled_pct]).to be > 0
    expect(k[:conversion][:ir_total]).to eq(2)
    expect(k[:conversion][:ir_target_y1]).to eq(100)
  end

  it "labels asset_split with human-readable keys" do
    k = described_class.build
    expect(k[:asset_split].keys).to include("ir_deck_ko", "ir_deck_en")
  end
end
