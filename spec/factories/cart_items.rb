# frozen_string_literal: true

FactoryBot.define do
  factory :cart_item do
    shopping_cart
    product
    quantity { 1 }
  end
end
