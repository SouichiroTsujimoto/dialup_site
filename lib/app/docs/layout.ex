defmodule Dialup.App.Docs.Layout do
  use Dialup.Layout

  def render(assigns) do
    ~H"""
    <div class="docs-layout">
      <aside class="docs-sidebar">
        <p class="sidebar-section-label">はじめに</p>
        <span ws-href="/docs" class="sidebar-link">Getting Started</span>

        <p class="sidebar-section-label">コンセプト</p>
        <span ws-href="/docs/concepts" class="sidebar-link">アーキテクチャ</span>

        <p class="sidebar-section-label">リファレンス</p>
        <span ws-href="/docs/api" class="sidebar-link">API リファレンス</span>

        <p class="sidebar-section-label">体験する</p>
        <span ws-href="/demo" class="sidebar-link">Live Demo</span>
      </aside>

      <main class="docs-content">
        {raw(@inner_content)}
      </main>
    </div>
    """
  end
end
