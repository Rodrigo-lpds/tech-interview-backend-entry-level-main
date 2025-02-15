class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  has_many :cart_items, dependent: :destroy

  before_save :calculate_total_price

  accepts_nested_attributes_for :cart_items
  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado
  # 
  
  def calculate_total_price
    self.total_price = cart_items.pluck(:total_price).sum
  end
end
