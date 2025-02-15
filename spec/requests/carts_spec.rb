require "rails_helper"

RSpec.describe '/cart', type: :request do
  let(:cart) { create(:shopping_cart) }
  let(:product) { create(:product, price: 10) }

  describe 'GET /cart' do
    context 'when the cart exists and has items' do
      it 'returns the cart details with a status of OK' do  
        create(:cart_item, cart: cart, product: product, quantity: 2)
        
        get '/cart'
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include('products')
        expect(JSON.parse(response.body)['products'].count).to eq(1)
      end
    end
  end

  describe 'POST /cart' do
    context 'when the item is not already added to the cart' do
      it 'adds the item to the cart and returns the updated cart' do
        expect {
          post '/cart', params: { product_id: product.id, quantity: 1 }
        }.to change { cart.cart_items.count }.by(1)
        
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include('products')
      end
    end

    context 'when the item is already in the cart' do
      it 'returns an error message and status UNPROCESSABLE ENTITY' do
        create(:cart_item, cart: cart, product: product, quantity: 2)

        post '/cart', params: { product_id: product.id, quantity: 1 }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('Item já foi adicionado ao carrinho')
      end
    end
  end

  describe 'POST #add_item' do
    context 'when the item exists in the cart' do
      it 'updates the quantity of the item' do
        cart_item = create(:cart_item, cart: cart, product: product, quantity: 2)
        
        post '/cart/add_item/', params: { product_id: product.id, quantity: 2 }
        
        cart_item.reload
        expect(cart_item.quantity).to eq(4)  # 2 + 2
        expect(response).to have_http_status(:created)
      end
    end

    context 'when the item does not exist in the cart' do
      it 'adds the new item to the cart' do
        expect {
          post '/cart/add_item/', params: { product_id: product.id, quantity: 1 }
        }.to change { cart.cart_items.count }.by(1)
        
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when the item is found in the cart' do
      it 'removes the item from the cart' do
        _cart_item = create(:cart_item, cart: cart, product: product, quantity: 2)

        expect {
          delete '/cart', params: { product_id: product.id }
        }.to change { cart.cart_items.count }.by(-1)
        
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the item is not found in the cart' do
      it 'returns an error message with status NOT FOUND' do
        delete '/cart', params: { product_id: product.id }
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['message']).to eq('Item não foi encontrado')
      end
    end
  end
end

