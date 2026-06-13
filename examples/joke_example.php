<?php
// Arquivo: examples/joke_example.php
// Exemplos de uso do Gerador de Piadas

require_once __DIR__ . '/../vendor/autoload.php';

use BoaConta\Services\JokeGenerator;

echo "=== BOA CONTA - Exemplos de Uso do Gerador de Piadas ===\n\n";

$jokeGenerator = new JokeGenerator();

// Exemplo 1: Uma piada da Official Joke API
echo "1. Uma piada da Official Joke API:\n";
try {
    $joke = $jokeGenerator->generateJoke('official');
    echo "   Piada: " . $joke['joke'] . "\n";
    echo "   Fonte: " . $joke['source'] . "\n\n";
} catch (\Exception $e) {
    echo "   Erro: " . $e->getMessage() . "\n\n";
}

// Exemplo 2: Uma piada da JokeAPI
echo "2. Uma piada da JokeAPI:\n";
try {
    $joke = $jokeGenerator->generateJoke('jokeapi');
    echo "   Piada: " . $joke['joke'] . "\n";
    echo "   Categoria: " . ($joke['category'] ?? 'N/A') . "\n";
    echo "   Fonte: " . $joke['source'] . "\n\n";
} catch (\Exception $e) {
    echo "   Erro: " . $e->getMessage() . "\n\n";
}

// Exemplo 3: Uma piada de Chuck Norris
echo "3. Uma piada de Chuck Norris:\n";
try {
    $joke = $jokeGenerator->generateJoke('chuck_norris');
    echo "   Piada: " . $joke['joke'] . "\n";
    echo "   Fonte: " . $joke['source'] . "\n\n";
} catch (\Exception $e) {
    echo "   Erro: " . $e->getMessage() . "\n\n";
}

// Exemplo 4: Uma piada de qualquer fonte
echo "4. Uma piada de qualquer fonte (aleatória):\n";
try {
    $joke = $jokeGenerator->generateRandomJokeFromAnySource();
    echo "   Piada: " . $joke['joke'] . "\n";
    echo "   Fonte: " . $joke['source'] . "\n\n";
} catch (\Exception $e) {
    echo "   Erro: " . $e->getMessage() . "\n\n";
}

// Exemplo 5: Múltiplas piadas
echo "5. 3 piadas aleatórias:\n";
try {
    $jokes = $jokeGenerator->generateMultipleJokes(3, 'official');
    foreach ($jokes as $index => $joke) {
        echo "   Piada " . ($index + 1) . ": " . substr($joke['joke'], 0, 50) . "...\n";
    }
    echo "\n";
} catch (\Exception $e) {
    echo "   Erro: " . $e->getMessage() . "\n\n";
}

// Exemplo 6: Fontes disponíveis
echo "6. Fontes disponíveis:\n";
$sources = $jokeGenerator->getAvailableSources();
foreach ($sources as $key => $name) {
    echo "   - $key: $name\n";
}
echo "\n";

echo "=== Exemplos Completos ===\n";
echo "\nPara usar a API REST:\n";
echo "1. Uma piada: /api/jokes.php?action=random&source=official\n";
echo "2. Qualquer fonte: /api/jokes.php?action=random-source\n";
echo "3. Múltiplas piadas: /api/jokes.php?action=multiple&count=5&source=official\n";
echo "4. Listar fontes: /api/jokes.php?action=sources\n";
echo "\nPara usar a interface web:\n";
echo "Acesse: /jokes.html\n";
