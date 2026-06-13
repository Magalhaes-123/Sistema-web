<?php

namespace BoaConta\Core;

abstract class BaseModel
{
    protected Database $db;
    protected string $table;
    protected array $fillable = [];
    protected array $guarded = [];

    public function __construct(Database $db)
    {
        $this->db = $db;
    }

    public function getAll(int $limit = 100, int $offset = 0): array
    {
        return $this->db->query(
            "SELECT * FROM {$this->table} LIMIT ? OFFSET ?",
            [$limit, $offset]
        );
    }

    public function getById(int $id): ?array
    {
        $result = $this->db->query(
            "SELECT * FROM {$this->table} WHERE id = ?",
            [$id]
        );
        return $result[0] ?? null;
    }

    public function create(array $data): string
    {
        $data = $this->sanitizeData($data);
        $fields = implode(',', array_keys($data));
        $placeholders = implode(',', array_fill(0, count($data), '?'));
        $sql = "INSERT INTO {$this->table} ({$fields}) VALUES ({$placeholders})";
        
        $this->db->execute($sql, array_values($data));
        return $this->db->lastInsertId();
    }

    public function update(int $id, array $data): bool
    {
        if (empty($data)) {
            return false;
        }
        
        $data = $this->sanitizeData($data);
        $set = implode(', ', array_map(fn($k) => "{$k} = ?", array_keys($data)));
        $sql = "UPDATE {$this->table} SET {$set} WHERE id = ?";
        
        $values = array_values($data);
        $values[] = $id;
        
        return $this->db->execute($sql, $values);
    }

    public function delete(int $id): bool
    {
        return $this->db->execute("DELETE FROM {$this->table} WHERE id = ?", [$id]);
    }

    public function count(): int
    {
        $result = $this->db->query("SELECT COUNT(*) as total FROM {$this->table}");
        return (int) ($result[0]['total'] ?? 0);
    }

    protected function sanitizeData(array $data): array
    {
        if (!empty($this->guarded)) {
            foreach ($this->guarded as $field) {
                unset($data[$field]);
            }
        }
        
        if (!empty($this->fillable)) {
            $data = array_intersect_key($data, array_flip($this->fillable));
        }
        
        return $data;
    }
}
