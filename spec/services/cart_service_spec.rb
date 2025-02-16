require 'rails_helper'
require 'redis'

RSpec.describe CartService do
  include ActiveSupport::Testing::TimeHelpers

  let(:cart_id) { 1 }
  let(:redis) { described_class.redis }

  before do
    redis.flushdb # Clear Redis before each test
  end

  describe ".update_cart_activity" do
    it "sets a cart activity key with the correct TTL" do
      described_class.update_cart_activity(cart_id)
      
      key = "#{CartService::REDIS_NAMESPACE}:#{cart_id}"
      expect(redis.ttl(key)).to be_within(5).of(CartService::CART_TTL)
    end
  end

  describe ".cart_expired?" do
    context "when the cart activity key does not exist" do
      it "returns true" do
        expect(described_class.cart_expired?(cart_id)).to be true
      end
    end

    context "when the cart activity key exists" do
      it "returns false" do
        described_class.update_cart_activity(cart_id)
        expect(described_class.cart_expired?(cart_id)).to be false
      end
    end
  end
end