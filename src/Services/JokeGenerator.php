<?php

namespace BoaConta\Services;

use GuzzleHttp\Client;
use GuzzleHttp\Exception\GuzzleException;
use Psr\Log\LoggerInterface;

class JokeGenerator
{
    private Client $httpClient;
    private ?LoggerInterface $logger;
    
    // APIs disponíveis
    private const OFFICIAL_JOKE_API = 'https://official-joke-api.appspot.com/random_joke';
    private const JOKE_API = 'https://v2.jokeapi.dev/joke/Any';
    private const CHUCK_NORRIS_API = 'http://api.icndb.com/jokes/random';
    
    private array $apis = [
        'official' => self::OFFICIAL_JOKE_API,
        'jokeapi' => self::JOKE_API,
        'chuck_norris' => self::CHUCK_NORRIS_API,
    ];

    public function __construct(?LoggerInterface $logger = null)
    {
        $this->httpClient = new Client([
            'timeout' => 5,
            'connect_timeout' => 3,
        ]);
        $this->logger = $logger;
    }

    /**
     * Gera uma piada aleatória de um API externo
     * 
     * @param string $source Fonte da piada (official, jokeapi, chuck_norris)
     * @return array Piada formatada
     * @throws \Exception
     */
    public function generateJoke(string $source = 'official'): array
    {
        if (!isset($this->apis[$source])) {
            throw new \InvalidArgumentException("Fonte '{$source}' não suportada");
        }

        $url = $this->apis[$source];
        
        try {
            $response = $this->httpClient->get($url);
            $data = json_decode($response->getBody(), true);
            
            $joke = match($source) {
                'official' => $this->parseOfficialJoke($data),
                'jokeapi' => $this->parseJokeApi($data),
                'chuck_norris' => $this->parseChuckNorris($data),
            };
            
            $this->logger?->info('Piada gerada com sucesso', ['source' => $source]);
            
            return $joke;
        } catch (GuzzleException $e) {
            $this->logger?->error('Erro ao buscar piada', ['source' => $source, 'error' => $e->getMessage()]);
            throw new \Exception("Erro ao buscar piada de {$source}: " . $e->getMessage());
        }
    }

    /**
     * Gera uma piada de qualquer fonte disponível aleatoriamente
     * 
     * @return array
     */
    public function generateRandomJokeFromAnySource(): array
    {
        $sources = array_keys($this->apis);
        $randomSource = $sources[array_rand($sources)];
        
        return $this->generateJoke($randomSource);
    }

    /**
     * Gera múltiplas piadas
     * 
     * @param int $count
     * @param string $source
     * @return array
     */
    public function generateMultipleJokes(int $count = 5, string $source = 'official'): array
    {
        $jokes = [];
        
        for ($i = 0; $i < $count; $i++) {
            try {
                $jokes[] = $this->generateJoke($source);
                usleep(500000); // Esperar 0.5 segundo entre requisições
            } catch (\Exception $e) {
                $this->logger?->warning('Erro ao gerar piada ' . ($i + 1), ['error' => $e->getMessage()]);
            }
        }
        
        return $jokes;
    }

    /**
     * Parse da resposta da Official Joke API
     */
    private function parseOfficialJoke(array $data): array
    {
        return [
            'source' => 'Official Joke API',
            'type' => $data['type'] ?? 'general',
            'joke' => isset($data['punchline']) 
                ? "{$data['setup']} {$data['punchline']}"
                : ($data['joke'] ?? 'Piada não disponível'),
            'setup' => $data['setup'] ?? '',
            'punchline' => $data['punchline'] ?? '',
            'id' => $data['id'] ?? null,
        ];
    }

    /**
     * Parse da resposta da JokeAPI
     */
    private function parseJokeApi(array $data): array
    {
        if ($data['type'] === 'twopart') {
            return [
                'source' => 'JokeAPI',
                'type' => 'twopart',
                'category' => $data['category'] ?? 'General',
                'joke' => "{$data['setup']} {$data['delivery']}",
                'setup' => $data['setup'] ?? '',
                'punchline' => $data['delivery'] ?? '',
                'id' => $data['id'] ?? null,
            ];
        }
        
        return [
            'source' => 'JokeAPI',
            'type' => 'single',
            'category' => $data['category'] ?? 'General',
            'joke' => $data['joke'] ?? 'Piada não disponível',
            'id' => $data['id'] ?? null,
        ];
    }

    /**
     * Parse da resposta da Chuck Norris API
     */
    private function parseChuckNorris(array $data): array
    {
        $joke = $data['value']['joke'] ?? 'Piada não disponível';
        
        return [
            'source' => 'Chuck Norris API',
            'type' => 'general',
            'joke' => $joke,
            'id' => $data['value']['id'] ?? null,
            'is_chuck_norris' => true,
        ];
    }

    /**
     * Lista as fontes de piadas disponíveis
     */
    public function getAvailableSources(): array
    {
        return [
            'official' => 'Official Joke API',
            'jokeapi' => 'JokeAPI',
            'chuck_norris' => 'Chuck Norris Database',
        ];
    }
}
