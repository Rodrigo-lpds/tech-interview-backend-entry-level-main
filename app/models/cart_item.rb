class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product
  has_many :cart_items, dependent: :destroy

  validates_presence_of :quantity
  validates_numericality_of :quantity, greater_than_or_equal_to: 1

  after_commit :update_cart_total_price

  def unit_price
    product.price
  end

  def total_price
    unit_price * quantity
  end

  def update_cart_total_price
    cart.update_total_price
  end
end
