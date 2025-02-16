# O Desafio - Carrinho de compras
O desafio consiste em uma API para gerenciamento do um carrinho de compras de e-commerce.

Você deve desenvolver utilizando a linguagem Ruby e framework Rails, uma API Rest que terá 3 endpoins que deverão implementar as seguintes funcionalidades:

### 1. Registrar um produto no carrinho
Criar um endpoint para inserção de produtos no carrinho.

Se não existir um carrinho para a sessão, criar o carrinho e salvar o ID do carrinho na sessão.

Adicionar o produto no carrinho e devolver o payload com a lista de produtos do carrinho atual.


ROTA: `/cart`
Payload:
```js
{
  "product_id": 345, // id do produto sendo adicionado
  "quantity": 2, // quantidade de produto a ser adicionado
}
```

Response
```js
{
  "id": 789, // id do carrinho
  "products": [
    {
      "id": 645,
      "name": "Nome do produto",
      "quantity": 2,
      "unit_price": 1.99, // valor unitário do produto
      "total_price": 3.98, // valor total do produto
    },
    {
      "id": 646,
      "name": "Nome do produto 2",
      "quantity": 2,
      "unit_price": 1.99,
      "total_price": 3.98,
    },
  ],
  "total_price": 7.96 // valor total no carrinho
}
```

### 2. Listar itens do carrinho atual
Criar um endpoint para listar os produtos no carrinho atual.

ROTA: `/cart`

Response:
```js
{
  "id": 789, // id do carrinho
  "products": [
    {
      "id": 645,
      "name": "Nome do produto",
      "quantity": 2,
      "unit_price": 1.99, // valor unitário do produto
      "total_price": 3.98, // valor total do produto
    },
    {
      "id": 646,
      "name": "Nome do produto 2",
      "quantity": 2,
      "unit_price": 1.99,
      "total_price": 3.98,
    },
  ],
  "total_price": 7.96 // valor total no carrinho
}
```

### 3. Alterar a quantidade de produtos no carrinho 
Um carrinho pode ter _N_ produtos, se o produto já existir no carrinho, apenas a quantidade dele deve ser alterada

ROTA: `/cart/add_item`

Payload
```json
{
  "product_id": 1230,
  "quantity": 1
}
```
Response:
```json
{
  "id": 1,
  "products": [
    {
      "id": 1230,
      "name": "Nome do produto X",
      "quantity": 2, // considerando que esse produto já estava no carrinho
      "unit_price": 7.00, 
      "total_price": 14.00, 
    },
    {
      "id": 01020,
      "name": "Nome do produto Y",
      "quantity": 1,
      "unit_price": 9.90, 
      "total_price": 9.90, 
    },
  ],
  "total_price": 23.9
}
```

### 3. Remover um produto do carrinho 

Criar um endpoint para excluir um produto do do carrinho. 

ROTA: `/cart/:product_id`


#### Detalhes adicionais:

- Verifique se o produto existe no carrinho antes de tentar removê-lo.
- Se o produto não estiver no carrinho, retorne uma mensagem de erro apropriada.
- Após remover o produto, retorne o payload com a lista atualizada de produtos no carrinho.
- Certifique-se de que o endpoint lida corretamente com casos em que o carrinho está vazio após a remoção do produto.

### 5. Excluir carrinhos abandonados
Um carrinho é considerado abandonado quando estiver sem interação (adição ou remoção de produtos) há mais de 3 horas.

- Quando este cenário ocorrer, o carrinho deve ser marcado como abandonado.
- Se o carrinho estiver abandonado há mais de 7 dias, remover o carrinho.
- Utilize um Job para gerenciar (marcar como abandonado e remover) carrinhos sem interação.
- Configure a aplicação para executar este Job nos períodos especificados acima.

## Implementação
Para facilitar o desenvolvimento foi configurado as dependências necessária via docker, assim sendo necessário em sua dependência a instalação do `docker-compose v2.29.2`.

Para inicialização só é necessário executar o script na raiz do projeto:

> Talvez seja necessário executar como superuser(sudo)

```
./dev.sh
```

### Testes  

Para executar os testes, siga os passos abaixo:  

1. Acesse o contêiner da aplicação:  

   ```
   docker exec -it rails_app bash
   ```  

2. Dentro do contêiner, execute os testes com:  

   ```
   bundle exec rspec
   ```

### Desenvolvimento da API
A documentação da API pode ser encontrada com mais detalhes em [docs/api.md](https://github.com/Rodrigo-lpds/tech-interview-backend-entry-level-main/blob/main/docs/api.md)

### Agendamento de carrinhos abandonados

#### **1. Atualização da atividade do carrinho (`CartService`)**
A classe `CartService` mantém um controle da atividade dos carrinhos usando **Redis**:

- Quando um usuário interage com um carrinho (por exemplo, adicionando um item), o método `update_cart_activity(cart_id)` é chamado.  
  - Isso armazena um timestamp no Redis com **tempo de expiração (`CART_TTL`) de 3 horas**.
  - O Redis automaticamente remove a chave após esse tempo caso o carrinho não possua mais nenhuma interação

- O método `cart_expired?(cart_id)` verifica se a chave do carrinho expirou no Redis.
  - O Redis retorna `-2` para `ttl` quando a chave não existe mais (indicando que o carrinho ficou inativo por mais de 3 horas).

#### **2. Job para marcar carrinhos abandonados (`MarkCartAsAbandonedJob`)**
Esse job roda a cada **30 minutos** (definido no `scheduler.yml`) e executa os seguintes passos:

1. **Recupera todas as chaves de carrinhos ativos no Redis** (`expired_cart_keys`).
2. **Itera sobre essas chaves** e extrai o `cart_id`.
3. **Verifica se o carrinho ainda existe no banco** (`cart_missing?`).
   - Se **não existir**, apenas remove a chave do Redis.
   - Se **existir**, ele processa o carrinho:
     - **Marca como abandonado** (`cart.mark_as_abandoned`).
     - **Remove, se necessário** (`cart.remove_if_abandoned`).
4. **Remove a chave do Redis se o carrinho foi excluído** (`remove_cart_key`).


#### **3. Como o Job age sobre carrinhos abandonados?**
- Se um usuário **não interagir por mais de 3 horas**, o Redis automaticamente expira a chave.
- O job roda a cada **30 minutos** e identifica quais carrinhos **não têm mais chave no Redis**.
- Para cada carrinho encontrado:
  - É verificado se pode **marcar como abandonado**.
  - É verificado se pode **remover carrinho** (`remove_if_abandoned`).

