defmodule Dialup.App.Docs.Layout do
  use Dialup.Layout

  def render(assigns) do
    ~H"""
    <div class="docs-layout">
      <aside class="docs-sidebar">
        <p class="sidebar-section-label">Docs</p>
        <span ws-href="/docs" class={"sidebar-link#{if @current_path == "/docs", do: " active"}"}>Getting Started</span>

        <p class="sidebar-section-label">Concepts</p>
        <span ws-href="/docs/concepts" class={"sidebar-link#{if @current_path == "/docs/concepts", do: " active"}"}>アーキテクチャ</span>

        <p class="sidebar-section-label">API</p>
        <span ws-href="/docs/api" class={"sidebar-link#{if @current_path == "/docs/api", do: " active"}"}>API リファレンス</span>

        <p class="sidebar-section-label">Demo</p>
        <span ws-href="/demo" class={"sidebar-link#{if @current_path == "/demo", do: " active"}"}>Live Demo</span>
      </aside>

      <main class="docs-content">
        {raw(@inner_content)}
      </main>
    </div>
    """
  end
end
