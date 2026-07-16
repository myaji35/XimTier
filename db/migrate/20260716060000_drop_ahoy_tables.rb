class DropAhoyTables < ActiveRecord::Migration[8.1]
  # ahoy_matey 제거에 따른 테이블 정리. — ISS-011
  #
  # ahoy 는 방문자에게 2년짜리 추적 쿠키(ahoy_visitor)를 심고 IP·브라우저·OS·
  # referrer·접속 도시를 저장했으나, 이 데이터를 읽는 코드가 어디에도 없었다.
  # 관리 화면도, 통계 화면도 없었다 — 수집만 하고 아무도 보지 않았다.
  #
  # 그 대가로 처리방침의 "추적·광고 쿠키는 사용하지 않습니다",
  # "cookieless 분석" 이 사실과 달라진 상태였다 (제30조 제3항).
  #
  # 쌓인 방문 기록에는 IP 가 들어 있어 그 자체가 개인정보다. 테이블째 파기한다.
  def up
    drop_table :ahoy_events, if_exists: true
    drop_table :ahoy_visits, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          "ahoy 는 의도적으로 제거했다. 방문자 분석이 다시 필요하면 " \
          "쿠키를 쓰지 않는 Plausible(PLAUSIBLE_DOMAIN 설정)을 켜는 쪽을 검토할 것."
  end
end
