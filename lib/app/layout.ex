defmodule Dialup.App.Layout do
  use Dialup.Layout

  def render(assigns) do
    ~H"""
    <header class="site-header">
      <div class="header-inner">
        <span class="site-logo" ws-href="/">
          Dial<span class="logo-accent">up</span>
        </span>
        <nav class="site-nav">
          <span ws-href="/docs">Docs</span>
          <span ws-href="/docs/concepts">Concepts</span>
          <span ws-href="/docs/api">API</span>
          <span ws-href="/demo" class="nav-cta">Live Demo</span>
        </nav>
      </div>
    </header>

    <span id="ws-status"></span>

    {raw(@inner_content)}

    <footer class="site-footer">
      <p>
        Dialup — MIT License &middot;
        Built with Dialup itself &middot;
        1 tab = 1 process
      </p>
    </footer>
    """
  end
end
