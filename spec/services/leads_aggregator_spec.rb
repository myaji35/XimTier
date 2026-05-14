require "rails_helper"

RSpec.describe LeadsAggregator do
  let!(:demo_user)    { create(:user, name: "Demo Person", email: "demo@x.com", company: "DemoCo", industry: :manufacturing, locale: "ko") }
  let!(:demo_request) { create(:demo_request, user: demo_user, locale: "ko", source: "demo_form") }

  let!(:contact_unhandled) do
    create(:contact_inquiry,
      name: "Contact A", email: "a@x.com", company: "Acme",
      industry: :hospital, locale: "en", handled: false)
  end
  let!(:contact_handled) do
    create(:contact_inquiry,
      name: "Contact B", email: "b@x.com", company: "Beta",
      industry: :manufacturing, locale: "ko", handled: true)
  end

  describe "#leads (no filters)" do
    it "returns demos and contacts merged, newest first" do
      result = described_class.new({}).leads
      kinds  = result.map(&:kind)
      expect(kinds).to include("demo", "contact")
      expect(result.size).to eq(3)
    end
  end

  describe "#counts" do
    it "tallies total / demo / contact" do
      counts = described_class.new({}).counts
      expect(counts[:total]).to eq(3)
      expect(counts[:demo]).to eq(1)
      expect(counts[:contact]).to eq(2)
    end
  end

  describe "filters" do
    it "kind=demo returns only demo leads" do
      r = described_class.new("kind" => "demo").leads
      expect(r.map(&:kind).uniq).to eq(["demo"])
    end

    it "kind=contact returns only contact leads" do
      r = described_class.new("kind" => "contact").leads
      expect(r.map(&:kind).uniq).to eq(["contact"])
    end

    it "locale=en filters to English-locale rows" do
      r = described_class.new("locale" => "en").leads
      expect(r.map(&:locale).uniq).to eq(["en"])
    end

    it "industry=hospital filters contacts (and excludes demos with manufacturing user)" do
      r = described_class.new("industry" => "hospital").leads
      expect(r.map(&:email)).to contain_exactly("a@x.com")
    end

    it "status=handled returns only handled contacts" do
      r = described_class.new("status" => "handled").leads
      expect(r.map(&:email)).to contain_exactly("b@x.com")
    end

    it "search 'demo' matches by name/company/message/email" do
      r = described_class.new("q" => "Demo").leads
      expect(r.map(&:kind)).to include("demo")
    end
  end

  describe "#to_csv" do
    it "produces a CSV with the standard header row" do
      csv = described_class.new({}).to_csv
      expect(csv.lines.first.strip).to eq(
        "kind,id,name,email,company,role,industry,status,source,locale,created_at,message"
      )
      expect(csv.lines.size).to eq(4) # header + 3 leads
    end

    it "respects filters when exporting" do
      csv = described_class.new("kind" => "contact").to_csv
      expect(csv.lines.size).to eq(3) # header + 2 contacts
      expect(csv).to include("a@x.com")
      expect(csv).not_to include("demo@x.com")
    end
  end
end
