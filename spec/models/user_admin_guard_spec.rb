require "rails_helper"

# ISS-007 / ISS-008 — Avo 인가가 avo-pro 전용이라 OSS 판에서는 정책이 호출되지 않는다.
# 방어가 모델 계층에 있으므로 여기서 검증한다.
RSpec.describe User, "권한·삭제 가드" do
  it "생성 시에는 admin 지정이 가능하다 (seed/factory)" do
    expect(create(:user, :admin).admin).to be(true)
  end

  it "update 로는 admin 을 켤 수 없다" do
    u = create(:user, admin: false)
    expect(u.update(admin: true)).to be(false)
    expect(u.reload.admin).to be(false)
  end

  it "admin 을 끄는 것도 update 로는 안 된다" do
    u = create(:user, :admin)
    u.update(admin: false)
    expect(u.reload.admin).to be(true)
  end

  it "admin 변경 시도가 있어도 다른 필드는 함께 저장되지 않는다" do
    u = create(:user, admin: false, name: "원래")
    u.update(name: "바뀜", admin: true)
    expect(u.reload.admin).to be(false)
    expect(u.reload.name).to eq("원래")
  end

  it "일반 필드 수정은 정상 동작한다" do
    u = create(:user, name: "원래")
    expect(u.update(name: "바뀜")).to be(true)
    expect(u.reload.name).to eq("바뀜")
  end

  it "grant_admin! / revoke_admin! 로는 부여·회수가 된다" do
    u = create(:user, admin: false)
    u.grant_admin!
    expect(u.reload.admin).to be(true)
    u.revoke_admin!
    expect(u.reload.admin).to be(false)
  end

  it "물리 삭제는 차단된다 (demo_requests 연쇄 삭제 방지)" do
    u = create(:user)
    u.demo_requests.create!(data_description: "보존되어야 함", locale: "ko")
    expect(u.destroy).to be(false)
    expect(User.exists?(u.id)).to be(true)
    expect(u.demo_requests.count).to eq(1)
  end
end
