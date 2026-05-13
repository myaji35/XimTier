class Admin::WikisController < ApplicationController
  layout "wiki"

  http_basic_authenticate_with(
    name: "admin",
    password: ENV.fetch("ADMIN_WIKI_PASSWORD", "gmldnjs!00")
  )

  def show
    @snapshot = CodeWikiInspector.snapshot
  end
end
