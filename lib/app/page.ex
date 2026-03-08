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
      <div class="hero-badge">$ mix phx.new hello</div>
      <h1>
        <span class="hl">WebSocket</span>-first<br/>
        Elixir Web Framework
      </h1>
      <p class="hero-sub">
        Dialup はサーバー上の GenServer がブラウザの状態を持ち続ける、
        WebSocket ファーストな Elixir フレームワークです。 <br/>
        新しい形のSingle Page Application を実現します。
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
        <p>1 tab = 1 process で、全てのページにまたがってセッションが継続。<br/>状態はサーバー上に存在し、WebSocket で同期される。</p>
      </div>
      <div class="features container">
        <div class="feature-card">
          <span class="feature-icon">📁</span>
          <h3>ファイルベースルーティング</h3>
          <p><code>app/users/[id]/page.ex</code> を置くだけで <code>/users/:id</code> になる。<code>router.ex</code> への手書き登録は不要。</p>
        </div>
        <div class="feature-card">
          <span class="feature-icon">⚡</span>
          <h3>1 tab = 1 process</h3>
          <p>各セッションが独立した GenServer を持つ。状態はサーバー上に存在し、WebSocket で同期される。</p>
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
          <p>切断を検知したら指数バックオフで再接続。プロセスが生きていれば状態はそのまま復元される。</p>
        </div>
      </div>
    </section>

    <section class="section section-alt">
      <div class="container">
        <div class="section-title">
          <h2>フレームワーク比較</h2>
          <p>Dialup は Phoenix LiveView と Next.js に大きく影響を受けています</p>
        </div>
        <div class="compare-wrap">
          <table class="compare-table">
            <thead>
              <tr>
                <th>機能</th>
                <th class="highlight-col">Dialup</th>
                <th>Next.js</th>
                <th>Phoenix LiveView</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>言語</td>
                <td class="highlight-col">Elixir</td>
                <td>TypeScript / JS</td>
                <td>Elixir</td>
              </tr>
              <tr>
                <td>ルーティング</td>
                <td class="highlight-col">ファイルベース</td>
                <td>ファイルベース</td>
                <td><code>router.ex</code> に定義</td>
              </tr>
              <tr>
                <td>状態の管理</td>
                <td class="highlight-col">サーバー</td>
                <td>クライアント (React)</td>
                <td>サーバー</td>
              </tr>
              <tr>
                <td>リアルタイム通信</td>
                <td class="highlight-col">WebSocket 組み込み</td>
                <td>別途実装が必要</td>
                <td>WebSocket 組み込み</td>
              </tr>
              <tr>
                <td>DOM 更新</td>
                <td class="highlight-col">idiomorph</td>
                <td>Virtual DOM (React)</td>
                <td>サーバサイドで差分計算 + morphdom等</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </section>

    <section class="section section-alt">
      <div class="container">
        <div class="section-title">
          <h2>実際に動かしてみる</h2>
          <p>カウンター・フォーム・リアルタイム入力を体験できる Live Demo を用意しています。</p>
        </div>
        <div class="section-content">
          <a ws-href="/demo" class="btn btn-primary">
            Live Demo を開く &rarr;
          </a>
        </div>
      </div>
    </section>
    """
  end
end
