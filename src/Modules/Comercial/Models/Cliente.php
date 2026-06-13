<?php

namespace BoaConta\Modules\Comercial\Models;

use BoaConta\Core\BaseModel;

class Cliente extends BaseModel
{
    protected string $table = 'clientes';
    protected array $fillable = ['empresa_id', 'nome', 'email', 'telefone', 'nif', 'endereco', 'cidade', 'pais_codigo', 'tipo'];

    public function getByEmpresa(int $empresaId, int $limit = 100): array
    {
        return $this->db->query(
            "SELECT * FROM {$this->table} WHERE empresa_id = ? AND ativo = 1 ORDER BY nome LIMIT ?",
            [$empresaId, $limit]
        );
    }

    public function search(string $termo, int $empresaId): array
    {
        return $this->db->query(
            "SELECT * FROM {$this->table} WHERE empresa_id = ? AND ativo = 1 AND (nome LIKE ? OR email LIKE ? OR nif LIKE ?) LIMIT 20",
            [$empresaId, "%{$termo}%", "%{$termo}%", "%{$termo}%"]
        );
    }

    public function getClientesAtivos(int $empresaId): int
    {
        $result = $this->db->query(
            "SELECT COUNT(*) as total FROM {$this->table} WHERE empresa_id = ? AND ativo = 1",
            [$empresaId]
        );
        return (int) ($result[0]['total'] ?? 0);
    }
}
