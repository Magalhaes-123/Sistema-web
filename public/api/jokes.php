<?php

// Arquivo: public/api/jokes.php
// Roteador de API para piadas

require_once __DIR__ . '/../../vendor/autoload.php';

use BoaConta\Services\JokeGenerator;
use BoaConta\Controllers\JokeController;

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

try {
    $jokeGenerator = new JokeGenerator();
    $jokeController = new JokeController($jokeGenerator);
    
    $action = $_GET['action'] ?? 'random';
    
    match($action) {
        'random' => $jokeController->getRandomJoke(),
        'random-source' => $jokeController->getJokeFromRandomSource(),
        'multiple' => $jokeController->getMultipleJokes(),
        'sources' => $jokeController->getSources(),
        default => jsonResponse([
            'success' => false,
            'error' => "Ação '{$action}' não encontrada. Ações disponíveis: random, random-source, multiple, sources",
        ], 404),
    };
} catch (\Exception $e) {
    jsonResponse([
        'success' => false,
        'error' => $e->getMessage(),
    ], 500);
}

function jsonResponse(array $data, int $statusCode = 200): void
{
    http_response_code($statusCode);
    echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    exit;
}
