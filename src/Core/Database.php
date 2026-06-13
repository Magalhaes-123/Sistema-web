<?php

namespace BoaConta\Core;

use PDO;
use PDOException;
use Psr\Log\LoggerInterface;

class Database
{
    private static ?PDO $connection = null;
    private array $config;
    private ?LoggerInterface $logger;

    public function __construct(array $config, ?LoggerInterface $logger = null)
    {
        $this->config = $config;
        $this->logger = $logger;
    }

    public function connect(): PDO
    {
        if (self::$connection === null) {
            try {
                $driver = $this->config['driver'];
                $host = $this->config['host'];
                $database = $this->config['database'];
                $username = $this->config['username'];
                $password = $this->config['password'];
                $port = $this->config['port'] ?? 3306;

                $dsn = "{$driver}:host={$host};port={$port};dbname={$database};charset=utf8mb4";
                self::$connection = new PDO($dsn, $username, $password, [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false,
                ]);
                
                $this->logger?->info('Conexão com banco de dados estabelecida');
            } catch (PDOException $e) {
                $this->logger?->error('Erro de conexão: ' . $e->getMessage());
                throw new DatabaseException('Erro ao conectar com banco de dados', 0, $e);
            }
        }
        return self::$connection;
    }

    public function query(string $sql, array $params = []): array
    {
        try {
            $stmt = $this->connect()->prepare($sql);
            $stmt->execute($params);
            return $stmt->fetchAll();
        } catch (PDOException $e) {
            $this->logger?->error('Erro na query: ' . $e->getMessage(), ['sql' => $sql]);
            throw new DatabaseException('Erro ao executar query', 0, $e);
        }
    }

    public function execute(string $sql, array $params = []): bool
    {
        try {
            $stmt = $this->connect()->prepare($sql);
            return $stmt->execute($params);
        } catch (PDOException $e) {
            $this->logger?->error('Erro na execução: ' . $e->getMessage(), ['sql' => $sql]);
            throw new DatabaseException('Erro ao executar comando', 0, $e);
        }
    }

    public function lastInsertId(): string
    {
        return $this->connect()->lastInsertId();
    }

    public function beginTransaction(): void
    {
        $this->connect()->beginTransaction();
    }

    public function commit(): void
    {
        $this->connect()->commit();
    }

    public function rollback(): void
    {
        $this->connect()->rollback();
    }
}
