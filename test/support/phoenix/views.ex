defmodule Pow.Test.Phoenix.LayoutView do
  @moduledoc false
  use Pow.Test.Phoenix.Web, :view
end

defmodule Pow.Test.Phoenix.Pow.SessionView do
  @moduledoc false
  use Pow.Test.Phoenix.Web, :web_module_view
end

defmodule Pow.Test.Phoenix.Pow.MailerView do
  @moduledoc false
  use Pow.Test.Phoenix.Web, :mailer_view

  def subject(:mail_test, _assigns), do: ":web_mailer_module subject"
end

defmodule Pow.Test.Phoenix.ErrorView do
  @moduledoc false
  def render("500.html", _assigns), do: "500.html"
  def render("400.html", _assigns), do: "400.html"
  def render("404.html", _assigns), do: "404.html"
end
