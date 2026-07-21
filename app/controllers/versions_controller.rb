# 실제로 돌아가는 코드의 SHA 를 알려준다.
#
# /up 은 구버전 컨테이너도 200 을 주기 때문에 배포 성공 판정에 쓸 수 없다.
# 실제로 커밋 4개가 미배포인 상태를 아무 게이트도 못 잡고 대표님이 화면을 보고
# 발견한 적이 있다(ISS-029). 그래서 "푸시한 SHA == 도는 SHA" 를 밖에서 대조한다.
#
# 노출하는 값은 git SHA 하나뿐이다 — 인증 없이 열려 있으므로 여기에 다른 정보를
# 추가하지 마라.
class VersionsController < ApplicationController
  def show
    # 프록시나 CDN 이 옛 값을 돌려주면 대조가 무의미해진다.
    response.headers["Cache-Control"] = "no-store"
    render json: { version: revision }
  end

  private

  # kamal 이 컨테이너에 주입한다. 로컬 개발에는 없으므로 "unknown" 으로 떨어진다.
  # git 을 셸로 호출하지 않는다 — 요청마다 프로세스를 띄우는 비용도, 인증 없이
  # 열린 엔드포인트에서 외부 명령을 실행하는 위험도 감수할 이유가 없다.
  def revision
    ENV["KAMAL_VERSION"].presence || "unknown"
  end
end
