<?php

namespace BoaConta\Modules\Faturacao\Services;

use BoaConta\Core\Database;
use BoaConta\Modules\Faturacao\Models\Fatura;

class FaturaService
{
    private Fatura $faturaModel;
    private Database $db;

    public function __construct(Database $db)
    {
        $this->db = $db;
        $this->faturaModel = new Fatura($db);
    }

    public function gerarNumeroFatura(int $empresaId, string $paisCode): string
    {
        $ano = date('Y');
        $mes = date('m');
        
        $result = $this->db->query(
            "SELECT COUNT(*) as total FROM faturas WHERE empresa_id = ? AND YEAR(data_emissao) = ? AND MONTH(data_emissao) = ?",
            [$empresaId, $ano, $mes]
        );
        
        $sequencia = ((int)($result[0]['total'] ?? 0)) + 1;
        
        return "{$paisCode}/{$ano}{$mes}/" . str_pad($sequencia, 5, '0', STR_PAD_LEFT);
    }

    public function criarFatura(array $dados): string
    {
        $this->db->beginTransaction();
        
        try {
            $id = $this->faturaModel->create($dados);
            $this->db->commit();
            return $id;
        } catch (\Exception $e) {
            $this->db->rollback();
            throw $e;
        }
    }

    public function calcularImposto(float $valor, string $paisCode, int $empresaId): array
    {
        $result = $this->db->query(
            "SELECT * FROM tipos_imposto WHERE pais_codigo = ?",
            [$paisCode]
        );
        
        if (empty($result)) {
            return ['imposto' => 0, 'percentual' => 0];
        }
        
        $imposto = $result[0];
        $valorImposto = $valor * ($imposto['percentual'] / 100);
        
        return [
            'imposto' => round($valorImposto, 2),
            'percentual' => $imposto['percentual'],
            'tipo' => $imposto['tipo']
        ];
    }
}
