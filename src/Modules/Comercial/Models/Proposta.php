<?php

namespace BoaConta\Modules\Comercial\Models;

use BoaConta\Core\BaseModel;

class Proposta extends BaseModel
{
    protected string $table = 'propostas';
    protected array $fillable = ['empresa_id', 'cliente_id', 'numero_proposta', 'descricao', 'valor', 'moeda', 'status', 'data_validade'];

    public function getByEmpresa(int $empresaId): array
    {
        return $this->db->query(
            "SELECT p.*, c.nome as cliente_nome FROM {$this->table} p 
             LEFT JOIN clientes c ON p.cliente_id = c.id 
             WHERE p.empresa_id = ? ORDER BY p.data_criacao DESC LIMIT 100",
            [$empresaId]
        );
    }

    public function getByCliente(int $clienteId): array
    {
        return $this->db->query(
            "SELECT * FROM {$this->table} WHERE cliente_id = ? ORDER BY data_criacao DESC",
            [$clienteId]
        );
    }

    public function getPropostasAbiertas(int $empresaId): array
    {
        return $this->db->query(
            "SELECT * FROM {$this->table} WHERE empresa_id = ? AND status IN ('pendente', 'aprovada') ORDER BY data_validade DESC",
            [$empresaId]
        );
    }
}
