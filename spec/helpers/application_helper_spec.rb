require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#meta_pixel_ids" do
    subject(:pixel_ids) { helper.meta_pixel_ids }

    around do |example|
      original_value = ENV["META_PIXEL_ID"]
      example.run
    ensure
      ENV["META_PIXEL_ID"] = original_value
    end

    it "단일값을 반환한다" do
      ENV["META_PIXEL_ID"] = "1299950782092213"

      expect(pixel_ids).to eq(["1299950782092213"])
    end

    it "다중값의 공백과 중복, 빈 항목, 잘못된 값을 제거한다" do
      ENV["META_PIXEL_ID"] = " 1299950782092213, 996100773765329, ,1299950782092213,invalid "

      expect(pixel_ids).to eq(["1299950782092213", "996100773765329"])
    end

    it "빈 문자열이면 빈 배열을 반환한다" do
      ENV["META_PIXEL_ID"] = ""

      expect(pixel_ids).to be_empty
    end
  end
end
