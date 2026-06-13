<?php

namespace BoaConta\Modules\Faturacao\Models;

use BoaConta\Core\BaseModel;

class Fatura extends BaseModel
{
    protected string $table = 'faturas';
    protected array $fillable = ['empresa_id', 'cliente_id', 'numero_fatura', 'valor', 'moeda', 'data_emissao', 'data_vencimento', 'status'];

    public function getByEmpresa(int $empresaId): array
    {
        return $this->db->query(
            "SELECT f.*, c.nome as cliente_nome FROM {$this->table} f
             LEFT JOIN clientes c ON f.cliente_id = c.id
             WHERE f.empresa_id = ? ORDER BY f.data_emissao DESC LIMIT 500",
            [$empresaId]
        );
    }

    public function getPendentesDePagamento(int $empresaId): array
    {
        return $this->db->query(
            "SELECT f.*, c.nome as cliente_nome FROM {$this->table} f
             LEFT JOIN clientes c ON f.cliente_id = c.id
             WHERE f.empresa_id = ? AND f.status = 'pendente' ORDER BY f.data_vencimento ASC",
            [$empresaId]
        );
    }

    public function getTotalArrecadacao(int $empresaId, string $dataInicio, string $dataFim): float
    {
        $result = $this->db->query(
            "SELECT SUM(valor) as total FROM {$this->table} WHERE empresa_id = ? AND data_emissao BETWEEN ? AND ? AND status = 'pago'",
            [$empresaId, $dataInicio, $dataFim]
        );
        return (float) ($result[0]['total'] ?? 0);
    }
}
