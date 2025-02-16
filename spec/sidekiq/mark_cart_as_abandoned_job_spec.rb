require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  let(:redis) { Redis.new }

  before do
    allow(Redis).to receive(:new).and_return(redis)
    allow(redis).to receive(:keys).with("cart_activity:*").and_return(["cart_activity:1", "cart_activity:2"])
    allow(redis).to receive(:del)
  end

  describe '#perform' do
    context 'when cart exists' do
      it 'processes the cart' do
        cart = create(:shopping_cart, id: 1)

        expect(Cart).to receive(:find).with("1").and_return(cart)

        expect(cart).to receive(:mark_as_abandoned)
        expect(cart).to receive(:remove_if_abandoned)
        expect(redis).not_to receive(:del).with("cart_activity:1")
        
        described_class.new.perform
      end
    end

    context 'when cart does not exist' do
      it 'removes the cart key from redis' do
        _cart = create(:shopping_cart, id: 1)
                
        expect(redis).to receive(:del).with("cart_activity:2")
        
        described_class.new.perform
      end
    end
  end
end
