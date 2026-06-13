<?php

namespace BoaConta\Modules\RecursosHumanos\Models;

use BoaConta\Core\BaseModel;

class Funcionario extends BaseModel
{
    protected string $table = 'funcionarios';
    protected array $fillable = ['empresa_id', 'nome', 'email', 'telefone', 'nif', 'data_admissao', 'cargo', 'departamento', 'status'];

    public function getByEmpresa(int $empresaId): array
    {
        return $this->db->query(
            "SELECT * FROM {$this->table} WHERE empresa_id = ? AND status = 'ativo' ORDER BY nome",
            [$empresaId]
        );
    }

    public function getSalarios(int $empresaId, string $mes): array
    {
        return $this->db->query(
            "SELECT f.*, s.valor_bruto, s.descontos, s.valor_liquido FROM {$this->table} f
             LEFT JOIN salarios s ON f.id = s.funcionario_id AND s.mes = ?
             WHERE f.empresa_id = ? AND f.status = 'ativo' ORDER BY f.nome",
            [$mes, $empresaId]
        );
    }

    public function getTotalFolha(int $empresaId, string $mes): array
    {
        $result = $this->db->query(
            "SELECT 
                SUM(s.valor_bruto) as total_bruto,
                SUM(s.descontos) as total_descontos,
                SUM(s.valor_liquido) as total_liquido
             FROM salarios s
             INNER JOIN {$this->table} f ON s.funcionario_id = f.id
             WHERE f.empresa_id = ? AND s.mes = ?",
            [$empresaId, $mes]
        );
        return $result[0] ?? ['total_bruto' => 0, 'total_descontos' => 0, 'total_liquido' => 0];
    }
}
