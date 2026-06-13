<?php

namespace BoaConta\Modules\Empresa\Models;

use BoaConta\Core\BaseModel;

class Empresa extends BaseModel
{
    protected string $table = 'empresas';
    protected array $fillable = ['nome', 'nif', 'email', 'telefone', 'pais_codigo', 'regime_fiscal'];

    public function getByUtilizador(int $utilizadorId): array
    {
        return $this->db->query(
            "SELECT e.* FROM {$this->table} e
             INNER JOIN utilizador_empresas ue ON e.id = ue.empresa_id
             WHERE ue.utilizador_id = ? AND e.ativa = 1 ORDER BY e.nome",
            [$utilizadorId]
        );
    }

    public function getConfiguracaoGlobal(int $empresaId): ?array
    {
        $result = $this->db->query(
            "SELECT * FROM configuracao_global WHERE empresa_id = ?",
            [$empresaId]
        );
        return $result[0] ?? null;
    }

    public function obterDashboard(int $empresaId): array
    {
        $clientes = $this->db->query(
            "SELECT COUNT(*) as total FROM clientes WHERE empresa_id = ? AND ativo = 1",
            [$empresaId]
        );
        
        $faturas = $this->db->query(
            "SELECT COUNT(*) as pendentes FROM faturas WHERE empresa_id = ? AND status = 'pendente'",
            [$empresaId]
        );
        
        $funcionarios = $this->db->query(
            "SELECT COUNT(*) as total FROM funcionarios WHERE empresa_id = ? AND status = 'ativo'",
            [$empresaId]
        );
        
        return [
            'clientes_ativos' => (int) ($clientes[0]['total'] ?? 0),
            'faturas_pendentes' => (int) ($faturas[0]['pendentes'] ?? 0),
            'funcionarios_ativos' => (int) ($funcionarios[0]['total'] ?? 0),
        ];
    }
}
