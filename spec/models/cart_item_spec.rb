# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartItem, type: :model do
  context 'when validating' do
    it 'validates presence of quantity' do
      cart = create(:shopping_cart)
      product = create(:product)
      
      cart_item = build(:cart_item, cart: cart, product: product, quantity: nil)

      expect(cart_item.valid?).to be_falsey
      expect(cart_item.errors[:quantity]).to include("can't be blank")
    end

    it 'validates numericality of quantity' do
      cart = create(:shopping_cart)
      product = create(:product)
      
      cart_item = build(:cart_item, cart: cart, product: product, quantity: -1)
      expect(cart_item.valid?).to be_falsey
      expect(cart_item.errors[:quantity]).to include('must be greater than or equal to 1')
    end
  end

  describe 'unit_price' do
    it 'returns item unit price' do
      product = create(:product, price: 100)
      cart = create(:shopping_cart)
      cart_item = create(:cart_item, cart: cart, product: product)

      expect(cart_item.unit_price).to eq(100)
    end
  end

  describe 'total_price' do
    it 'returns item total price' do
      product = create(:product, price: 100)
      cart = create(:shopping_cart)
      cart_item = create(:cart_item, cart: cart, product: product, quantity: 2)

      expect(cart_item.total_price).to eq(200)
    end
  end

  describe 'update_cart_total_price' do
    it 'updates cart total price' do
      product = create(:product, price: 100)
      cart = create(:shopping_cart)
      _cart_item = create(:cart_item, cart: cart, product: product, quantity: 2)
  
      # Reload the cart to get the updated total price from the database
      cart.reload
  
      expect(cart.total_price).to eq(200)
    end
  end  
end
