defmodule Dialup.App.EcDemo.Page do
  use Dialup.Page

  @layout false

  @products [
    %{
      id: 1,
      name: "やさしい洗濯洗剤",
      category: "laundry",
      category_label: "洗濯・掃除",
      price: 680,
      position: "0% 0%"
    },
    %{
      id: 2,
      name: "やわらかティッシュ",
      category: "bath",
      category_label: "バス・衛生",
      price: 298,
      position: "50% 0%"
    },
    %{
      id: 3,
      name: "ボタニカルシャンプー",
      category: "bath",
      category_label: "バス・衛生",
      price: 1_280,
      position: "100% 0%"
    },
    %{
      id: 4,
      name: "ミント歯みがき",
      category: "bath",
      category_label: "バス・衛生",
      price: 420,
      position: "0% 100%"
    },
    %{
      id: 5,
      name: "朝のブレンドコーヒー",
      category: "food",
      category_label: "食品",
      price: 980,
      position: "50% 100%"
    },
    %{
      id: 6,
      name: "泡立ちキッチンスポンジ",
      category: "kitchen",
      category_label: "キッチン",
      price: 360,
      position: "100% 100%"
    }
  ]

  declare_action(
    name: :add_to_cart,
    desc: "Add one product to the shopping cart",
    params: %{product_id: {:integer, enum: [1, 2, 3, 4, 5, 6]}},
    risk: "low",
    effects: "Increases the selected product quantity in this demo cart by one.",
    reversible: true,
    idempotent: false,
    examples: [%{product_id: 1}],
    success: "The cart count and total increase."
  )

  declare_action(
    name: :hold_product,
    desc: "Hold one product before committing it to the cart",
    params: %{product_id: {:integer, enum: [1, 2, 3, 4, 5, 6]}},
    risk: "low",
    effects: "Adds one product to the temporary held selection.",
    reversible: true,
    idempotent: false,
    examples: [%{product_id: 1}],
    success: "The held quantity increases."
  )

  declare_action(
    name: :commit_pending,
    desc: "Move all held products into the cart",
    params: %{},
    risk: "low",
    effects: "Moves the temporary held selection into the demo cart.",
    reversible: true,
    idempotent: false,
    success: "Held quantities become zero and cart quantities increase.",
    agent_only: true
  )

  declare_region(
    name: :product_catalog,
    role: "list",
    desc: "Filtered products currently available in the market",
    data: :products,
    actions: [:add_to_cart, :hold_product]
  )

  declare_region(
    name: :shopping_cart,
    role: "status",
    desc: "Current cart quantities and total",
    data: :cart,
    actions: [:commit_pending]
  )

  def page_title(_assigns), do: "日々市 | 暮らしのマーケット"

  def mount(_params, assigns) do
    {:ok,
     Map.merge(assigns, %{
       category: "all",
       query: "",
       interaction_mode: "drag",
       view_mode: "hibi",
       products: @products,
       cart: %{},
       pending: %{},
       favorites: MapSet.new(),
       cart_open: false,
       toast: nil
     })}
  end

  def __available__(:add_to_cart, _assigns), do: true
  def __available__(:hold_product, assigns), do: assigns.interaction_mode == "hold"
  def __available__(:commit_pending, assigns), do: pending_count(assigns) > 0
  def __available__(_action, _assigns), do: true

  def agent_state(assigns) do
    %{
      category: assigns.category,
      query: assigns.query,
      interaction_mode: assigns.interaction_mode,
      view_mode: assigns.view_mode,
      visible_products: filtered_products(assigns),
      cart: cart_summary(assigns),
      held: pending_lines(assigns)
    }
  end

  def agent_message(_assigns) do
    %{
      concept:
        "日々市 is an ecommerce interaction experiment with drag-to-cart and click-to-hold modes.",
      goal:
        "Help the user find products and update the shared cart while preserving their current filters and selections.",
      recommended_flow: [
        "Read product_catalog and shopping_cart.",
        "Use humanFocus when the user points at a product or interface area.",
        "Focus product_catalog or shopping_cart before changing it.",
        "Use add_to_cart for a direct add, or hold_product then commit_pending in hold mode.",
        "Verify quantities and total after the action."
      ],
      safety: [
        "This is a UI demo and does not place real orders.",
        "Do not infer checkout or payment intent from adding an item to the cart."
      ]
    }
  end

  def agent_grant(_assigns) do
    %{
      capabilities: [:add_to_cart, :hold_product, :commit_pending],
      projections: [:state, :regions, :actions],
      expires_in: :timer.minutes(15),
      require_version: true
    }
  end

  def handle_event("search", value, assigns) do
    {:update, overwrite(assigns, %{query: value, toast: nil})}
  end

  def handle_event("set_category", category, assigns) do
    {:update, overwrite(assigns, %{category: category, toast: nil})}
  end

  def handle_event("set_mode", mode, assigns) when mode in ["drag", "hold"] do
    pending = if mode == "drag", do: %{}, else: assigns.pending
    message = if mode == "drag", do: "ドラッグモード", else: "クリック保持モード"

    {:update, overwrite(assigns, %{interaction_mode: mode, pending: pending, toast: message})}
  end

  def handle_event("set_view", view, assigns) when view in ["hibi", "minimal"] do
    {:update, overwrite(assigns, %{view_mode: view, toast: nil})}
  end

  def handle_event(:add_to_cart, params, assigns),
    do: add_product_to_cart(product_id(params), assigns)

  def handle_event("add_to_cart", params, assigns),
    do: add_product_to_cart(product_id(params), assigns)

  def handle_event(:hold_product, params, assigns),
    do: hold_product(product_id(params), assigns)

  def handle_event("hold_product", params, assigns),
    do: hold_product(product_id(params), assigns)

  def handle_event("release_product", params, assigns) do
    id = product_id(params)

    case product(id) do
      nil ->
        invalid_product(assigns)

      product ->
        quantity = Map.get(assigns.pending, id, 0)

        pending =
          cond do
            quantity <= 1 -> Map.delete(assigns.pending, id)
            true -> Map.put(assigns.pending, id, quantity - 1)
          end

        {:update, overwrite(assigns, %{pending: pending, toast: "#{product.name}を1個戻しました"})}
    end
  end

  def handle_event(:commit_pending, _params, assigns), do: commit_pending(assigns)
  def handle_event("commit_pending", _params, assigns), do: commit_pending(assigns)

  def handle_event("open_cart", _params, assigns) do
    if assigns.interaction_mode == "hold" and pending_count(assigns) > 0 do
      commit_pending(assigns)
    else
      {:update, overwrite(assigns, %{cart_open: true, toast: nil})}
    end
  end

  def handle_event("close_cart", _params, assigns) do
    {:update, overwrite(assigns, %{cart_open: false})}
  end

  def handle_event("toggle_favorite", params, assigns) do
    id = product_id(params)

    if product(id) do
      favorites =
        if MapSet.member?(assigns.favorites, id),
          do: MapSet.delete(assigns.favorites, id),
          else: MapSet.put(assigns.favorites, id)

      {:update, overwrite(assigns, %{favorites: favorites, toast: nil})}
    else
      invalid_product(assigns)
    end
  end

  defp add_product_to_cart(id, assigns) do
    case product(id) do
      nil ->
        invalid_product(assigns)

      product ->
        cart = Map.update(assigns.cart, id, 1, &(&1 + 1))
        {:update, overwrite(assigns, %{cart: cart, toast: "#{product.name}をカートに入れました"})}
    end
  end

  defp hold_product(id, assigns) do
    case product(id) do
      nil ->
        invalid_product(assigns)

      product ->
        pending = Map.update(assigns.pending, id, 1, &(&1 + 1))
        {:update, overwrite(assigns, %{pending: pending, toast: "#{product.name}を保持中"})}
    end
  end

  defp commit_pending(assigns) do
    added = pending_count(assigns)

    cart =
      Enum.reduce(assigns.pending, assigns.cart, fn {id, quantity}, cart ->
        Map.update(cart, id, quantity, &(&1 + quantity))
      end)

    {:update,
     overwrite(assigns, %{
       cart: cart,
       pending: %{},
       toast: if(added > 0, do: "#{added}点をカートに入れました", else: nil),
       cart_open: added == 0
     })}
  end

  def render(assigns) do
    visible_products = filtered_products(assigns)
    cart = cart_summary(assigns)
    pending_total = pending_count(assigns)

    assigns =
      Map.merge(assigns, %{
        visible_products: visible_products,
        cart_summary: cart,
        pending_total: pending_total,
        pending_lines: pending_lines(assigns),
        cart_lines: cart_lines(assigns)
      })

    ~H"""
    <div
      class={"ec-page view-#{@view_mode}#{if @interaction_mode == "hold", do: " mode-hold", else: " mode-drag"}"}
      data-view={@view_mode}
      data-mode={@interaction_mode}
      id="ec-catalog"
    >
      <div class="view-switch" role="group" aria-label="デザイン表示">
        <button class={"view-button#{if @view_mode == "hibi", do: " is-active"}"} type="button" ws-event="set_view" ws-value="hibi">日々市 ver.</button>
        <button class={"view-button#{if @view_mode == "minimal", do: " is-active"}"} type="button" ws-event="set_view" ws-value="minimal">Minimal Core</button>
      </div>

      <header class="site-header">
        <a class="brand" href="/ec_demo" aria-label="日々市 ホーム">
          <span class="brand-mark">日</span><span>日々市</span>
        </a>
        <label class="search">
          <span aria-hidden="true">⌕</span>
          <input type="search" data-product-search ws-change="search" ws-debounce="180" value={@query} placeholder="商品を検索" />
          <kbd>⌘ K</kbd>
        </label>
        <div class="header-actions">
          <button class="icon-button" type="button" aria-label="お気に入り">♡</button>
          <button class="account-button" type="button" aria-label="アカウント">MY</button>
        </div>
      </header>

      <main>
        <section class="intro">
          <div><p class="eyebrow">DAILY MARKET</p><h1>いつもの暮らしを、<br />軽やかに。</h1></div>
          <p class="intro-copy">
            <%= if @interaction_mode == "drag" do %>
              必要なものを見つけたら、商品をつかんで右下のカートへ。
            <% else %>
              商品をクリックして手元に保持。選び終えたら右下のカートへ。
            <% end %>
          </p>
        </section>

        <nav class="category-tabs" aria-label="商品カテゴリー">
          <button :for={{value, label} <- categories()} class={"category-tab#{if @category == value, do: " is-active"}"} type="button" ws-event="set_category" ws-value={value}>{label}</button>
        </nav>

        <div class="catalog-meta">
          <p><span>{length(@visible_products)}</span> items</p>
          <div class="catalog-tools">
            <div class="mode-switch" role="group" aria-label="カート操作方式">
              <button class={"mode-button#{if @interaction_mode == "drag", do: " is-active"}"} type="button" ws-event="set_mode" ws-value="drag"><span>↗</span> ドラッグ</button>
              <button class={"mode-button#{if @interaction_mode == "hold", do: " is-active"}"} type="button" ws-event="set_mode" ws-value="hold"><span>☝</span> クリック保持</button>
            </div>
            <button class="sort-button" type="button">おすすめ順 <span>⌄</span></button>
          </div>
        </div>

        <.dialup_region
          name={:product_catalog}
          role="list"
          desc="Filtered products currently available in the market"
          data={:products}
          actions={[:add_to_cart, :hold_product]}
          class="product-grid"
        >
          <article :for={product <- @visible_products} class={"product-card#{if Map.get(@pending, product.id, 0) > 0, do: " is-held"}"} data-product-id={product.id}>
            <div class="product-media" data-draggable-product role="button" tabindex="0" aria-label={"#{product.name}を操作"}>
              <div class="product-shot" style={"background-position:#{product.position}"}></div>
              <span :if={Map.get(@pending, product.id, 0) > 0} class="held-badge">{Map.get(@pending, product.id)}</span>
              <button :if={Map.get(@pending, product.id, 0) > 0} class="held-remove" type="button" ws-event="release_product" data-dialup-params={Jason.encode!(%{product_id: product.id})}>↶ 1個戻す</button>
            </div>
            <button class={"product-favorite#{if MapSet.member?(@favorites, product.id), do: " is-favorite"}"} type="button" ws-event="toggle_favorite" data-dialup-params={Jason.encode!(%{product_id: product.id})} aria-label={"#{product.name}をお気に入りに追加"}>
              {if MapSet.member?(@favorites, product.id), do: "♥", else: "♡"}
            </button>
            <div class="product-info">
              <p class="product-category">{product.category_label}</p>
              <h2 class="product-name">{product.name}</h2>
              <div class="product-row">
                <p class="product-price">{yen(product.price)}<small>税込</small></p>
                <%= if @interaction_mode == "hold" do %>
                  <.dialup_action name={:hold_product} class="quick-add" product_id={product.id}>＋</.dialup_action>
                <% else %>
                  <.dialup_action name={:add_to_cart} class="quick-add" product_id={product.id}>＋</.dialup_action>
                <% end %>
              </div>
            </div>
          </article>
        </.dialup_region>

        <p :if={@visible_products == []} class="empty-state">該当する商品がありません。</p>
      </main>

      <div class="drag-hint"><span>商品をここへ</span><span>↘</span></div>

      <.dialup_region
        name={:shopping_cart}
        role="status"
        desc="Current cart quantities and total"
        data={:cart}
        actions={[:commit_pending]}
        class={"cart-dock#{if @pending_total > 0, do: " has-pending"}"}
        id="ec-cart-dock"
      >
        <button class="cart-hit" data-cart-dock type="button" ws-event="open_cart">
          <span class="cart-drop"><span class="cart-emoji">🛒</span><span class="cart-count">{@cart_summary.count}</span></span>
          <span class="cart-summary"><span>{if @pending_total > 0, do: "#{@pending_total}点を入れる", else: "カート"}</span><strong>{yen(@cart_summary.total)}</strong></span>
          <span class="cart-open">›</span>
        </button>
      </.dialup_region>

      <div :if={@toast} class="toast is-visible" role="status">{@toast}</div>

      <div :if={@cart_open} class="cart-dialog-backdrop">
        <button class="cart-dialog-dismiss" type="button" ws-event="close_cart" aria-label="カートを閉じる"></button>
        <section class="cart-dialog" role="dialog" aria-modal="true" aria-label="カートの中身">
          <div class="dialog-header">
            <div><p class="eyebrow">YOUR CART</p><h2>カートの中身</h2></div>
            <button class="dialog-close" type="button" ws-event="close_cart">×</button>
          </div>
          <div class="cart-lines">
            <p :if={@cart_lines == []} class="cart-empty">カートはまだ空です。</p>
            <div :for={line <- @cart_lines} class="cart-line">
              <div class="cart-thumb" style={"background-position:#{line.product.position}"}></div>
              <div><p>{line.product.name}</p><small>{yen(line.product.price)} × {line.quantity}</small></div>
              <strong>{yen(line.product.price * line.quantity)}</strong>
            </div>
          </div>
          <div class="dialog-footer">
            <div><span>合計</span><strong>{yen(@cart_summary.total)}</strong></div>
            <button type="button">購入手続きへ</button>
          </div>
        </section>
      </div>
    </div>
    """
  end

  defp categories do
    [
      {"all", "すべて"},
      {"laundry", "洗濯・掃除"},
      {"bath", "バス・衛生"},
      {"kitchen", "キッチン"},
      {"food", "食品"}
    ]
  end

  defp filtered_products(assigns) do
    query = assigns.query |> String.trim() |> String.downcase()

    Enum.filter(@products, fn product ->
      category_match = assigns.category == "all" or product.category == assigns.category
      text = String.downcase("#{product.name} #{product.category_label}")
      category_match and (query == "" or String.contains?(text, query))
    end)
  end

  defp cart_summary(assigns) do
    Enum.reduce(assigns.cart, %{count: 0, total: 0}, fn {id, quantity}, summary ->
      product = product!(id)
      %{count: summary.count + quantity, total: summary.total + product.price * quantity}
    end)
  end

  defp pending_count(assigns), do: assigns.pending |> Map.values() |> Enum.sum()

  defp pending_lines(assigns) do
    Enum.map(assigns.pending, fn {id, quantity} ->
      %{product: product!(id), quantity: quantity}
    end)
  end

  defp cart_lines(assigns) do
    Enum.map(assigns.cart, fn {id, quantity} -> %{product: product!(id), quantity: quantity} end)
  end

  defp product_id(params) do
    value = params["product_id"] || params[:product_id] || params["id"] || params[:id]

    case value do
      value when is_integer(value) ->
        value

      value when is_binary(value) ->
        case Integer.parse(value) do
          {id, ""} -> id
          _ -> nil
        end

      _ ->
        nil
    end
  end

  defp invalid_product(assigns),
    do: {:update, overwrite(assigns, %{toast: "指定された商品は見つかりません"})}

  defp product(id), do: Enum.find(@products, &(&1.id == id))
  defp product!(id), do: Enum.find(@products, &(&1.id == id))
  defp yen(value), do: "¥" <> (value |> Integer.to_string() |> add_commas())

  defp add_commas(value),
    do: value |> String.reverse() |> String.replace(~r/(\d{3})(?=\d)/, "\\1,") |> String.reverse()
end
