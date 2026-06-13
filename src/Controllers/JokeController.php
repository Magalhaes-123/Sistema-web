<?php

namespace BoaConta\Controllers;

use BoaConta\Services\JokeGenerator;

class JokeController
{
    private JokeGenerator $jokeGenerator;

    public function __construct(JokeGenerator $jokeGenerator)
    {
        $this->jokeGenerator = $jokeGenerator;
    }

    /**
     * Retorna uma piada aleatória
     */
    public function getRandomJoke()
    {
        try {
            $source = $_GET['source'] ?? 'official';
            $joke = $this->jokeGenerator->generateJoke($source);
            
            return $this->jsonResponse([
                'success' => true,
                'data' => $joke,
            ]);
        } catch (\Exception $e) {
            return $this->jsonResponse([
                'success' => false,
                'error' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Retorna uma piada de qualquer fonte
     */
    public function getJokeFromRandomSource()
    {
        try {
            $joke = $this->jokeGenerator->generateRandomJokeFromAnySource();
            
            return $this->jsonResponse([
                'success' => true,
                'data' => $joke,
            ]);
        } catch (\Exception $e) {
            return $this->jsonResponse([
                'success' => false,
                'error' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Retorna múltiplas piadas
     */
    public function getMultipleJokes()
    {
        try {
            $count = min((int)($_GET['count'] ?? 5), 20); // Máximo 20
            $source = $_GET['source'] ?? 'official';
            $jokes = $this->jokeGenerator->generateMultipleJokes($count, $source);
            
            return $this->jsonResponse([
                'success' => true,
                'count' => count($jokes),
                'data' => $jokes,
            ]);
        } catch (\Exception $e) {
            return $this->jsonResponse([
                'success' => false,
                'error' => $e->getMessage(),
            ], 400);
        }
    }

    /**
     * Lista as fontes disponíveis
     */
    public function getSources()
    {
        $sources = $this->jokeGenerator->getAvailableSources();
        
        return $this->jsonResponse([
            'success' => true,
            'sources' => $sources,
        ]);
    }

    /**
     * Retorna resposta JSON
     */
    private function jsonResponse(array $data, int $statusCode = 200): void
    {
        header('Content-Type: application/json');
        http_response_code($statusCode);
        echo json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }
}
