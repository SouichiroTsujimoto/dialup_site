defmodule Dialup.App.Layout do
  use Dialup.Layout

  def render(assigns) do
    ~H"""
    <nav class="site-nav">
      <div class="nav-inner">
        <span class="nav-logo" ws-href="/">Dialup</span>
        <div class="nav-links">
          <span ws-href="/docs" class={if @current_path == "/docs", do: "active"}>Docs</span>
          <span ws-href="/docs/concepts" class={if @current_path == "/docs/concepts", do: "active"}>Concepts</span>
          <span ws-href="/docs/api" class={if @current_path == "/docs/api", do: "active"}>API</span>
          <span ws-href="/demo" class={if @current_path == "/demo", do: "active"}>Demo</span>
        </div>
        <span id="ws-status" class="ws-lamp" title="WebSocket status"></span>
      </div>
    </nav>

    <main class="page-content">
      {raw(@inner_content)}
    </main>

    <footer class="site-footer">
      <p>Dialup — MIT License &middot; Built with Dialup &middot; WebSocket-first Framework</p>
    </footer>
    """
  end
end
