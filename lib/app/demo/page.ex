defmodule Dialup.App.Demo.Page do
  use Dialup.Page

  def page_title(_assigns), do: "Live Demo — Dialup"

  def mount(_params, assigns) do
    {:ok,
     assigns
     |> Map.merge(%{
       count: 0,
       name_input: "",
       submitted_name: nil,
       draft: "",
       draft_confirmed: nil,
       message_log: []
     })}
  end

  # --- Counter ---

  def handle_event("inc", _, assigns) do
    new_assigns = Map.update!(assigns, :count, &(&1 + 1))
    {:patch, "demo-counter-value", render_counter(new_assigns), new_assigns}
  end

  def handle_event("dec", _, assigns) do
    new_assigns = Map.update!(assigns, :count, &(&1 - 1))
    {:patch, "demo-counter-value", render_counter(new_assigns), new_assigns}
  end

  def handle_event("reset_counter", _, assigns) do
    new_assigns = Map.put(assigns, :count, 0)
    {:patch, "demo-counter-value", render_counter(new_assigns), new_assigns}
  end

  # --- Form submit ---

  def handle_event("submit_name", %{"name" => name}, assigns) do
    new_assigns = assigns |> Map.merge(%{submitted_name: name, name_input: name})
    {:update, new_assigns}
  end

  # --- ws-change: live draft ---

  def handle_event("draft_change", value, assigns) do
    new_assigns = Map.put(assigns, :draft, value)
    {:patch, "demo-draft-preview", render_draft_preview(new_assigns), new_assigns}
  end

  def handle_event("confirm_draft", _, assigns) do
    new_assigns = assigns |> Map.merge(%{draft_confirmed: assigns.draft, draft: ""})
    {:update, new_assigns}
  end

  # --- Log messages (handle_info demo) ---

  def handle_event("send_message", %{"message" => msg}, assigns) when msg != "" do
    entry = "[#{time_now()}] #{msg}"
    new_assigns = Map.update!(assigns, :message_log, &[entry | &1])
    {:update, Map.merge(new_assigns, %{message_log: Enum.take(new_assigns.message_log, 5)})}
  end

  def handle_event("send_message", _, assigns), do: {:noreply, assigns}

  def handle_event("clear_log", _, assigns) do
    {:update, Map.put(assigns, :message_log, [])}
  end

  # --- Private renders ---

  defp render_counter(assigns) do
    ~H"""
    <div id="demo-counter-value" class="demo-value">{@count}</div>
    """
  end

  defp render_draft_preview(assigns) do
    ~H"""
    <p id="demo-draft-preview" class="result-line">
      <%= if @draft == "" do %>
        <span style="color: var(--muted);">入力内容がここにリアルタイム表示されます</span>
      <% else %>
        サーバーの draft: <strong>{@draft}</strong>
      <% end %>
    </p>
    """
  end

  defp time_now do
    {h, m, s} = :erlang.time()
    :io_lib.format("~2..0B:~2..0B:~2..0B", [h, m, s]) |> IO.iodata_to_binary()
  end

  def render(assigns) do
    ~H"""
    <div class="demo-container">
      <div class="demo-header">
        <h1>Live Demo</h1>
        <p>すべてのインタラクションは WebSocket 経由でサーバーの GenServer に届きます。</p>
      </div>

      <%!-- === Counter === --%>
      <div class="demo-card">
        <div class="demo-card-header">
          <span class="demo-tag">:patch</span>
          <h3>カウンター — 部分更新</h3>
        </div>
        <p>
          <code>&#123;:patch, "demo-counter-value", rendered, assigns&#125;</code> を使用。
          カウンター部分の要素だけが更新され、ページ全体は再描画されません。
        </p>
        {render_counter(assigns)}
        <div>
          <button class="btn btn-primary" ws-event="dec">ー</button>
          <button class="btn btn-primary" ws-event="inc">＋</button>
          <button class="btn btn-ghost" ws-event="reset_counter">リセット</button>
        </div>
      </div>

      <%!-- === ws-submit === --%>
      <div class="demo-card">
        <div class="demo-card-header">
          <span class="demo-tag">ws-submit</span>
          <h3>form submit</h3>
        </div>
        <p>
          <code>ws-submit</code> を持つ form は、送信時にフォームデータをオブジェクトとしてサーバーに送ります。
          <code>handle_event("submit_name", %&#123;"name" => name&#125;, assigns)</code> で受け取れます。
        </p>
        <form ws-submit="submit_name">
          <div class="form-row">
            <input type="text" name="name" value={@name_input} placeholder="名前を入力..." />
            <button type="submit" class="btn btn-ghost">送信</button>
          </div>
        </form>
        <%= if @submitted_name do %>
          <p class="result-line">サーバーが受け取った名前: <strong>{@submitted_name}</strong></p>
        <% end %>
      </div>

      <%!-- === ws-change === --%>
      <div class="demo-card">
        <div class="demo-card-header">
          <span class="demo-tag">ws-change</span>
          <h3>リアルタイム入力同期</h3>
        </div>
        <p style="color: var(--muted); font-size: 0.875rem; margin: 0 0 1rem;">
          <code>ws-change</code> は入力のたびにサーバーへ値を送ります。
          <code>ws-debounce="300"</code> で 300ms のデバウンスを適用し、
          タイピング中の過剰な送信を防いでいます。
          ここでは <code>:patch</code> でプレビュー部分だけを更新しています。
        </p>
        <div class="form-row">
          <input type="text" ws-change="draft_change" ws-debounce="300" value={@draft} placeholder="入力中にサーバーへ同期..." />
          <button class="btn btn-ghost" ws-event="confirm_draft">確定</button>
        </div>
        {render_draft_preview(assigns)}
        <%= if @draft_confirmed do %>
          <p class="result-line">確定済み: <strong>{@draft_confirmed}</strong></p>
        <% end %>
      </div>

      <%!-- === Message log === --%>
      <div class="demo-card">
        <div class="demo-card-header">
          <span class="demo-tag">:update</span>
          <h3>メッセージログ — 全体更新</h3>
        </div>
        <p style="color: var(--muted); font-size: 0.875rem; margin: 0 0 1rem;">
          <code>&#123;:update, assigns&#125;</code> を使用。送信のたびに <code>#dialup-root</code> 全体を idiomorph で差し替えます。
          サーバー側でタイムスタンプを付与しています（最新5件を表示）。
        </p>
        <form ws-submit="send_message">
          <div class="form-row">
            <input type="text" name="message" placeholder="メッセージを入力..." />
            <button type="submit" class="btn btn-ghost">送信</button>
          </div>
        </form>
        <%= if @message_log == [] do %>
          <p class="result-line" style="color: var(--muted);">まだメッセージがありません。</p>
        <% else %>
          <ul style="margin: 1rem 0 0; padding: 0; list-style: none;">
            <%= for entry <- @message_log do %>
              <li style="font-size: 0.875rem; padding: 0.3rem 0; border-bottom: 1px solid var(--border); font-family: monospace; color: #374151;">
                {entry}
              </li>
            <% end %>
          </ul>
          <button class="btn btn-primary" ws-event="clear_log">クリア</button>
        <% end %>
      </div>

      <%!-- === Navigation === --%>
      <div class="demo-card">
        <div class="demo-card-header">
          <span class="demo-tag">ws-href</span>
          <h3>SPA ナビゲーション</h3>
        </div>
        <p style="color: var(--muted); font-size: 0.875rem; margin: 0 0 1rem;">
          <code>ws-href</code> をクリックすると <code>__navigate</code> イベントがサーバーに送られ、
          新しいページの HTML が返ってきます。
          <code>history.pushState</code> で URL も更新されます。ページ全体のリロードは発生しません。
        </p>
        <div style="display: flex; gap: 0.75rem; flex-wrap: wrap;">
          <a ws-href="/" class="btn btn-primary">← Home</a>
          <a ws-href="/docs" class="btn btn-primary">Docs</a>
          <a ws-href="/docs/concepts" class="btn btn-primary">Concepts</a>
          <a ws-href="/docs/api" class="btn btn-primary">API Ref</a>
        </div>
      </div>
    </div>
    """
  end
end
