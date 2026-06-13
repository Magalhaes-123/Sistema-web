# Gerador de Piadas - Random Joke Generator

## Descrição

Sistema completo para gerar piadas aleatórias usando múltiplas APIs externas integrado ao BOA CONTA.

### APIs Suportadas

1. **Official Joke API** - `https://official-joke-api.appspot.com/random_joke`
2. **JokeAPI** - `https://v2.jokeapi.dev/joke/Any`
3. **Chuck Norris API** - `http://api.icndb.com/jokes/random`

## Arquivos Criados

### 1. `src/Services/JokeGenerator.php`
Classe principal que gerencia a geração de piadas:
- `generateJoke($source)` - Gera uma piada de uma fonte específica
- `generateRandomJokeFromAnySource()` - Gera uma piada de qualquer fonte aleatoriamente
- `generateMultipleJokes($count, $source)` - Gera múltiplas piadas
- `getAvailableSources()` - Lista fontes disponíveis

### 2. `src/Controllers/JokeController.php`
Controlador para gerenciar requisições HTTP:
- `getRandomJoke()` - Endpoint para uma piada aleatória
- `getJokeFromRandomSource()` - Endpoint para qualquer fonte
- `getMultipleJokes()` - Endpoint para múltiplas piadas
- `getSources()` - Endpoint para listar fontes

### 3. `public/api/jokes.php`
API REST endpoint:
```
GET /api/jokes.php?action=random&source=official
GET /api/jokes.php?action=random-source
GET /api/jokes.php?action=multiple&count=5&source=official
GET /api/jokes.php?action=sources
```

### 4. `public/jokes.html`
Interface web interativa com:
- Seleção de fonte de piadas
- Botão para piada aleatória
- Botão para qualquer fonte
- Gerador de múltiplas piadas
- UI responsiva e moderna

## Como Usar

### Instalação de Dependências

Adicione ao seu `composer.json`:
```json
"require": {
    "guzzlehttp/guzzle": "^7.0"
}
```

Depois execute:
```bash
composer update
```

### Via PHP

```php
use BoaConta\Services\JokeGenerator;

$jokeGenerator = new JokeGenerator();

// Uma piada aleatória
$joke = $jokeGenerator->generateJoke('official');
echo $joke['joke'];

// Múltiplas piadas
$jokes = $jokeGenerator->generateMultipleJokes(5, 'official');
```

### Via API REST

```bash
# Uma piada
curl "http://localhost:8000/api/jokes.php?action=random&source=official"

# Qualquer fonte
curl "http://localhost:8000/api/jokes.php?action=random-source"

# Múltiplas piadas
curl "http://localhost:8000/api/jokes.php?action=multiple&count=5&source=official"

# Fontes disponíveis
curl "http://localhost:8000/api/jokes.php?action=sources"
```

### Via JavaScript/Frontend

```javascript
// Uma piada
fetch('/api/jokes.php?action=random&source=official')
  .then(res => res.json())
  .then(data => console.log(data.data.joke));

// Múltiplas piadas
fetch('/api/jokes.php?action=multiple&count=5')
  .then(res => res.json())
  .then(data => data.data.forEach(joke => console.log(joke.joke)));
```

## Respostas da API

### Sucesso (200)
```json
{
  "success": true,
  "data": {
    "source": "Official Joke API",
    "type": "general",
    "joke": "Why did the scarecrow win an award? Because he was outstanding in his field.",
    "setup": "Why did the scarecrow win an award?",
    "punchline": "Because he was outstanding in his field.",
    "id": 10
  }
}
```

### Erro (400/500)
```json
{
  "success": false,
  "error": "Descrição do erro"
}
```

## Exemplos de Uso

Veja `examples/joke_example.php` para exemplos completos.

## Interface Web

Acesse `http://localhost:8000/jokes.html` para usar a interface interativa.

### Features da Interface
- ✅ Seleção de fonte de piadas
- ✅ Controle de quantidade de piadas
- ✅ Carregamento com animação
- ✅ Mensagens de erro/sucesso
- ✅ Design responsivo
- ✅ CORS habilitado

## Tratamento de Erros

- Timeout de 5 segundos para requisições
- Tratamento de exceções Guzzle
- Logging de erros
- Respostas de erro estruturadas
- Validação de parâmetros

## Performance

- Delay de 500ms entre requisições múltiplas (rate limiting)
- Máximo de 20 piadas por requisição
- HTTP timeout configurável
- Cliente HTTP com pool de conexões

## Segurança

- CORS habilitado (configurável)
- Validação de entrada
- Tratamento seguro de exceções
- Sanitização de output JSON

## Melhorias Futuras

- [ ] Cache de piadas
- [ ] Filtragem por categoria
- [ ] Limite de taxa (rate limiting)
- [ ] Autenticação opcional
- [ ] Banco de dados local de piadas
- [ ] Tradução de piadas

## Licença

MIT
