require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  describe 'mark_as_abandoned' do
    let(:shopping_cart) { create(:shopping_cart) }

    it 'marks the shopping cart as abandoned if inactive for a certain time' do
      shopping_cart.update(last_interaction_at: 3.hours.ago)
      expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned? }.from(false).to(true)
    end

    it 'does not mark the shopping cart as abandoned if active' do
      shopping_cart.update(last_interaction_at: 1.hour.ago)
      expect { shopping_cart.mark_as_abandoned }.not_to change { shopping_cart.abandoned? }
    end

    it 'does not mark the shopping cart as abandoned if already abandoned' do
      shopping_cart.update(abandoned: true)
      expect { shopping_cart.mark_as_abandoned }.not_to change { shopping_cart.abandoned? }
    end
  end

  describe 'remove_if_abandoned' do
    let(:shopping_cart) { create(:shopping_cart, last_interaction_at: 7.days.ago) }

    it 'removes the shopping cart if abandoned for a certain time' do
      shopping_cart.mark_as_abandoned
      expect { shopping_cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
    end

    it 'does not remove the shopping cart if not abandoned' do
      shopping_cart.update(last_interaction_at: 1.hour.ago)
      expect { shopping_cart.remove_if_abandoned }.not_to change { Cart.count }
    end

    it 'does not remove the shopping cart if not abandoned for long enough' do
      shopping_cart.update(last_interaction_at: 6.days.ago)
      expect { shopping_cart.remove_if_abandoned }.not_to change { Cart.count }
    end
  end

  describe 'update_total_price' do
    let(:shopping_cart) { create(:shopping_cart) }
    let(:product) { create(:product, price: 100) }

    it 'updates the total price of the shopping cart' do
      create(:cart_item, cart: shopping_cart, product: product, quantity: 2)
      shopping_cart.update_total_price
      expect(shopping_cart.total_price).to eq(200)
    end
  end

  describe 'update_cart_activity' do
    let(:shopping_cart) { create(:shopping_cart) }

    it 'updates the cart activity' do
      expect(CartService).to receive(:update_cart_activity).with(shopping_cart.id)
      shopping_cart.update_cart_activity
    end
  end

  describe 'abandoned?' do
    let(:shopping_cart) { create(:shopping_cart) }

    it 'returns the abandoned status' do
      expect(shopping_cart.abandoned?).to eq(shopping_cart.abandoned)
    end
  end
end
