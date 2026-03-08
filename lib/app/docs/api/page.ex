defmodule Dialup.App.Docs.Api.Page do
  use Dialup.Page

  def page_title(_assigns), do: "API Reference — Dialup"

  defp code_layout_example, do: ~S|defmodule MyApp.App.Layout do
  use Dialup.Layout

  # session を設定する（接続時に一度だけ呼ばれる）
  def mount(session) do
    user = Repo.get(User, get_user_id_from_cookie())
    {:ok, Map.put(session, :current_user, user)}
  end

  def render(assigns) do
    ~H"""
    <nav>{@current_user.name}</nav>
    <main>{raw(@inner_content)}</main>
    """
  end
end|

  defp code_page_example, do: ~S|defmodule MyApp.App.Users.Id do
  use Dialup.Page

  def mount(%{"id" => id}, assigns) do
    {:ok, Map.put(assigns, :user, Users.get!(id))}
  end

  def handle_event("follow", _, assigns) do
    {:update, Map.update!(assigns, :user, &Users.follow/1)}
  end

  def render(assigns) do
    ~H"""
    <h1>{@user.name}</h1>
    <button ws-event="follow">フォロー</button>
    """
  end
end|

  defp code_patch_example, do: ~S|defp render_count(assigns) do
  ~H"""
  <p id="count">count: {@count}</p>
  """
end

def handle_event("increment", _, assigns) do
  new_assigns = Map.update!(assigns, :count, &(&1 + 1))
  {:patch, "count", render_count(new_assigns), new_assigns}
end|

  defp code_static_example, do: ~S|defmodule MyApp.App.About do
  use Dialup.Page

  @static true

  def render(assigns) do
    ~H"""
    <h1>About</h1>
    <span ws-href="/users">ユーザー一覧</span>
    """
  end
end|

  defp code_protocol, do: ~S|# クライアント → サーバー
{ event: "__init",      value: "/current/path" }   # 初回接続
{ event: "__reconnect", value: "/current/path" }   # 再接続
{ event: "__navigate",  value: "/users/123" }      # ナビゲーション
{ event: "follow",      value: "" }                # ユーザーイベント

# サーバー → クライアント
{ html: "<h1>...</h1>", path: "/users/123" }        # :update
{ target: "count", html: "<p id='count'>5</p>" }    # :patch|

  def render(assigns) do
    ~H"""
    <h1>API リファレンス</h1>
    <p class="page-lead">
      Dialup が提供するすべての公開 API を説明します。
    </p>

    <h2>use Dialup.Layout</h2>
    <p>
      レイアウトモジュールに <code>use Dialup.Layout</code> を追加することで、
      <code>mount/1</code> と <code>render/1</code> コールバックが使えるようになります。
    </p>

    <pre><code>{code_layout_example()}</code></pre>

    <div class="note">
      <strong>注意：</strong> <code>mount/1</code> は省略可能です。
      省略した場合、受け取った session をそのまま返すデフォルト実装が使われます。
    </div>

    <h2>use Dialup.Page</h2>
    <p>
      ページモジュールに <code>use Dialup.Page</code> を追加します。
    </p>

    <pre><code>{code_page_example()}</code></pre>

    <h3>mount/1 と mount/2 の使い分け</h3>

    <table class="return-table">
      <thead>
        <tr><th>定義する関数</th><th>用途</th></tr>
      </thead>
      <tbody>
        <tr>
          <td><code>mount/2</code> のみ</td>
          <td>動的ページ（URL パラメータを使用）</td>
        </tr>
        <tr>
          <td><code>mount/1</code> のみ</td>
          <td>静的ページ（mount/2 は自動生成される）</td>
        </tr>
        <tr>
          <td>どちらも定義しない</td>
          <td>シンプルなページ（デフォルト mount/2 が生成される）</td>
        </tr>
      </tbody>
    </table>

    <h2>handle_event / handle_info の返り値</h2>

    <table class="return-table">
      <thead>
        <tr><th>返り値</th><th>説明</th></tr>
      </thead>
      <tbody>
        <tr>
          <td><code>&#123;:noreply, assigns&#125;</code></td>
          <td>再描画なし。状態のみ更新（ws-change 等の頻繁なイベントに）</td>
        </tr>
        <tr>
          <td><code>&#123;:update, assigns&#125;</code></td>
          <td>全体再描画（<code>#dialup-root</code> を idiomorph で差し替え）</td>
        </tr>
        <tr>
          <td><code>&#123;:patch, id, rendered, assigns&#125;</code></td>
          <td>部分再描画（指定した id の要素のみ更新）</td>
        </tr>
        <tr>
          <td><code>&#123;:redirect, path, assigns&#125;</code></td>
          <td>別ページへ遷移（<code>__navigate</code> と同様の挙動）</td>
        </tr>
      </tbody>
    </table>

    <h3>:patch の使用例</h3>
    <pre><code>{code_patch_example()}</code></pre>

    <h2>HTML 属性</h2>
    <p>
      Dialup が監視する HTML 属性一覧です。
    </p>

    <table class="attr-table">
      <thead>
        <tr><th>属性</th><th>対象要素</th><th>説明</th></tr>
      </thead>
      <tbody>
        <tr>
          <td><code>ws-href="/path"</code></td>
          <td>任意</td>
          <td>クリック時に SPA ナビゲーション（history.pushState）</td>
        </tr>
        <tr>
          <td><code>ws-event="event_name"</code></td>
          <td>任意</td>
          <td>クリック時に <code>handle_event/3</code> を呼ぶ</td>
        </tr>
        <tr>
          <td><code>ws-value="value"</code></td>
          <td>ws-event と組み合わせ</td>
          <td>handle_event の第二引数として渡す値（省略時は空文字）</td>
        </tr>
        <tr>
          <td><code>ws-submit="event_name"</code></td>
          <td>form</td>
          <td>送信時にフォームデータをオブジェクトとして handle_event に渡す</td>
        </tr>
        <tr>
          <td><code>ws-change="event_name"</code></td>
          <td>input / textarea / select</td>
          <td>入力のたびに現在の値を handle_event に渡す</td>
        </tr>
      </tbody>
    </table>

    <h2>静的ページ（@static true）</h2>
    <p>
      WebSocket 接続を必要としないページには <code>@static true</code> を指定します。
    </p>

    <pre><code>{code_static_example()}</code></pre>

    <h2>メッセージプロトコル</h2>
    <p>WebSocket で送受信される JSON メッセージの仕様です。</p>

    <pre><code>{code_protocol()}</code></pre>

    <h2>use Dialup オプション</h2>

    <table class="return-table">
      <thead>
        <tr><th>オプション</th><th>型</th><th>説明</th></tr>
      </thead>
      <tbody>
        <tr>
          <td><code>app_dir</code></td>
          <td>String（必須）</td>
          <td>page.ex / layout.ex を配置するルートディレクトリの絶対パス</td>
        </tr>
        <tr>
          <td><code>title</code></td>
          <td>String</td>
          <td>HTML title タグのデフォルト値（デフォルト: "Dialup App"）</td>
        </tr>
        <tr>
          <td><code>lang</code></td>
          <td>String</td>
          <td>html lang 属性の値（デフォルト: "en"）</td>
        </tr>
        <tr>
          <td><code>head_extra</code></td>
          <td>String</td>
          <td>head に追加する HTML（CSS・meta タグ等）</td>
        </tr>
      </tbody>
    </table>
    """
  end
end
