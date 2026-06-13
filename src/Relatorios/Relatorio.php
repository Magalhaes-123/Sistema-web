<?php

namespace BoaConta\Relatorios;

use BoaConta\Core\Database;

class Relatorio
{
    protected Database $db;
    protected int $empresaId;

    public function __construct(Database $db, int $empresaId)
    {
        $this->db = $db;
        $this->empresaId = $empresaId;
    }

    public function gerarRelatorioFinanceiro(string $dataInicio, string $dataFim): array
    {
        return $this->db->query(
            "SELECT * FROM lancamentos WHERE empresa_id = ? AND data_lancamento BETWEEN ? AND ? ORDER BY data_lancamento DESC",
            [$this->empresaId, $dataInicio, $dataFim]
        );
    }

    public function gerarRelatorioFiscal(string $mes): array
    {
        return $this->db->query(
            "SELECT f.*, c.nome as cliente_nome FROM faturas f
             LEFT JOIN clientes c ON f.cliente_id = c.id
             WHERE f.empresa_id = ? AND DATE_FORMAT(f.data_emissao, '%Y-%m') = ?
             ORDER BY f.data_emissao",
            [$this->empresaId, $mes]
        );
    }

    public function gerarRelatorioPessoal(): array
    {
        return $this->db->query(
            "SELECT * FROM funcionarios WHERE empresa_id = ? AND status = 'ativo' ORDER BY nome",
            [$this->empresaId]
        );
    }

    public function gerarRelatorioVendas(string $dataInicio, string $dataFim): array
    {
        return $this->db->query(
            "SELECT 
                DATE(f.data_emissao) as data,
                SUM(f.valor) as total_vendas,
                COUNT(DISTINCT f.cliente_id) as total_clientes
             FROM faturas f
             WHERE f.empresa_id = ? AND f.data_emissao BETWEEN ? AND ?
             GROUP BY DATE(f.data_emissao)
             ORDER BY f.data_emissao DESC",
            [$this->empresaId, $dataInicio, $dataFim]
        );
    }
}
