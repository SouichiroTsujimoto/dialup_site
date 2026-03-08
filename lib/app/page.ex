defmodule Dialup.App.Page do
  use Dialup.Page

  def page_title(_assigns), do: "Dialup — WebSocket-first Elixir Framework"

  defp counter_example, do: ~S|
defmodule Dialup.App.Counter do
  use Dialup.Page

  def mount(_params, assigns) do
    {:ok, Map.put(assigns, :count, 0)}
  end

  def handle_event("inc", _, assigns) do
    {:update, Map.update!(assigns, :count, &(&1 + 1))}
  end

  def render(assigns) do
    ~H"""
    <p>Count: {@count}</p>
    <button ws-event="inc">+1</button>
    """
  end
end
|

  def render(assigns) do
    ~H"""
    <section class="hero">
      <div class="hero-badge">Dialup Framework</div>
      <h1>
        <span class="hl">WebSocket</span>-first<br/>
        Real-time UI
      </h1>
      <p class="hero-sub">
        Dialup はサーバー上の GenServer がブラウザの状態を持ち続ける、
        WebSocket ファーストな Elixir フレームワークです。
        ルーティングはファイル配置だけ。差分はクライアント側で。
      </p>
      <div class="hero-actions">
        <span ws-href="/docs" class="btn btn-primary">Get Started</span>
        <span ws-href="/demo" class="btn btn-ghost">Live Demo &rarr;</span>
      </div>

      <div class="hero-code">
        <div class="code-titlebar">
          <span class="code-dot dot-r"></span>
          <span class="code-dot dot-y"></span>
          <span class="code-dot dot-g"></span>
          <span class="code-filename">app/counter/page.ex</span>
        </div>
        <pre><code>{counter_example()}</code></pre>
      </div>
    </section>

    <section class="section section-alt">
      <div class="section-title">
        <h2>なぜ Dialup なのか</h2>
        <p>LiveView の思想を継承しながらシンプルな実装を目指す</p>
      </div>
      <div class="features container">
        <div class="feature-card">
          <span class="feature-icon">📁</span>
          <h3>ファイルベースルーティング</h3>
          <p><code>app/users/[id]/page.ex</code> を置くだけで <code>/users/:id</code> になる。<code>router.ex</code> への手書き登録は不要。</p>
        </div>
        <div class="feature-card">
          <span class="feature-icon">⚡</span>
          <h3>1 タブ = 1 プロセス</h3>
          <p>各ブラウザタブが独立した GenServer を持つ。状態はサーバー上に存在し、WebSocket で同期される。</p>
        </div>
        <div class="feature-card">
          <span class="feature-icon">🔄</span>
          <h3>session / assigns の分離</h3>
          <p><code>session</code> はナビゲーションをまたいで持続。<code>assigns</code> はページ遷移でリセット。ログイン状態が自然に保たれる。</p>
        </div>
        <div class="feature-card">
          <span class="feature-icon">🧩</span>
          <h3>クライアント側 DOM モーフィング</h3>
          <p>サーバーは HTML を送るだけ。差分適用は idiomorph が担う。プロトコルが単純でデバッグしやすい。</p>
        </div>
        <div class="feature-card">
          <span class="feature-icon">🪶</span>
          <h3>軽量な依存関係</h3>
          <p>Phoenix 本体は不使用。Bandit + HEEx + idiomorph のみ。クライアント JS は自作 ~100 行 + idiomorph 5KB。</p>
        </div>
        <div class="feature-card">
          <span class="feature-icon">🔁</span>
          <h3>自動再接続</h3>
          <p>切断を検知したら指数バックオフで自動再接続。プロセスが生きていれば状態はそのまま復元される。</p>
        </div>
      </div>
    </section>

    <section class="section">
      <div class="container">
        <div class="section-title">
          <h2>Hypermedia の次へ</h2>
          <p>UI アーキテクチャの三つの流派</p>
        </div>
        <div class="compare-wrap">
          <table class="compare-table">
            <thead>
              <tr>
                <th>思想</th>
                <th>転送単位</th>
                <th>状態の場所</th>
                <th>代表技術</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><span class="pill pill-gray">RESTful</span></td>
                <td>JSON リソース</td>
                <td>クライアント (React 等)</td>
                <td>Rails API + React</td>
              </tr>
              <tr>
                <td><span class="pill pill-gray">Hypermediaful</span></td>
                <td>HTML 断片</td>
                <td>サーバー (ステートレス)</td>
                <td>Rails + htmx / Turbo</td>
              </tr>
              <tr class="highlight-row">
                <td><span class="pill pill-purple">Dialup</span></td>
                <td>HTML 断片 (WS)</td>
                <td>サーバー上のプロセス</td>
                <td>Dialup / Phoenix LiveView</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </section>

    <section class="section section-alt">
      <div class="container" style="text-align: center;">
        <h2 style="font-size: 2rem; margin: 0 0 1rem;">実際に動かしてみる</h2>
        <p style="color: var(--muted); margin: 0 0 2rem;">カウンター・フォーム・リアルタイム入力を体験できる Live Demo を用意しています。</p>
        <span ws-href="/demo" class="btn btn-primary" style="font-size: 1rem; padding: 0.875rem 2rem;">
          Live Demo を開く &rarr;
        </span>
      </div>
    </section>
    """
  end
end
