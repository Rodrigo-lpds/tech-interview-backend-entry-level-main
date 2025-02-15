class CartService
  CART_TTL = 3.hours.to_i
  REDIS_NAMESPACE = "cart_activity"

  def self.update_cart_activity(cart_id)
    redis.setex("#{REDIS_NAMESPACE}:#{cart_id}", CART_TTL, Time.current.to_i)
  end

  def self.cart_expired?(cart_id)
    redis.ttl("#{REDIS_NAMESPACE}:#{cart_id}") == -2
  end

  def self.redis
    @redis ||= Redis.new
  end
end
