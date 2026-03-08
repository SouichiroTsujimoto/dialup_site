defmodule Dialup.App.Layout do
  use Dialup.Layout

  def render(assigns) do
    ~H"""
    <nav class="site-nav">
      <div class="nav-inner">
        <span class="nav-logo" ws-href="/">Dialup</span>
        <div class="nav-links">
          <span ws-href="/docs">Docs</span>
          <span ws-href="/docs/concepts">Concepts</span>
          <span ws-href="/docs/api">API</span>
          <span ws-href="/demo">Demo</span>
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
