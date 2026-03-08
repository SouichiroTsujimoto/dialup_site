defmodule Dialup.App.Docs.Concepts.Page do
  use Dialup.Page

  def page_title(_assigns), do: "Architecture — Dialup"

  def render(assigns) do
    ~H"""
    <h1>アーキテクチャ</h1>
    <p class="page-lead">
      Dialup の「1 タブ = 1 プロセス」モデルと、state の設計を解説します。
    </p>

    <h2>全体構造</h2>
    <p>
      Dialup は Elixir の GenServer（プロセス）を中心に据えた設計です。
      ブラウザのタブが一つ開くと、サーバー上に対応する UserSessionProcess が起動します。
      以後の操作はすべてこのプロセスを通じて行われます。
    </p>

    <pre class="arch-diagram">
    【ブラウザ】
      dialup.js
      ├── WebSocket 接続管理（Cookie 経由のセッション ID）
      ├── ws-click / ws-change / ws-submit / ws-href の監視
      ├── 切断検知と指数バックオフ自動再接続
      ├── ブラウザ履歴管理（history.pushState / popstate）
      └── サーバーから HTML を受け取り idiomorph で適用

               ↕ WebSocket（JSON 送受信）

    【Elixir サーバー】
      Dialup.SessionRegistry（Registry）
      Dialup.SessionSupervisor（DynamicSupervisor）
      └── UserSessionProcess（1 タブ = 1 プロセス）
           ├── session  : layout.mount が設定。ナビゲーション間で持続
           ├── assigns  : page.mount が設定。ナビゲーションごとにリセット
           ├── params   : URL パラメータ（framework が自動設定）
           └── layout + page を合成して HTML を生成
    </pre>

    <h2>ファイルベースルーティング</h2>
    <p>
      Dialup はファイルの配置を読み取り、コンパイル時にルートテーブルを生成します。
      <code>router.ex</code> への手書き登録は不要です。
    </p>

    <pre><code>app/
    ├── layout.ex               # 全ページ共通レイアウト
    ├── page.ex                 # /
    ├── blog/
    │   ├── layout.ex           # /blog/* 共通レイアウト（ネスト可）
    │   ├── page.ex             # /blog
    │   └── [slug]/
    │       └── page.ex         # /blog/:slug（動的ルーティング）</code></pre>

    <p>
      ネストしたレイアウトは自動的に適用されます。
      <code>/blog/my-post</code> にアクセスすると、
      ルートの <code>layout.ex</code> → <code>blog/layout.ex</code> → <code>blog/[slug]/page.ex</code>
      の順に組み合わされます。
    </p>

    <h2>session と assigns の分離</h2>
    <p>
      Dialup の最も重要なコンセプトは、state を二層に分けることです。
    </p>

    <table class="compare-table" style="margin: 1.5rem 0;">
      <thead>
        <tr>
          <th>フィールド</th>
          <th>設定者</th>
          <th>ライフサイクル</th>
          <th>用途例</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><code>session</code></td>
          <td><code>layout.mount/1</code></td>
          <td>プロセス全体で持続</td>
          <td>ログインユーザー、テーマ設定</td>
        </tr>
        <tr>
          <td><code>assigns</code></td>
          <td><code>page.mount/2</code></td>
          <td>ページ遷移でリセット</td>
          <td>記事一覧、カウンター</td>
        </tr>
        <tr>
          <td><code>params</code></td>
          <td>framework が自動設定</td>
          <td>ナビゲーションごとに更新</td>
          <td>URL パラメータ・クエリ文字列</td>
        </tr>
      </tbody>
    </table>

    <p>
      テンプレート内では <code>session + assigns + params</code> がマージされるため、
      すべて <code>@field_name</code> でアクセスできます。
      どの層の値かを意識する必要はありません。
    </p>

    <pre><code>&lt;p&gt;&#123;@current_user.name&#125;&lt;/p&gt;  &lt;!-- session 由来 --&gt;
    &lt;h1&gt;&#123;@post.title&#125;&lt;/h1&gt;        &lt;!-- assigns 由来 --&gt;
    &lt;p&gt;ID: &#123;@params["id"]&#125;&lt;/p&gt;    &lt;!-- params --&gt;</code></pre>

    <h2>接続・再接続のフロー</h2>

    <pre><code>初回接続:
      HTTP GET → Cookie にセッション ID 発行
      → WebSocket 接続
      → Registry にプロセス登録
      → layout.mount → page.mount → render → HTML 送信

    切断時:
      プロセスはデフォルト 5 分間生存

    再接続時:
      Cookie のセッション ID で Registry を検索
      プロセス生存中 → socket_pid を更新（take_over）→ 現在の state で再描画
      タイムアウト済み → 新規プロセス起動 → mount からやり直し</code></pre>

    <h2>差分適用：なぜクライアント側か</h2>
    <p>
      LiveView はサーバー側で差分を計算して最小限の指示を送ります。
      Dialup はシンプルさを優先し、サーバーは HTML 断片をそのまま送信します。
      クライアント側の <a href="https://github.com/bigskysoftware/idiomorph">idiomorph</a>（5KB）が
      DOM を効率的にモーフィングするため、フォームの入力値が保たれます。
    </p>

    <div class="note">
      <strong>トレードオフ：</strong>
      転送サイズは LiveView より大きくなりますが（数バイト vs 数百バイト）、
      実装が単純でデバッグしやすく、プロトコルが JSON + HTML というシンプルな形になります。
      一般的なネットワーク環境では体感差はほぼ出ません。
    </div>
    """
  end
end
