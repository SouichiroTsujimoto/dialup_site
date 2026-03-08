defmodule Dialup.App.Docs.Page do
  use Dialup.Page

  def page_title(_assigns), do: "Getting Started — Dialup"

  defp code_install, do: ~S|mix new my_app
cd my_app|

  defp code_deps, do: ~S|defp deps do
  [
    {:dialup, "~> 0.1"}
  ]
end|

  defp code_app_module, do: ~S|defmodule MyApp do
  use Application

  use Dialup,
    app_dir: __DIR__ <> "/app",
    title: "My App",
    lang: "ja"

  @impl Application
  def start(_type, _args) do
    children = [
      {Dialup, app: __MODULE__, port: 4000}
    ]
    Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
  end
end|

  defp code_first_page, do: ~S|defmodule Dialup.App.Page do
  use Dialup.Page

  def mount(_params, assigns) do
    {:ok, Map.put(assigns, :count, 0)}
  end

  def handle_event("increment", _, assigns) do
    {:update, Map.update!(assigns, :count, &(&1 + 1))}
  end

  def render(assigns) do
    ~H"""
    <h1>Hello, Dialup!</h1>
    <p>Count: {@count}</p>
    <button ws-event="increment">+1</button>
    """
  end
end|

  defp code_file_tree, do: ~S|lib/app/
├── page.ex            # /
├── about/
│   └── page.ex        # /about
└── users/
    ├── page.ex        # /users
    └── [id]/
        └── page.ex    # /users/:id|

  def render(assigns) do
    ~H"""
    <h1>Getting Started</h1>
    <p class="page-lead">
      Dialup を使って最初のリアルタイムページを動かすまでのガイドです。
    </p>

    <h2>インストール</h2>
    <p>新しい Mix プロジェクトを作成し、<code>mix.exs</code> に Dialup を追加します。</p>
    <pre><code>{code_install()}</code></pre>

    <p><code>mix.exs</code> の <code>deps</code> に追加：</p>
    <pre><code>{code_deps()}</code></pre>

    <pre><code>mix deps.get</code></pre>

    <h2>アプリケーションモジュールの設定</h2>
    <p><code>lib/my_app.ex</code> を以下のように書き換えます：</p>
    <pre><code>{code_app_module()}</code></pre>

    <div class="note">
      <strong>app_dir</strong> には <code>page.ex</code> / <code>layout.ex</code> を置くディレクトリを指定します。
      このディレクトリのファイル配置が自動的にルートになります。
    </div>

    <h2>最初のページを作る</h2>
    <p>
      ルートページ <code>/</code> を作成します。
      <code>lib/app/</code> ディレクトリを作り、<code>page.ex</code> を置くだけです。
    </p>

    <ol class="steps">
      <li>
        <strong>ディレクトリを作成する</strong>
        <pre><code>mkdir -p lib/app</code></pre>
      </li>
      <li>
        <strong><code>lib/app/page.ex</code> を作成する</strong>
        <pre><code>{code_first_page()}</code></pre>
      </li>
      <li>
        <strong>サーバーを起動する</strong>
        <pre><code>mix run --no-halt</code></pre>
        <p>ブラウザでポート 4000 を開くとリアルタイムカウンターが動作しています。</p>
      </li>
    </ol>

    <h2>ページの追加</h2>
    <p>
      新しいページは <code>lib/app/</code> 以下にファイルを置くだけで追加できます。
      ファイルパスがそのままURLになります。
    </p>

    <pre><code>{code_file_tree()}</code></pre>

    <p>
      動的ルートは <code>[パラメータ名]</code> という形式のディレクトリ名で表現します。
      <code>/users/[id]/page.ex</code> は <code>/users/:id</code> にマッチし、
      <code>mount/2</code> の第一引数に <code>%&#123;"id" => "..."&#125;</code> として渡されます。
    </p>

    <h2>次のステップ</h2>
    <ul>
      <li><span ws-href="/docs/concepts">アーキテクチャと state のライフサイクル</span>を理解する</li>
      <li><span ws-href="/docs/api">API リファレンス</span>で使えるすべての機能を確認する</li>
      <li><span ws-href="/demo">Live Demo</span> で実際の動作を確認する</li>
    </ul>
    """
  end
end
