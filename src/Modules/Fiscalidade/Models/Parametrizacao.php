<?php

namespace BoaConta\Modules\Fiscalidade\Models;

use BoaConta\Core\BaseModel;

class Parametrizacao extends BaseModel
{
    protected string $table = 'parametrizacao_fiscal';
    protected array $fillable = ['empresa_id', 'pais_codigo', 'regime_fiscal', 'normas_contabilisticas', 'regras_arredondamento', 'politicas_auditoria'];

    public function getByPais(string $paisCode, int $empresaId): ?array
    {
        $result = $this->db->query(
            "SELECT * FROM {$this->table} WHERE pais_codigo = ? AND empresa_id = ?",
            [$paisCode, $empresaId]
        );
        return $result[0] ?? null;
    }

    public function getTiposImposto(string $paisCode): array
    {
        return $this->db->query(
            "SELECT * FROM tipos_imposto WHERE pais_codigo = ? ORDER BY tipo",
            [$paisCode]
        );
    }

    public function getRegimesFiscais(string $paisCode): array
    {
        return $this->db->query(
            "SELECT DISTINCT regime_fiscal FROM {$this->table} WHERE pais_codigo = ?",
            [$paisCode]
        );
    }
}
