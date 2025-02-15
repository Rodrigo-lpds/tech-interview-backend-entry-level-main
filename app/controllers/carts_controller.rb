  # frozen_string_literal: true

  class CartsController < ApplicationController
    before_action :load_cart, only: %i[ show create destroy add_item]

    def show
      render json: format_cart_json(cart: @cart), status: :ok
    end


    # o que fazer caso o item já tenha sido adicionado ao carrinho? avisar que item já foi adicionado
    def create
      product_id = cart_params[:product_id].to_i
      quantity = cart_params[:quantity].to_i
    
      return render json: { error: "Item já foi adicionado ao carrinho" }, status: :unprocessable_entity if item_already_added?(cart: @cart, product_id:)
      
      cart_item = @cart.cart_items.new(product_id:, quantity:)
    
      if cart_item.save
        render json: format_cart_json(cart: @cart), status: :created
      else
        render json: cart_item.errors, status: :unprocessable_entity
      end
    end

    def add_item
      product_id = cart_params[:product_id].to_i
      quantity = cart_params[:quantity].to_i

      cart_item = @cart.cart_items.find_by(product_id: product_id)

      if cart_item.present?
        cart_item.update(quantity: cart_item.quantity + quantity)
      else
        cart_item = @cart.cart_items.new(product_id: product_id, quantity: quantity)
      end

      if cart_item.save
        render json: format_cart_json(cart: @cart), status: :created
      else
        render json: cart_item.errors, status: :unprocessable_entity
      end
    end

    def destroy
      cart_item = @cart.cart_items.find_by(product_id: cart_params[:product_id])

      if cart_item.present?

        cart_item.delete

        render json: format_cart_json(cart: @cart), status: :ok
      else
        render json: { message: 'Item não foi encontrado' }, status: :not_found
      end
    end

    private

    def load_cart
      @cart ||= Cart.find_or_create_by(session_id: session[:cart_id]) do |cart|
        session[:cart_id] = cart.id
      end
    end

    def cart_params
      params.permit(:product_id, :quantity)
    end

    def format_cart_json(cart:)
      {
        id: cart.id,
        products: products(cart:),
        total_price: cart.total_price,
      }
    end

    def products(cart:)
      cart.cart_items.map do |item|
        product = item.product
        {
          id: product.id,
          name: product.name,
          quantity: item.quantity,
          price: product.price,
          total_price: item.total_price,
        }
      end
    end

    def item_already_added?(cart:, product_id:)
      cart.cart_items.find_by(product_id: product_id).present?
    end
  end
