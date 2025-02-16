# Documentação da API

## Visão Geral
A API de carrinho de compras permite a manipulação dos itens adicionados ao carrinho por sessão. Os seguintes endpoints estão disponíveis:

## Endpoints

### 1. Obter o Carrinho
**GET /cart**

#### Descrição
Recupera o carrinho atual associado à sessão do usuário.

#### Respostas
- **200 OK**: Retorna os detalhes do carrinho.

#### Exemplo de Resposta:
```json
{
  "id": 1,
  "products": [
    {
      "id": 101,
      "name": "Produto A",
      "quantity": 2,
      "price": 50.0,
      "total_price": 100.0
    }
  ],
  "total_price": 100.0
}
```

---

### 2. Adicionar Item ao Carrinho
**POST /cart**

#### Descrição
Adiciona um novo item ao carrinho, caso o item já esteja presente, retorna um erro.

#### Parâmetros
- `product_id` (integer, obrigatório) - ID do produto a ser adicionado.
- `quantity` (integer, obrigatório) - Quantidade do produto.

#### Respostas
- **201 Created**: Item adicionado ao carrinho com sucesso.
- **422 Unprocessable Entity**: O item já foi adicionado ao carrinho.

#### Exemplo de Request:
```json
{
  "product_id": 101,
  "quantity": 2
}
```

#### Exemplo de Resposta (Sucesso):
```json
{
  "id": 1,
  "products": [
    {
      "id": 101,
      "name": "Produto A",
      "quantity": 2,
      "price": 50.0,
      "total_price": 100.0
    }
  ],
  "total_price": 100.0
}
```

#### Exemplo de Resposta (Erro):
```json
{
  "error": "Item já foi adicionado ao carrinho"
}
```

---

### 3. Adicionar Quantidade a um Item no Carrinho
**POST /cart/add_item**

#### Descrição
Adiciona quantidade a um item existente no carrinho. Se o item não existir, ele será criado.

#### Parâmetros
- `product_id` (integer, obrigatório) - ID do produto a ser atualizado.
- `quantity` (integer, obrigatório) - Quantidade adicional do produto.

#### Respostas
- **201 Created**: Item atualizado/adicionado ao carrinho.
- **422 Unprocessable Entity**: Erro ao atualizar o item.

#### Exemplo de Request:
```json
{
  "product_id": 101,
  "quantity": 3
}
```

#### Exemplo de Resposta:
```json
{
  "id": 1,
  "products": [
    {
      "id": 101,
      "name": "Produto A",
      "quantity": 5,
      "price": 50.0,
      "total_price": 250.0
    }
  ],
  "total_price": 250.0
}
```

---

### 4. Remover um Item do Carrinho
**DELETE /cart**

#### Descrição
Remove um item específico do carrinho.

#### Parâmetros
- `product_id` (integer, obrigatório) - ID do produto a ser removido.

#### Respostas
- **200 OK**: Item removido do carrinho.
- **404 Not Found**: Item não encontrado no carrinho.

#### Exemplo de Request:
```json
{
  "product_id": 101
}
```

#### Exemplo de Resposta (Sucesso):
```json
{
  "id": 1,
  "products": [],
  "total_price": 0.0
}
```

#### Exemplo de Resposta (Erro):
```json
{
  "message": "Item não foi encontrado"
}
```