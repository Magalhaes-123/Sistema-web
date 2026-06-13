# BOA CONTA - Sistema Universal de Gestão Empresarial

## 📋 Descrição

Sistema completo de gestão empresarial desenvolvido em PHP 8.0+ com suporte para:

✅ **Multi-País** - Suporte para múltiplos países com parametrizações específicas
✅ **Multi-Empresa** - Gestão de múltiplas empresas por utilizador
✅ **Multi-Moeda** - Suporte para diferentes moedas com conversão automática
✅ **Configuração Global** - Parametrizações centralizadas
✅ **Módulos Funcionais** - Comercial, Faturação, Fiscalidade, Contabilidade, RH
✅ **Autenticação & Autorização** - Sistema seguro com permissões por papel
✅ **Relatórios Avançados** - Geração de relatórios financeiros, fiscais e pessoais
✅ **Transações Seguras** - Suporte para transações ACID com rollback automático

## 🏗️ Estrutura do Projeto

```
boa-conta-sistema/
├── config/                 # Configurações da aplicação
│   ├── app.php
│   └── database.php
├── src/                    # Código-fonte (PSR-4)
│   ├── Core/              # Classes base (Database, BaseModel, Validator, etc)
│   ├── Auth/              # Sistema de autenticação
│   ├── Modules/           # Módulos funcionais
│   │   ├── Comercial/
│   │   ├── Faturacao/
│   │   ├── Fiscalidade/
│   │   ├── Contabilidade/
│   │   ├── RecursosHumanos/
│   │   └── Empresa/
│   └── Relatorios/        # Sistema de relatórios
├── database/
│   └── migrations/        # Scripts SQL
├── public/                # Arquivos públicos
│   └── index.php         # Entrada da aplicação
├── views/                 # Templates HTML
├── assets/                # CSS, JS, imagens
├── cache/ & tmp/          # Diretórios temporários
├── composer.json          # Dependências do Composer
└── README.md
```

## 🔧 Instalação

### Pré-requisitos
- PHP >= 8.0
- MySQL/MariaDB >= 5.7
- Composer
- Git

### Passos

```bash
# 1. Clonar repositório
git clone https://github.com/Magalhaes-123/boa-conta-sistema.git
cd boa-conta-sistema

# 2. Instalar dependências
composer install

# 3. Configurar variáveis de ambiente
cp .env.example .env
# Editar .env com suas configurações

# 4. Criar banco de dados
mysql -u root -p
CREATE DATABASE boa_conta CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;

# 5. Executar migrations
mysql -u root -p boa_conta < database/migrations/001_create_tables.sql

# 6. Iniciar servidor (desenvolvimento)
php -S localhost:8000 -t public
```

## 📦 Módulos

### Comercial
- **Clientes** - Gestão completa de clientes
- **Propostas** - Criação e rastreamento de propostas
- **Contratos** - Gestão de contratos
- **Histórico** - Registro de todas as transações

### Faturação
- **Emissão de Faturas** - Geração automática de números
- **Recibos** - Registro de pagamentos
- **Notas de Débito/Crédito** - Ajustes de valores
- **Auto-Cálculo de Impostos** - Cálculo automático por país
- **Rastreamento de Pendências** - Relatório de faturas não pagas

### Fiscalidade
- **Parametrizações por País** - Configurações específicas por jurisdição
- **Tipos de Empresa** - Diferentes regimes fiscais
- **Regimes Fiscais** - Enquadramento tributário
- **Calendário Fiscal** - Prazos e obrigações
- **Normas Contabilísticas** - Padrões de contabilização

### Contabilidade
- **Plano de Contas** - Estrutura hierárquica de contas
- **Lançamentos Contábeis** - Débitos e créditos
- **Exercícios Contabilísticos** - Períodos contábeis
- **Balanço Trial** - Verificação de equilíbrio
- **Centros de Custo** - Alocação de despesas

### Recursos Humanos
- **Gestão de Funcionários** - Cadastro e histórico
- **Salários** - Cálculo e processamento de folha
- **Descontos Legais** - Retenções automáticas
- **Mapas Salariais** - Estrutura de remuneração
- **Atração Automática** - Processamento automatizado

## 🔐 Autenticação & Segurança

- Autenticação baseada em sessões
- Hash seguro de senhas com `password_verify()`
- Proteção contra SQL Injection (prepared statements)
- Validação de entrada de dados
- Sistema de permissões por papel

## 📊 Relatórios

### Relatórios Disponíveis
- **Financeiro** - Fluxo de caixa e lançamentos
- **Fiscal** - Movimentos tributários
- **Pessoal** - Dados de recursos humanos
- **Vendas** - Análise de desempenho comercial

## 🚀 Recursos Avançados

- **Transações ACID** - Suporte para rollback automático
- **Logging** - Registro de operações críticas
- **Validação** - Sistema robusto de validação
- **Container de Injeção de Dependência** - Padrão de design moderno
- **Índices de Banco de Dados** - Otimização de performance

## 📝 Exemplo de Uso

```php
<?php

// Criar fatura
$faturaService = new BoaConta\Modules\Faturacao\Services\FaturaService($db);
$dados = [
    'empresa_id' => 1,
    'cliente_id' => 5,
    'numero_fatura' => 'AO/202401/00001',
    'valor' => 1500.00,
    'moeda' => 'AOA',
    'data_emissao' => date('Y-m-d'),
    'data_vencimento' => date('Y-m-d', strtotime('+30 days')),
    'status' => 'pendente'
];

$id = $faturaService->criarFatura($dados);

// Calcular imposto
$imposto = $faturaService->calcularImposto(1500.00, 'AO', 1);
echo "Imposto: " . $imposto['imposto'];
```

## 📞 Suporte

Para dúvidas ou problemas, crie uma issue no repositório.

## 📄 Licença

MIT License - Veja LICENSE.md para detalhes

## ✍️ Autor

**Magalhaes-123**

---

**Última atualização:** Junho 2026
