require "rails_helper"

RSpec.describe "Reverse What-If 인터랙티브 데모", type: :system do
  let(:demo_path) { how_it_works_path(locale: :ko, anchor: "reverse-what-if-demo") }

  before do
    visit demo_path
    expect(page).to have_css('[data-controller="reverse-what-if"]', wait: 5)
  end

  context "초기 렌더" do
    it "Stimulus 컨트롤러가 마운트되고 5개 변수 행 + SHAP 차트가 렌더된다" do
      within('[data-controller="reverse-what-if"]') do
        expect(page).to have_css('[data-reverse-what-if-target="varRow"]', count: 5)
        # SHAP 패널은 초기 display:none이므로 visible: :all
        expect(page).to have_css('.shap-chart[role="img"]', visible: :all)
        expect(page).to have_css('.shap-chart__fill', count: 5, visible: :all)
        expect(page).to have_css('.shap-chart__axis line', visible: :all)
      end
    end

    it "슬라이더의 a11y 속성이 초기값에 맞춰 설정된다 (컨트롤러 connect 직후 1.20 갱신)" do
      slider = find('[data-reverse-what-if-target="slider"]')
      # controller#changeTarget이 toFixed(2)로 즉시 정규화 → "1.20"
      expect(slider["aria-valuenow"]).to eq("1.20")
      expect(slider["aria-label"]).to include("목표 불량률")
      expect(slider["aria-valuetext"]).to include("1.20")
    end
  end

  context "슬라이더 조작 → 5변수 카드 갱신" do
    it "슬라이더 값을 0.60으로 바꾸면 targetValue/improvement/aria-valuetext가 즉시 갱신된다" do
      # Range input은 Capybara fill_in이 안정적이지 않아 JS dispatch로 처리 (실 사용자 키보드 입력과 동등)
      page.execute_script(<<~JS)
        const root  = document.querySelector('[data-controller="reverse-what-if"]');
        const slider = root.querySelector('input[type="range"]');
        slider.value = '0.6';
        slider.dispatchEvent(new Event('input', { bubbles: true }));
      JS

      within('[data-controller="reverse-what-if"]') do
        expect(find('[data-reverse-what-if-target="targetValue"]').text).to eq("0.60")
        expect(find('[data-reverse-what-if-target="improvement"]').text).to eq("−75%")
      end

      slider = find('[data-reverse-what-if-target="slider"]')
      expect(slider["aria-valuenow"]).to eq("0.60")
      expect(slider["aria-valuetext"]).to include("0.60")
    end
  end

  context "SHAP 탭 전환" do
    it "SHAP 탭을 클릭하면 panelShap이 표시되고 panelReverse는 숨겨진다" do
      find('[data-reverse-what-if-target="tabShap"]').click

      reverse_panel = find('[data-reverse-what-if-target="panelReverse"]', visible: :all)
      shap_panel    = find('[data-reverse-what-if-target="panelShap"]', visible: :all)

      expect(reverse_panel.style("display")["display"]).to eq("none")
      expect(shap_panel.style("display")["display"]).to eq("block")

      # SHAP 막대가 데이터로 채워졌는지(초기 "—" 텍스트 → 변수명/숫자) 확인
      shap_labels = all('[data-reverse-what-if-target="shapLabel"]')
      expect(shap_labels.size).to eq(5)
      shap_labels.each { |l| expect(l.text).not_to eq("—") }
    end
  end
end
