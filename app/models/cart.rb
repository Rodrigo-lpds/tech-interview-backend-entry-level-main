class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
  
  after_commit :update_cart_activity
  
  def update_cart_activity
    CartService.update_cart_activity(id)
  end

  def update_total_price
    update(total_price: cart_items.sum { |item| item.total_price })
  end

  def mark_as_abandoned
    return if abandoned? || last_interaction_at > 3.hours.ago

    update(abandoned: true)
  end

  def remove_if_abandoned
    destroy if abandoned? && last_interaction_at < 7.days.ago
  end

  def abandoned?
    abandoned
  end
end
