class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform(*_args)
    expired_cart_keys.each do |key|
      cart_id = extract_cart_id(key)

      if cart_missing?(cart_id)
        remove_cart_key(key)
        next
      end

      process_cart(cart_id)
      remove_cart_key(key) if cart_missing?(cart_id)
    end
  end

  private

  def expired_cart_keys
    redis.keys("cart_activity:*")
  end

  def extract_cart_id(key)
    key.split(":").last
  end

  def cart_missing?(cart_id)
    !Cart.exists?(id: cart_id)
  end

  def remove_cart_key(key)
    redis.del(key)
  end

  def process_cart(cart_id)
    cart = Cart.find(cart_id)
    cart.mark_as_abandoned
    cart.remove_if_abandoned
  end

  def redis
    @redis ||= Redis.new
  end
end
