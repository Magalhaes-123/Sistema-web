<?php

namespace BoaConta\Modules\Contabilidade\Models;

use BoaConta\Core\BaseModel;

class Lancamento extends BaseModel
{
    protected string $table = 'lancamentos';
    protected array $fillable = ['empresa_id', 'conta_id', 'tipo', 'valor', 'moeda', 'descricao', 'data_lancamento', 'periodo_contabil'];

    public function getByPeriodo(int $empresaId, string $dataInicio, string $dataFim): array
    {
        return $this->db->query(
            "SELECT * FROM {$this->table} WHERE empresa_id = ? AND data_lancamento BETWEEN ? AND ? ORDER BY data_lancamento DESC",
            [$empresaId, $dataInicio, $dataFim]
        );
    }

    public function getSaldoConta(int $contaId): float
    {
        $result = $this->db->query(
            "SELECT SUM(CASE WHEN tipo = 'debito' THEN valor ELSE -valor END) as saldo FROM {$this->table} WHERE conta_id = ?",
            [$contaId]
        );
        return (float) ($result[0]['saldo'] ?? 0);
    }

    public function getBalancoTrial(int $empresaId): array
    {
        return $this->db->query(
            "SELECT conta_id, 
                    SUM(CASE WHEN tipo = 'debito' THEN valor ELSE 0 END) as debito,
                    SUM(CASE WHEN tipo = 'credito' THEN valor ELSE 0 END) as credito
             FROM {$this->table} 
             WHERE empresa_id = ?
             GROUP BY conta_id",
            [$empresaId]
        );
    }
}
