-- Tabelas de Configuração
CREATE TABLE IF NOT EXISTS configuracao_global (
    id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id INT NOT NULL UNIQUE,
    pais_codigo VARCHAR(2) NOT NULL,
    idioma VARCHAR(5) DEFAULT 'pt_PT',
    moeda_padrao VARCHAR(3) NOT NULL,
    modo_online BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_empresa (empresa_id)
);

-- Tabela de Empresas
CREATE TABLE IF NOT EXISTS empresas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    nif VARCHAR(20) NOT NULL,
    email VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    pais_codigo VARCHAR(2) NOT NULL,
    regime_fiscal VARCHAR(50),
    ativa BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_nif (nif),
    KEY idx_pais (pais_codigo),
    KEY idx_ativa (ativa)
);

-- Tabela de Clientes
CREATE TABLE IF NOT EXISTS clientes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id INT NOT NULL,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    telefone VARCHAR(20),
    nif VARCHAR(20),
    endereco TEXT,
    cidade VARCHAR(100),
    pais_codigo VARCHAR(2),
    tipo VARCHAR(20),
    historico LONGTEXT,
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE,
    KEY idx_empresa (empresa_id),
    KEY idx_ativo (ativo),
    KEY idx_nif (nif)
);

-- Tabela de Propostas
CREATE TABLE IF NOT EXISTS propostas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id INT NOT NULL,
    cliente_id INT NOT NULL,
    numero_proposta VARCHAR(50) NOT NULL,
    descricao LONGTEXT,
    valor DECIMAL(12,2) NOT NULL,
    moeda VARCHAR(3) DEFAULT 'AOA',
    status VARCHAR(20) DEFAULT 'pendente',
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_validade DATE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE,
    UNIQUE KEY unique_proposta (numero_proposta),
    KEY idx_empresa (empresa_id),
    KEY idx_cliente (cliente_id),
    KEY idx_status (status)
);

-- Tabela de Faturas
CREATE TABLE IF NOT EXISTS faturas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id INT NOT NULL,
    cliente_id INT NOT NULL,
    numero_fatura VARCHAR(50) NOT NULL,
    valor DECIMAL(12,2) NOT NULL,
    moeda VARCHAR(3) DEFAULT 'AOA',
    data_emissao DATE NOT NULL,
    data_vencimento DATE,
    status VARCHAR(20) DEFAULT 'pendente',
    descricao LONGTEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE,
    UNIQUE KEY unique_fatura (numero_fatura),
    KEY idx_empresa (empresa_id),
    KEY idx_cliente (cliente_id),
    KEY idx_status (status),
    KEY idx_data_emissao (data_emissao),
    KEY idx_data_vencimento (data_vencimento)
);

-- Tabela de Recibos
CREATE TABLE IF NOT EXISTS recibos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    fatura_id INT NOT NULL,
    numero_recibo VARCHAR(50) NOT NULL,
    valor DECIMAL(12,2) NOT NULL,
    data_recebimento DATE NOT NULL,
    metodo_pagamento VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (fatura_id) REFERENCES faturas(id) ON DELETE CASCADE,
    UNIQUE KEY unique_recibo (numero_recibo),
    KEY idx_fatura (fatura_id)
);

-- Tabela de Tipos de Imposto
CREATE TABLE IF NOT EXISTS tipos_imposto (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pais_codigo VARCHAR(2) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    percentual DECIMAL(5,2) NOT NULL,
    descricao TEXT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_pais (pais_codigo)
);

-- Tabela de Parametrização Fiscal
CREATE TABLE IF NOT EXISTS parametrizacao_fiscal (
    id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id INT NOT NULL,
    pais_codigo VARCHAR(2) NOT NULL,
    regime_fiscal VARCHAR(50),
    normas_contabilisticas VARCHAR(100),
    regras_arredondamento TEXT,
    politicas_auditoria LONGTEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE,
    UNIQUE KEY unique_empresa_pais (empresa_id, pais_codigo),
    KEY idx_pais (pais_codigo)
);

-- Tabela de Contas (Plano de Contas)
CREATE TABLE IF NOT EXISTS contas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id INT NOT NULL,
    numero_conta VARCHAR(20) NOT NULL,
    nome VARCHAR(255) NOT NULL,
    tipo VARCHAR(50),
    saldo DECIMAL(14,2) DEFAULT 0,
    ativa BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE,
    UNIQUE KEY unique_conta (empresa_id, numero_conta),
    KEY idx_empresa (empresa_id),
    KEY idx_tipo (tipo)
);

-- Tabela de Lançamentos Contábeis
CREATE TABLE IF NOT EXISTS lancamentos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id INT NOT NULL,
    conta_id INT NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    valor DECIMAL(14,2) NOT NULL,
    moeda VARCHAR(3) DEFAULT 'AOA',
    descricao LONGTEXT,
    data_lancamento DATE NOT NULL,
    periodo_contabil VARCHAR(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE,
    FOREIGN KEY (conta_id) REFERENCES contas(id) ON DELETE RESTRICT,
    KEY idx_empresa (empresa_id),
    KEY idx_conta (conta_id),
    KEY idx_data (data_lancamento),
    KEY idx_tipo (tipo)
);

-- Tabela de Funcionários
CREATE TABLE IF NOT EXISTS funcionarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    empresa_id INT NOT NULL,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    telefone VARCHAR(20),
    nif VARCHAR(20),
    data_admissao DATE NOT NULL,
    cargo VARCHAR(100),
    departamento VARCHAR(100),
    status VARCHAR(20) DEFAULT 'ativo',
    desconto_legal VARCHAR(100),
    mapa_salarial INT,
    atracao_automatica BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE,
    KEY idx_empresa (empresa_id),
    KEY idx_status (status),
    KEY idx_nif (nif)
);

-- Tabela de Salários
CREATE TABLE IF NOT EXISTS salarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    funcionario_id INT NOT NULL,
    mes VARCHAR(7) NOT NULL,
    valor_bruto DECIMAL(12,2) NOT NULL,
    descontos DECIMAL(12,2) DEFAULT 0,
    valor_liquido DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (funcionario_id) REFERENCES funcionarios(id) ON DELETE CASCADE,
    UNIQUE KEY unique_funcionario_mes (funcionario_id, mes),
    KEY idx_mes (mes)
);

-- Tabela de Utilizadores
CREATE TABLE IF NOT EXISTS utilizadores (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    status VARCHAR(20) DEFAULT 'ativo',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_email (email),
    KEY idx_status (status)
);

-- Tabela de Relação Utilizador-Empresa
CREATE TABLE IF NOT EXISTS utilizador_empresas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    utilizador_id INT NOT NULL,
    empresa_id INT NOT NULL,
    papel VARCHAR(50) DEFAULT 'usuario',
    permissoes JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (utilizador_id) REFERENCES utilizadores(id) ON DELETE CASCADE,
    FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_empresa (utilizador_id, empresa_id),
    KEY idx_empresa (empresa_id)
);

-- Índices adicionais para otimização
CREATE INDEX idx_relatorio_vendas ON faturas(empresa_id, data_emissao, status);
CREATE INDEX idx_relatorio_financeiro ON lancamentos(empresa_id, data_lancamento);
CREATE INDEX idx_relatorio_rh ON funcionarios(empresa_id, status, departamento);
