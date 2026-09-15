-- ====================================================================
-- SISTEMA INTEGRADO DE GESTÃO EMPRESARIAL E FATURAÇÃO (ANGOLA)
-- Conformidade: Decreto Presidencial nº 312/18 (AGT) & PGC Angola
-- Base de Dados Oficial Definitiva para XAMPP (MySQL 8.0 / MariaDB)
-- Versão 3.0 - Arquitetura Empresarial Transacional Completa
-- Cobrindo todos os Domínios (Segurança, Comercial, Stock, Vendas, 
-- Compras, Faturação, Financeiro, Contabilidade, Fiscal, RH, Ativos e Auditoria)
-- ====================================================================

CREATE DATABASE IF NOT EXISTS `erp_angola` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `erp_angola`;

SET FOREIGN_KEY_CHECKS = 0;

-- ====================================================================
-- DOMÍNIO 1: ORGANIZAÇÃO & CONFIGURAÇÕES
-- ====================================================================

DROP TABLE IF EXISTS `erp_system_settings`;
CREATE TABLE `erp_system_settings` (
  `id` VARCHAR(50) NOT NULL PRIMARY KEY,
  `environment` ENUM('production', 'sandbox', 'demo') NOT NULL DEFAULT 'sandbox',
  `agt_cert_number` VARCHAR(50) NOT NULL DEFAULT '245/AGT/2024',
  `agt_software_name` VARCHAR(100) NOT NULL DEFAULT 'ANGOLA-ERP-ENTERPRISE',
  `agt_software_version` VARCHAR(20) NOT NULL DEFAULT '3.0.0',
  `agt_validation_url` VARCHAR(255) DEFAULT 'https://agt.minfin.gov.ao/ws/faturacao/v1',
  `contingency_mode` BOOLEAN NOT NULL DEFAULT FALSE,
  `saft_version` VARCHAR(20) NOT NULL DEFAULT '1.01_01',
  `auto_backup_enabled` BOOLEAN NOT NULL DEFAULT TRUE,
  `backup_retention_days` INT NOT NULL DEFAULT 30,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_companies`;
CREATE TABLE `erp_companies` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `nif` VARCHAR(20) NOT NULL UNIQUE,
  `name` VARCHAR(255) NOT NULL,
  `trade_name` VARCHAR(255) NULL,
  `address` TEXT NOT NULL,
  `city` VARCHAR(100) NOT NULL,
  `province` VARCHAR(100) NOT NULL,
  `postal_code` VARCHAR(20) DEFAULT '0000',
  `country` VARCHAR(50) DEFAULT 'AO',
  `phone` VARCHAR(50) NULL,
  `email` VARCHAR(100) NULL,
  `website` VARCHAR(150) NULL,
  `capital_social` DECIMAL(15,2) DEFAULT 10000000.00,
  `regime_fiscal` ENUM('Geral', 'Simplificado', 'Exclusao') NOT NULL DEFAULT 'Geral',
  `cert_number_agt` VARCHAR(50) NOT NULL DEFAULT '245/AGT/2024',
  `iban_principal` VARCHAR(50) NULL,
  `currency` VARCHAR(10) DEFAULT 'AOA',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_branches`;
CREATE TABLE `erp_branches` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `code` VARCHAR(20) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `address` TEXT NOT NULL,
  `city` VARCHAR(100) NOT NULL DEFAULT 'Luanda',
  `phone` VARCHAR(50) NULL,
  `email` VARCHAR(100) NULL,
  `is_headquarters` BOOLEAN NOT NULL DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_branch_code` (`company_id`, `code`),
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_company_settings`;
CREATE TABLE `erp_company_settings` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL UNIQUE,
  `default_currency` VARCHAR(10) NOT NULL DEFAULT 'AOA',
  `default_retention_rate` DECIMAL(5,2) NOT NULL DEFAULT 6.50,
  `default_print_copies` INT NOT NULL DEFAULT 2,
  `thermal_printer_enabled` BOOLEAN NOT NULL DEFAULT FALSE,
  `legal_disclaimer` TEXT NULL,
  `smtp_host` VARCHAR(150) NULL,
  `smtp_port` INT NULL,
  `smtp_user` VARCHAR(100) NULL,
  `smtp_secure` ENUM('tls', 'ssl', 'none') DEFAULT 'tls',
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_branch_settings`;
CREATE TABLE `erp_branch_settings` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `branch_id` VARCHAR(36) NOT NULL UNIQUE,
  `default_warehouse_id` VARCHAR(36) NULL,
  `default_cash_register_id` VARCHAR(36) NULL,
  `receipt_footer_message` VARCHAR(255) NULL,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`branch_id`) REFERENCES `erp_branches` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_bank_accounts`;
CREATE TABLE `erp_bank_accounts` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `branch_id` VARCHAR(36) NULL,
  `bank_name` VARCHAR(100) NOT NULL,
  `account_number` VARCHAR(50) NOT NULL,
  `iban` VARCHAR(50) NOT NULL UNIQUE,
  `swift` VARCHAR(30) NULL,
  `balance` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `currency` VARCHAR(10) NOT NULL DEFAULT 'AOA',
  `status` ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- DOMÍNIO 2: SEGURANÇA, UTILIZADORES, ROLES & PERMISSÕES (RBAC)
-- ====================================================================

DROP TABLE IF EXISTS `erp_users`;
CREATE TABLE `erp_users` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `branch_id` VARCHAR(36) NULL,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `phone` VARCHAR(50) NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `two_factor_secret` VARCHAR(100) NULL,
  `two_factor_enabled` BOOLEAN NOT NULL DEFAULT FALSE,
  `role` ENUM('admin', 'financeiro', 'contabilista', 'comercial', 'armazem', 'rh', 'auditor') NOT NULL DEFAULT 'comercial',
  `permissions` JSON NOT NULL,
  `status` ENUM('active', 'inactive', 'locked') NOT NULL DEFAULT 'active',
  `failed_attempts` INT NOT NULL DEFAULT 0,
  `last_login_at` DATETIME NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_roles`;
CREATE TABLE `erp_roles` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `code` VARCHAR(50) NOT NULL UNIQUE,
  `name` VARCHAR(100) NOT NULL,
  `description` TEXT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_permissions`;
CREATE TABLE `erp_permissions` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `code` VARCHAR(100) NOT NULL UNIQUE,
  `name` VARCHAR(100) NOT NULL,
  `module` VARCHAR(50) NOT NULL,
  `action` ENUM('VIEW', 'CREATE', 'UPDATE', 'DELETE', 'APPROVE', 'ISSUE', 'CANCEL', 'PAY', 'RECEIVE', 'EXPORT', 'PRINT', 'CLOSE_PERIOD', 'CONFIGURE', 'ADMIN') NOT NULL,
  `description` TEXT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_user_roles`;
CREATE TABLE `erp_user_roles` (
  `user_id` VARCHAR(36) NOT NULL,
  `role_id` VARCHAR(36) NOT NULL,
  PRIMARY KEY (`user_id`, `role_id`),
  FOREIGN KEY (`user_id`) REFERENCES `erp_users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`role_id`) REFERENCES `erp_roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_role_permissions`;
CREATE TABLE `erp_role_permissions` (
  `role_id` VARCHAR(36) NOT NULL,
  `permission_id` VARCHAR(36) NOT NULL,
  PRIMARY KEY (`role_id`, `permission_id`),
  FOREIGN KEY (`role_id`) REFERENCES `erp_roles` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`permission_id`) REFERENCES `erp_permissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_user_company_access`;
CREATE TABLE `erp_user_company_access` (
  `user_id` VARCHAR(36) NOT NULL,
  `company_id` VARCHAR(36) NOT NULL,
  `can_manage` BOOLEAN NOT NULL DEFAULT FALSE,
  PRIMARY KEY (`user_id`, `company_id`),
  FOREIGN KEY (`user_id`) REFERENCES `erp_users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_user_branch_access`;
CREATE TABLE `erp_user_branch_access` (
  `user_id` VARCHAR(36) NOT NULL,
  `branch_id` VARCHAR(36) NOT NULL,
  PRIMARY KEY (`user_id`, `branch_id`),
  FOREIGN KEY (`user_id`) REFERENCES `erp_users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`branch_id`) REFERENCES `erp_branches` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_sessions`;
CREATE TABLE `erp_sessions` (
  `id` VARCHAR(64) NOT NULL PRIMARY KEY,
  `user_id` VARCHAR(36) NOT NULL,
  `token_hash` VARCHAR(64) NOT NULL UNIQUE,
  `ip_address` VARCHAR(45) NOT NULL,
  `user_agent` TEXT NULL,
  `expires_at` DATETIME NOT NULL,
  `revoked_at` DATETIME NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_sessions_user` (`user_id`),
  INDEX `idx_sessions_token` (`token_hash`),
  FOREIGN KEY (`user_id`) REFERENCES `erp_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_login_attempts`;
CREATE TABLE `erp_login_attempts` (
  `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
  `ip_address` VARCHAR(45) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `success` BOOLEAN NOT NULL DEFAULT FALSE,
  `user_agent` TEXT NULL,
  `attempt_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_login_ip_email` (`ip_address`, `email`, `attempt_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_password_reset_tokens`;
CREATE TABLE `erp_password_reset_tokens` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `user_id` VARCHAR(36) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `token_hash` VARCHAR(64) NOT NULL UNIQUE,
  `expires_at` DATETIME NOT NULL,
  `used` BOOLEAN NOT NULL DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `erp_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- DOMÍNIO 3: CLIENTES, FORNECEDORES & PARCEIROS DE NEGÓCIO
-- ====================================================================

DROP TABLE IF EXISTS `erp_payment_terms`;
CREATE TABLE `erp_payment_terms` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `code` VARCHAR(30) NOT NULL UNIQUE,
  `name` VARCHAR(100) NOT NULL,
  `days` INT NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_payment_methods`;
CREATE TABLE `erp_payment_methods` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `code` VARCHAR(20) NOT NULL UNIQUE,
  `name` VARCHAR(100) NOT NULL,
  `requires_bank` BOOLEAN NOT NULL DEFAULT FALSE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_price_lists`;
CREATE TABLE `erp_price_lists` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `code` VARCHAR(50) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `currency` VARCHAR(10) NOT NULL DEFAULT 'AOA',
  `is_default` BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE KEY `uk_company_price_list` (`company_id`, `code`),
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_third_parties`;
CREATE TABLE `erp_third_parties` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `type` ENUM('customer', 'supplier', 'both') NOT NULL DEFAULT 'customer',
  `nif` VARCHAR(20) NOT NULL,
  `code` VARCHAR(50) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `trade_name` VARCHAR(255) NULL,
  `email` VARCHAR(100) NULL,
  `phone` VARCHAR(50) NULL,
  `address` TEXT NOT NULL,
  `city` VARCHAR(100) NOT NULL,
  `province` VARCHAR(100) NOT NULL,
  `country` VARCHAR(50) DEFAULT 'AO',
  `credit_limit` DECIMAL(15,2) DEFAULT 0.00,
  `payment_terms_id` VARCHAR(36) NULL,
  `tax_regime` ENUM('Geral', 'Simplificado', 'Exclusao') DEFAULT 'Geral',
  `has_withholding_exemption` BOOLEAN DEFAULT FALSE,
  `accounting_account` VARCHAR(20) DEFAULT '31.1',
  `status` ENUM('active', 'inactive', 'blocked') DEFAULT 'active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_tp_company_nif` (`company_id`, `nif`),
  INDEX `idx_thirdparty_nif` (`nif`),
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_contacts`;
CREATE TABLE `erp_contacts` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `third_party_id` VARCHAR(36) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `role` VARCHAR(100) NULL,
  `email` VARCHAR(100) NULL,
  `phone` VARCHAR(50) NULL,
  `is_primary` BOOLEAN NOT NULL DEFAULT FALSE,
  FOREIGN KEY (`third_party_id`) REFERENCES `erp_third_parties` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_addresses`;
CREATE TABLE `erp_addresses` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `third_party_id` VARCHAR(36) NOT NULL,
  `type` ENUM('fiscal', 'delivery', 'billing') NOT NULL DEFAULT 'fiscal',
  `address` TEXT NOT NULL,
  `city` VARCHAR(100) NOT NULL,
  `province` VARCHAR(100) NOT NULL,
  `is_primary` BOOLEAN NOT NULL DEFAULT FALSE,
  FOREIGN KEY (`third_party_id`) REFERENCES `erp_third_parties` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- DOMÍNIO 4: PRODUTOS, SERVIÇOS & TABELAS DE PREÇO
-- ====================================================================

DROP TABLE IF EXISTS `erp_categories`;
CREATE TABLE `erp_categories` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `code` VARCHAR(50) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `parent_id` VARCHAR(36) NULL,
  UNIQUE KEY `uk_category_company_code` (`company_id`, `code`),
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_brands`;
CREATE TABLE `erp_brands` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  UNIQUE KEY `uk_brand_company_name` (`company_id`, `name`),
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_units`;
CREATE TABLE `erp_units` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `code` VARCHAR(10) NOT NULL UNIQUE,
  `name` VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_products`;
CREATE TABLE `erp_products` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `code` VARCHAR(50) NOT NULL,
  `barcode` VARCHAR(50) NULL,
  `description` VARCHAR(255) NOT NULL,
  `category_id` VARCHAR(36) NULL,
  `brand_id` VARCHAR(36) NULL,
  `unit_id` VARCHAR(36) NULL,
  `unit` VARCHAR(10) NOT NULL DEFAULT 'UN',
  `is_service` BOOLEAN NOT NULL DEFAULT FALSE,
  `cost_price` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `sale_price` DECIMAL(15,2) NOT NULL,
  `tax_code` VARCHAR(20) NOT NULL DEFAULT 'IVA14',
  `tax_rate` DECIMAL(5,2) NOT NULL DEFAULT 14.00,
  `exemption_reason_code` VARCHAR(10) NULL,
  `min_stock` DECIMAL(12,2) DEFAULT 0.00,
  `max_stock` DECIMAL(12,2) DEFAULT 0.00,
  `default_warehouse_id` VARCHAR(36) NULL,
  `accounting_sales_account` VARCHAR(20) DEFAULT '71.1',
  `accounting_inventory_account` VARCHAR(20) DEFAULT '26',
  `accounting_cost_account` VARCHAR(20) DEFAULT '61',
  `status` ENUM('active', 'inactive') DEFAULT 'active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_prod_company_code` (`company_id`, `code`),
  INDEX `idx_product_barcode` (`barcode`),
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_product_prices`;
CREATE TABLE `erp_product_prices` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `price_list_id` VARCHAR(36) NOT NULL,
  `product_id` VARCHAR(36) NOT NULL,
  `price` DECIMAL(15,2) NOT NULL,
  UNIQUE KEY `uk_price_list_prod` (`price_list_id`, `product_id`),
  FOREIGN KEY (`price_list_id`) REFERENCES `erp_price_lists` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`product_id`) REFERENCES `erp_products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_barcodes`;
CREATE TABLE `erp_barcodes` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `product_id` VARCHAR(36) NOT NULL,
  `barcode` VARCHAR(50) NOT NULL UNIQUE,
  FOREIGN KEY (`product_id`) REFERENCES `erp_products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- DOMÍNIO 5: ARMAZÉNS, STOCK & KARDEX (Ponto 9)
-- ====================================================================

DROP TABLE IF EXISTS `erp_warehouses`;
CREATE TABLE `erp_warehouses` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `branch_id` VARCHAR(36) NOT NULL,
  `code` VARCHAR(20) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `location` VARCHAR(255) NOT NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_wh_branch_code` (`branch_id`, `code`),
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`branch_id`) REFERENCES `erp_branches` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_warehouse_locations`;
CREATE TABLE `erp_warehouse_locations` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `warehouse_id` VARCHAR(36) NOT NULL,
  `aisle` VARCHAR(20) NOT NULL,
  `rack` VARCHAR(20) NOT NULL,
  `shelf` VARCHAR(20) NOT NULL,
  `code` VARCHAR(50) NOT NULL,
  FOREIGN KEY (`warehouse_id`) REFERENCES `erp_warehouses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_lots`;
CREATE TABLE `erp_lots` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `product_id` VARCHAR(36) NOT NULL,
  `lot_number` VARCHAR(50) NOT NULL,
  `manufacture_date` DATE NULL,
  `expiry_date` DATE NULL,
  UNIQUE KEY `uk_prod_lot` (`product_id`, `lot_number`),
  FOREIGN KEY (`product_id`) REFERENCES `erp_products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_serial_numbers`;
CREATE TABLE `erp_serial_numbers` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `product_id` VARCHAR(36) NOT NULL,
  `serial_number` VARCHAR(100) NOT NULL UNIQUE,
  `status` ENUM('in_stock', 'sold', 'transferred', 'returned') NOT NULL DEFAULT 'in_stock',
  FOREIGN KEY (`product_id`) REFERENCES `erp_products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_stock_balances`;
CREATE TABLE `erp_stock_balances` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `warehouse_id` VARCHAR(36) NOT NULL,
  `product_id` VARCHAR(36) NOT NULL,
  `quantity` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `average_cost` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_wh_product_bal` (`warehouse_id`, `product_id`),
  FOREIGN KEY (`warehouse_id`) REFERENCES `erp_warehouses` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`product_id`) REFERENCES `erp_products` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela Stock Movements com TODAS as colunas solicitadas no Ponto 9
DROP TABLE IF EXISTS `erp_stock_movements`;
CREATE TABLE `erp_stock_movements` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `branch_id` VARCHAR(36) NOT NULL,
  `warehouse_id` VARCHAR(36) NOT NULL,
  `product_id` VARCHAR(36) NOT NULL,
  `type` ENUM('entrada', 'saida', 'transferencia', 'ajuste', 'inventario', 'devolucao') NOT NULL,
  `quantity` DECIMAL(12,2) NOT NULL,
  `unit_cost` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `total_cost` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `source_type` VARCHAR(50) NOT NULL,
  `source_id` VARCHAR(50) NOT NULL,
  `source_line_id` VARCHAR(50) NULL,
  `lot_id` VARCHAR(36) NULL,
  `serial_number_id` VARCHAR(36) NULL,
  `movement_date` DATE NOT NULL,
  `user_id` VARCHAR(50) NOT NULL,
  `reason` VARCHAR(255) NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_stock_wh_prod` (`warehouse_id`, `product_id`),
  INDEX `idx_stock_date` (`movement_date`),
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`warehouse_id`) REFERENCES `erp_warehouses` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`product_id`) REFERENCES `erp_products` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_stock_adjustments`;
CREATE TABLE `erp_stock_adjustments` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `warehouse_id` VARCHAR(36) NOT NULL,
  `product_id` VARCHAR(36) NOT NULL,
  `quantity_diff` DECIMAL(12,2) NOT NULL,
  `reason` VARCHAR(255) NOT NULL,
  `user_id` VARCHAR(36) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`warehouse_id`) REFERENCES `erp_warehouses` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`product_id`) REFERENCES `erp_products` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_stock_transfers`;
CREATE TABLE `erp_stock_transfers` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `source_warehouse_id` VARCHAR(36) NOT NULL,
  `destination_warehouse_id` VARCHAR(36) NOT NULL,
  `status` ENUM('draft', 'in_transit', 'completed', 'cancelled') NOT NULL DEFAULT 'draft',
  `reference_doc` VARCHAR(50) NULL,
  `user_id` VARCHAR(36) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`source_warehouse_id`) REFERENCES `erp_warehouses` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`destination_warehouse_id`) REFERENCES `erp_warehouses` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_stock_transfer_lines`;
CREATE TABLE `erp_stock_transfer_lines` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `transfer_id` VARCHAR(36) NOT NULL,
  `product_id` VARCHAR(36) NOT NULL,
  `quantity` DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (`transfer_id`) REFERENCES `erp_stock_transfers` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`product_id`) REFERENCES `erp_products` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- DOMÍNIO 6: MOTOR FISCAL & REGRAS DE TRIBUTAÇÃO (Ponto 14)
-- ====================================================================

DROP TABLE IF EXISTS `erp_fiscal_regimes`;
CREATE TABLE `erp_fiscal_regimes` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `code` VARCHAR(20) NOT NULL UNIQUE,
  `name` VARCHAR(100) NOT NULL,
  `iva_rate` DECIMAL(5,2) NOT NULL DEFAULT 14.00,
  `requires_saft` BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_exemption_codes`;
CREATE TABLE `erp_exemption_codes` (
  `code` VARCHAR(10) NOT NULL PRIMARY KEY,
  `description` VARCHAR(255) NOT NULL,
  `legal_basis` TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_fiscal_tax_rates`;
CREATE TABLE `erp_fiscal_tax_rates` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `code` VARCHAR(20) NOT NULL UNIQUE,
  `name` VARCHAR(100) NOT NULL,
  `tax_type` ENUM('IVA', 'IS', 'RET') NOT NULL DEFAULT 'IVA',
  `rate_percent` DECIMAL(5,2) NOT NULL,
  `is_exemption` BOOLEAN NOT NULL DEFAULT FALSE,
  `exemption_reason_code` VARCHAR(10) NULL,
  `legal_basis` TEXT NULL,
  `valid_from` DATE NOT NULL DEFAULT '2020-01-01',
  `valid_to` DATE NULL,
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_tax_rules`;
CREATE TABLE `erp_tax_rules` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `product_type` ENUM('physical', 'service', 'all') NOT NULL DEFAULT 'all',
  `tax_code` VARCHAR(20) NOT NULL,
  `priority` INT NOT NULL DEFAULT 1,
  `effective_from` DATE NOT NULL,
  `effective_to` DATE NULL,
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_withholding_rules`;
CREATE TABLE `erp_withholding_rules` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `service_type` VARCHAR(100) NOT NULL,
  `rate_percent` DECIMAL(5,2) NOT NULL DEFAULT 6.50,
  `legal_basis` VARCHAR(255) NOT NULL DEFAULT 'Lei nº 19/14 do Código Geral Tributário'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- DOMÍNIO 7: FATURAÇÃO, SÉRIES & SEQUÊNCIAS (Pontos 12, 13, 16)
-- ====================================================================

DROP TABLE IF EXISTS `erp_document_series`;
CREATE TABLE `erp_document_series` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `branch_id` VARCHAR(36) NOT NULL,
  `series_code` VARCHAR(10) NOT NULL,
  `year` INT NOT NULL,
  `description` VARCHAR(100) NOT NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_series_year` (`company_id`, `branch_id`, `series_code`, `year`),
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`branch_id`) REFERENCES `erp_branches` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_document_sequences`;
CREATE TABLE `erp_document_sequences` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `branch_id` VARCHAR(36) NOT NULL,
  `document_type` ENUM('FT', 'FR', 'FS', 'FP', 'RC', 'NC', 'ND', 'GR', 'GT', 'NE') NOT NULL,
  `series_id` VARCHAR(36) NOT NULL,
  `series_code` VARCHAR(10) NOT NULL,
  `year` INT NOT NULL,
  `current_number` INT NOT NULL DEFAULT 0,
  `last_hash` VARCHAR(255) NULL,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_doc_sequence` (`company_id`, `branch_id`, `document_type`, `series_id`),
  FOREIGN KEY (`series_id`) REFERENCES `erp_document_series` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_documents`;
CREATE TABLE `erp_documents` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `branch_id` VARCHAR(36) NOT NULL,
  `type` ENUM('FT', 'FR', 'FS', 'FP', 'RC', 'NC', 'ND', 'GR', 'GT') NOT NULL,
  `series_id` VARCHAR(36) NOT NULL,
  `series_code` VARCHAR(10) NOT NULL,
  `series` VARCHAR(10) GENERATED ALWAYS AS (`series_code`) STORED,
  `document_number` VARCHAR(50) NOT NULL,
  `sequence_number` INT NOT NULL,
  `system_entry_date` DATETIME NOT NULL,
  `document_date` DATE NOT NULL,
  `due_date` DATE NOT NULL,
  `entity_id` VARCHAR(36) NOT NULL,
  `entity_nif` VARCHAR(20) NOT NULL,
  `entity_name` VARCHAR(255) NOT NULL,
  `entity_address` TEXT NOT NULL,
  `currency` VARCHAR(10) DEFAULT 'AOA',
  `exchange_rate` DECIMAL(10,4) DEFAULT 1.0000,
  `total_net` DECIMAL(15,2) NOT NULL,
  `total_discount` DECIMAL(15,2) DEFAULT 0.00,
  `total_tax` DECIMAL(15,2) NOT NULL,
  `total_retention` DECIMAL(15,2) DEFAULT 0.00,
  `total_gross` DECIMAL(15,2) NOT NULL,
  `status` ENUM('draft', 'validated', 'issued', 'liquidated', 'partially_paid', 'cancelled') NOT NULL DEFAULT 'issued',
  `payment_method` VARCHAR(50) DEFAULT 'Transferencia',
  `hash` VARCHAR(255) NOT NULL,
  `hash_control` VARCHAR(50) NOT NULL,
  `previous_hash` VARCHAR(255) NULL,
  `signature_algorithm` VARCHAR(50) NOT NULL DEFAULT 'SHA1withRSA',
  `agt_certificate_number` VARCHAR(50) NOT NULL DEFAULT '245/AGT/2024',
  `qr_code_payload` TEXT NOT NULL,
  `agt_status` ENUM('pending', 'submitted', 'accepted', 'rejected', 'contingency') DEFAULT 'contingency',
  `agt_protocol` VARCHAR(100) NULL,
  `cancellation_reason` VARCHAR(255) NULL,
  `cancelled_at` DATETIME NULL,
  `cancelled_by_user_id` VARCHAR(36) NULL,
  `created_by_user_id` VARCHAR(36) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_company_doc_number` (`company_id`, `document_number`),
  UNIQUE KEY `uk_doc_seq` (`company_id`, `type`, `series`, `sequence_number`),
  INDEX `idx_doc_date` (`document_date`),
  INDEX `idx_doc_entity` (`entity_nif`),
  INDEX `idx_doc_hash` (`hash_control`),
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`branch_id`) REFERENCES `erp_branches` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`series_id`) REFERENCES `erp_document_series` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_document_lines`;
CREATE TABLE `erp_document_lines` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `document_id` VARCHAR(36) NOT NULL,
  `line_number` INT NOT NULL,
  `product_id` VARCHAR(36) NOT NULL,
  `product_code` VARCHAR(50) NOT NULL,
  `description` VARCHAR(255) NOT NULL,
  `quantity` DECIMAL(12,2) NOT NULL,
  `unit` VARCHAR(10) NOT NULL DEFAULT 'UN',
  `unit_price` DECIMAL(15,2) NOT NULL,
  `discount_percent` DECIMAL(5,2) DEFAULT 0.00,
  `discount_amount` DECIMAL(15,2) DEFAULT 0.00,
  `tax_rate` DECIMAL(5,2) NOT NULL,
  `tax_code` VARCHAR(20) NOT NULL,
  `tax_amount` DECIMAL(15,2) NOT NULL,
  `exemption_reason_code` VARCHAR(10) NULL,
  `total_line` DECIMAL(15,2) NOT NULL,
  UNIQUE KEY `uk_doc_line_num` (`document_id`, `line_number`),
  FOREIGN KEY (`document_id`) REFERENCES `erp_documents` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`product_id`) REFERENCES `erp_products` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_payments`;
CREATE TABLE `erp_payments` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `document_id` VARCHAR(36) NOT NULL,
  `payment_method_id` VARCHAR(36) NOT NULL,
  `payment_date` DATE NOT NULL,
  `amount` DECIMAL(15,2) NOT NULL,
  `bank_account_id` VARCHAR(36) NULL,
  `cash_register_id` VARCHAR(36) NULL,
  `transaction_reference` VARCHAR(100) NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`document_id`) REFERENCES `erp_documents` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_receipts_issued`;
CREATE TABLE `erp_receipts_issued` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `receipt_number` VARCHAR(50) NOT NULL UNIQUE,
  `invoice_id` VARCHAR(36) NOT NULL,
  `customer_id` VARCHAR(36) NOT NULL,
  `amount_paid` DECIMAL(15,2) NOT NULL,
  `receipt_date` DATE NOT NULL,
  `hash` VARCHAR(255) NOT NULL,
  `hash_control` VARCHAR(50) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`invoice_id`) REFERENCES `erp_documents` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_credit_notes`;
CREATE TABLE `erp_credit_notes` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `document_id` VARCHAR(36) NOT NULL UNIQUE,
  `original_document_id` VARCHAR(36) NOT NULL,
  `reason` VARCHAR(255) NOT NULL,
  FOREIGN KEY (`document_id`) REFERENCES `erp_documents` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`original_document_id`) REFERENCES `erp_documents` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_debit_notes`;
CREATE TABLE `erp_debit_notes` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `document_id` VARCHAR(36) NOT NULL UNIQUE,
  `original_document_id` VARCHAR(36) NOT NULL,
  `reason` VARCHAR(255) NOT NULL,
  FOREIGN KEY (`document_id`) REFERENCES `erp_documents` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`original_document_id`) REFERENCES `erp_documents` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- DOMÍNIO 8: VENDAS (Encomendas, Orçamentos, Guias) - Ponto 11
-- ====================================================================

DROP TABLE IF EXISTS `erp_sales_orders`;
CREATE TABLE `erp_sales_orders` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `branch_id` VARCHAR(36) NOT NULL,
  `order_number` VARCHAR(50) NOT NULL UNIQUE,
  `order_type` ENUM('quote', 'order') NOT NULL DEFAULT 'order',
  `customer_id` VARCHAR(36) NOT NULL,
  `order_date` DATE NOT NULL,
  `expected_delivery_date` DATE NULL,
  `total_amount` DECIMAL(15,2) NOT NULL,
  `status` ENUM('draft', 'approved', 'delivered', 'invoiced', 'cancelled') NOT NULL DEFAULT 'draft',
  `approved_by_user_id` VARCHAR(36) NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`customer_id`) REFERENCES `erp_third_parties` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_sales_order_lines`;
CREATE TABLE `erp_sales_order_lines` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `order_id` VARCHAR(36) NOT NULL,
  `product_id` VARCHAR(36) NOT NULL,
  `quantity` DECIMAL(12,2) NOT NULL,
  `unit_price` DECIMAL(15,2) NOT NULL,
  `tax_rate` DECIMAL(5,2) NOT NULL,
  `total_line` DECIMAL(15,2) NOT NULL,
  FOREIGN KEY (`order_id`) REFERENCES `erp_sales_orders` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`product_id`) REFERENCES `erp_products` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_delivery_notes`;
CREATE TABLE `erp_delivery_notes` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `delivery_number` VARCHAR(50) NOT NULL UNIQUE,
  `sales_order_id` VARCHAR(36) NULL,
  `document_id` VARCHAR(36) NULL,
  `customer_id` VARCHAR(36) NOT NULL,
  `delivery_date` DATE NOT NULL,
  `status` ENUM('prepared', 'shipped', 'delivered', 'returned') NOT NULL DEFAULT 'prepared',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`customer_id`) REFERENCES `erp_third_parties` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_delivery_note_lines`;
CREATE TABLE `erp_delivery_note_lines` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `delivery_note_id` VARCHAR(36) NOT NULL,
  `product_id` VARCHAR(36) NOT NULL,
  `quantity` DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (`delivery_note_id`) REFERENCES `erp_delivery_notes` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`product_id`) REFERENCES `erp_products` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- DOMÍNIO 9: COMPRAS & FORNECEDORES - Ponto 10
-- ====================================================================

DROP TABLE IF EXISTS `erp_purchase_orders`;
CREATE TABLE `erp_purchase_orders` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `branch_id` VARCHAR(36) NOT NULL,
  `order_number` VARCHAR(50) NOT NULL UNIQUE,
  `supplier_id` VARCHAR(36) NOT NULL,
  `order_date` DATE NOT NULL,
  `expected_date` DATE NULL,
  `total_amount` DECIMAL(15,2) NOT NULL,
  `status` ENUM('draft', 'approved', 'received', 'invoiced', 'cancelled') NOT NULL DEFAULT 'draft',
  `approved_by_user_id` VARCHAR(36) NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`supplier_id`) REFERENCES `erp_third_parties` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_purchase_order_lines`;
CREATE TABLE `erp_purchase_order_lines` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `order_id` VARCHAR(36) NOT NULL,
  `product_id` VARCHAR(36) NOT NULL,
  `quantity` DECIMAL(12,2) NOT NULL,
  `unit_cost` DECIMAL(15,2) NOT NULL,
  `tax_rate` DECIMAL(5,2) NOT NULL,
  `total_line` DECIMAL(15,2) NOT NULL,
  FOREIGN KEY (`order_id`) REFERENCES `erp_purchase_orders` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`product_id`) REFERENCES `erp_products` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_receipts`;
CREATE TABLE `erp_receipts` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `receipt_number` VARCHAR(50) NOT NULL UNIQUE,
  `purchase_order_id` VARCHAR(36) NULL,
  `supplier_id` VARCHAR(36) NOT NULL,
  `warehouse_id` VARCHAR(36) NOT NULL,
  `reception_date` DATE NOT NULL,
  `delivery_note_ref` VARCHAR(50) NULL,
  `status` ENUM('draft', 'received', 'verified') NOT NULL DEFAULT 'received',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`supplier_id`) REFERENCES `erp_third_parties` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`warehouse_id`) REFERENCES `erp_warehouses` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_receipt_lines`;
CREATE TABLE `erp_receipt_lines` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `receipt_id` VARCHAR(36) NOT NULL,
  `product_id` VARCHAR(36) NOT NULL,
  `quantity_received` DECIMAL(12,2) NOT NULL,
  `unit_cost` DECIMAL(15,2) NOT NULL,
  FOREIGN KEY (`receipt_id`) REFERENCES `erp_receipts` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`product_id`) REFERENCES `erp_products` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_supplier_invoices`;
CREATE TABLE `erp_supplier_invoices` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `branch_id` VARCHAR(36) NOT NULL,
  `supplier_id` VARCHAR(36) NOT NULL,
  `invoice_number` VARCHAR(50) NOT NULL,
  `invoice_date` DATE NOT NULL,
  `due_date` DATE NOT NULL,
  `total_net` DECIMAL(15,2) NOT NULL,
  `total_tax` DECIMAL(15,2) NOT NULL,
  `total_retention` DECIMAL(15,2) DEFAULT 0.00,
  `total_gross` DECIMAL(15,2) NOT NULL,
  `paid_amount` DECIMAL(15,2) DEFAULT 0.00,
  `balance` DECIMAL(15,2) NOT NULL,
  `status` ENUM('pending', 'partially_paid', 'paid', 'cancelled') NOT NULL DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_supp_inv` (`company_id`, `supplier_id`, `invoice_number`),
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`supplier_id`) REFERENCES `erp_third_parties` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_supplier_invoice_lines`;
CREATE TABLE `erp_supplier_invoice_lines` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `invoice_id` VARCHAR(36) NOT NULL,
  `product_id` VARCHAR(36) NOT NULL,
  `quantity` DECIMAL(12,2) NOT NULL,
  `unit_cost` DECIMAL(15,2) NOT NULL,
  `tax_rate` DECIMAL(5,2) NOT NULL,
  `total_line` DECIMAL(15,2) NOT NULL,
  FOREIGN KEY (`invoice_id`) REFERENCES `erp_supplier_invoices` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`product_id`) REFERENCES `erp_products` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_purchases`;
CREATE TABLE `erp_purchases` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `branch_id` VARCHAR(36) NOT NULL,
  `supplier_id` VARCHAR(36) NOT NULL,
  `purchase_number` VARCHAR(50) NOT NULL,
  `purchase_date` DATE NOT NULL,
  `total_net` DECIMAL(15,2) NOT NULL,
  `total_tax` DECIMAL(15,2) NOT NULL,
  `total_gross` DECIMAL(15,2) NOT NULL,
  `status` ENUM('pending', 'approved', 'paid', 'cancelled') NOT NULL DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`supplier_id`) REFERENCES `erp_third_parties` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- DOMÍNIO 10: TESOURARIA, CAIXA & BANCOS - Ponto 17
-- ====================================================================

DROP TABLE IF EXISTS `erp_cash_accounts`;
CREATE TABLE `erp_cash_accounts` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `branch_id` VARCHAR(36) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `initial_balance` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `current_balance` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `currency` VARCHAR(10) NOT NULL DEFAULT 'AOA',
  `status` ENUM('open', 'closed') NOT NULL DEFAULT 'open',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`branch_id`) REFERENCES `erp_branches` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_cash_sessions`;
CREATE TABLE `erp_cash_sessions` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `cash_account_id` VARCHAR(36) NOT NULL,
  `user_id` VARCHAR(36) NOT NULL,
  `opened_at` DATETIME NOT NULL,
  `closed_at` DATETIME NULL,
  `opening_balance` DECIMAL(15,2) NOT NULL,
  `closing_system_balance` DECIMAL(15,2) NULL,
  `closing_declared_balance` DECIMAL(15,2) NULL,
  `cash_difference` DECIMAL(15,2) NULL,
  `status` ENUM('open', 'closed') NOT NULL DEFAULT 'open',
  FOREIGN KEY (`cash_account_id`) REFERENCES `erp_cash_accounts` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`user_id`) REFERENCES `erp_users` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_cash_movements`;
CREATE TABLE `erp_cash_movements` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `cash_account_id` VARCHAR(36) NOT NULL,
  `session_id` VARCHAR(36) NULL,
  `user_id` VARCHAR(36) NOT NULL,
  `type` ENUM('entry', 'exit', 'sangria', 'reforco') NOT NULL,
  `amount` DECIMAL(15,2) NOT NULL,
  `description` VARCHAR(255) NOT NULL,
  `document_ref` VARCHAR(50) NULL,
  `movement_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`cash_account_id`) REFERENCES `erp_cash_accounts` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_bank_transactions`;
CREATE TABLE `erp_bank_transactions` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `bank_account_id` VARCHAR(36) NOT NULL,
  `date` DATE NOT NULL,
  `type` ENUM('deposit', 'withdrawal', 'transfer', 'payment', 'receipt', 'charge') NOT NULL,
  `amount` DECIMAL(15,2) NOT NULL,
  `description` VARCHAR(255) NOT NULL,
  `document_ref` VARCHAR(50) NULL,
  `reconciled` BOOLEAN NOT NULL DEFAULT FALSE,
  `reconciliation_date` DATE NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`bank_account_id`) REFERENCES `erp_bank_accounts` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_financial_transactions`;
CREATE TABLE `erp_financial_transactions` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `branch_id` VARCHAR(36) NOT NULL,
  `account_type` ENUM('bank', 'cash') NOT NULL,
  `account_id` VARCHAR(36) NOT NULL,
  `type` ENUM('credit', 'debit') NOT NULL,
  `amount` DECIMAL(15,2) NOT NULL,
  `balance_after` DECIMAL(15,2) NOT NULL,
  `transaction_date` DATE NOT NULL,
  `description` VARCHAR(255) NOT NULL,
  `document_ref` VARCHAR(50) NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_receivables`;
CREATE TABLE `erp_receivables` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `customer_id` VARCHAR(36) NOT NULL,
  `document_id` VARCHAR(36) NOT NULL,
  `document_ref` VARCHAR(50) NOT NULL,
  `issue_date` DATE NOT NULL,
  `due_date` DATE NOT NULL,
  `total_amount` DECIMAL(15,2) NOT NULL,
  `paid_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `balance` DECIMAL(15,2) NOT NULL,
  `status` ENUM('pending', 'partially_paid', 'paid', 'overdue') NOT NULL DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`customer_id`) REFERENCES `erp_third_parties` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`document_id`) REFERENCES `erp_documents` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_payables`;
CREATE TABLE `erp_payables` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `supplier_id` VARCHAR(36) NOT NULL,
  `document_ref` VARCHAR(50) NOT NULL,
  `issue_date` DATE NOT NULL,
  `due_date` DATE NOT NULL,
  `total_amount` DECIMAL(15,2) NOT NULL,
  `paid_amount` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `balance` DECIMAL(15,2) NOT NULL,
  `status` ENUM('pending', 'partially_paid', 'paid', 'overdue') NOT NULL DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`supplier_id`) REFERENCES `erp_third_parties` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_reconciliations`;
CREATE TABLE `erp_reconciliations` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `bank_account_id` VARCHAR(36) NOT NULL,
  `statement_date` DATE NOT NULL,
  `statement_balance` DECIMAL(15,2) NOT NULL,
  `system_balance` DECIMAL(15,2) NOT NULL,
  `difference` DECIMAL(15,2) NOT NULL,
  `status` ENUM('balanced', 'unbalanced') NOT NULL,
  `reconciled_by_user_id` VARCHAR(36) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`bank_account_id`) REFERENCES `erp_bank_accounts` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- DOMÍNIO 11: CONTABILIDADE PGC & PERÍODOS (Pontos 18, 19)
-- ====================================================================

DROP TABLE IF EXISTS `erp_accounting_periods`;
CREATE TABLE `erp_accounting_periods` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `fiscal_year` INT NOT NULL,
  `period_month` INT NOT NULL,
  `period_name` VARCHAR(50) NOT NULL,
  `start_date` DATE NOT NULL,
  `end_date` DATE NOT NULL,
  `status` ENUM('OPEN', 'CLOSED') NOT NULL DEFAULT 'OPEN',
  `closed_at` DATETIME NULL,
  `closed_by_user_id` VARCHAR(36) NULL,
  `reopened_at` DATETIME NULL,
  `reopened_by_user_id` VARCHAR(36) NULL,
  `reopen_reason` VARCHAR(255) NULL,
  UNIQUE KEY `uk_period_comp_mth` (`company_id`, `fiscal_year`, `period_month`),
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_cost_centers`;
CREATE TABLE `erp_cost_centers` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `code` VARCHAR(50) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  UNIQUE KEY `uk_cc_company_code` (`company_id`, `code`),
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_journals`;
CREATE TABLE `erp_journals` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `code` VARCHAR(20) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `type` ENUM('Vendas', 'Compras', 'Caixa', 'Bancos', 'Operações Diversas', 'Salários') NOT NULL,
  UNIQUE KEY `uk_journal_code` (`company_id`, `code`),
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `pgc_accounts`;
CREATE TABLE `pgc_accounts` (
  `code` VARCHAR(20) NOT NULL PRIMARY KEY,
  `description` VARCHAR(255) NOT NULL,
  `class_code` INT NOT NULL,
  `nature` ENUM('debit', 'credit', 'mixed') NOT NULL,
  `is_movable` BOOLEAN DEFAULT TRUE,
  `parent_code` VARCHAR(20) NULL,
  INDEX idx_pgc_class (`class_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `pgc_journal_entries`;
CREATE TABLE `pgc_journal_entries` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `period_id` VARCHAR(36) NULL,
  `entry_number` INT NOT NULL,
  `date` DATE NOT NULL,
  `journal_type` ENUM('Vendas', 'Compras', 'Caixa', 'Bancos', 'Operações Diversas', 'Salários') NOT NULL,
  `document_ref` VARCHAR(50) NOT NULL,
  `description` VARCHAR(255) NOT NULL,
  `debit_total` DECIMAL(15,2) NOT NULL,
  `credit_total` DECIMAL(15,2) NOT NULL,
  `status` ENUM('draft', 'posted', 'reversed') NOT NULL DEFAULT 'posted',
  `cost_center_id` VARCHAR(36) NULL,
  `created_by_user_id` VARCHAR(36) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_je_date` (`date`),
  INDEX `idx_je_ref` (`document_ref`),
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `pgc_journal_entry_lines`;
CREATE TABLE `pgc_journal_entry_lines` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `entry_id` VARCHAR(36) NOT NULL,
  `account_code` VARCHAR(20) NOT NULL,
  `account_description` VARCHAR(255) NOT NULL,
  `description` VARCHAR(255) NOT NULL,
  `debit` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `credit` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `third_party_id` VARCHAR(36) NULL,
  FOREIGN KEY (`entry_id`) REFERENCES `pgc_journal_entries` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`account_code`) REFERENCES `pgc_accounts` (`code`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_accounting_mappings`;
CREATE TABLE `erp_accounting_mappings` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `event_type` VARCHAR(50) NOT NULL,
  `debit_account_code` VARCHAR(20) NOT NULL,
  `credit_account_code` VARCHAR(20) NOT NULL,
  `description` VARCHAR(255) NOT NULL,
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- DOMÍNIO 12: INTEGRAÇÃO AGT & COMUNICAÇÃO FISCAL (Ponto 15)
-- ====================================================================

DROP TABLE IF EXISTS `erp_digital_certificates`;
CREATE TABLE `erp_digital_certificates` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `certificate_number` VARCHAR(50) NOT NULL,
  `public_key` TEXT NOT NULL,
  `private_key_path` VARCHAR(255) NULL,
  `valid_from` DATE NOT NULL,
  `valid_to` DATE NOT NULL,
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_agt_submissions`;
CREATE TABLE `erp_agt_submissions` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `document_id` VARCHAR(36) NOT NULL,
  `environment` ENUM('production', 'sandbox') NOT NULL DEFAULT 'sandbox',
  `idempotency_key` VARCHAR(64) NOT NULL UNIQUE,
  `payload_xml` MEDIUMTEXT NOT NULL,
  `status` ENUM('queued', 'sending', 'accepted', 'rejected', 'timeout', 'contingency') NOT NULL DEFAULT 'queued',
  `attempt_count` INT NOT NULL DEFAULT 0,
  `last_attempt_at` DATETIME NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`document_id`) REFERENCES `erp_documents` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_agt_responses`;
CREATE TABLE `erp_agt_responses` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `submission_id` VARCHAR(36) NOT NULL,
  `protocol_number` VARCHAR(100) NULL,
  `status_code` VARCHAR(20) NOT NULL,
  `message` TEXT NOT NULL,
  `raw_response` MEDIUMTEXT NULL,
  `received_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`submission_id`) REFERENCES `erp_agt_submissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- DOMÍNIO 13: RECURSOS HUMANOS, PROCESSAMENTO SALARIAL & ATIVOS (Ponto 20)
-- ====================================================================

DROP TABLE IF EXISTS `erp_employees`;
CREATE TABLE `erp_employees` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `nif` VARCHAR(20) NOT NULL,
  `bi_number` VARCHAR(30) NOT NULL,
  `department` VARCHAR(100) NOT NULL,
  `role` VARCHAR(100) NOT NULL,
  `base_salary` DECIMAL(15,2) NOT NULL,
  `food_allowance` DECIMAL(15,2) DEFAULT 0.00,
  `transport_allowance` DECIMAL(15,2) DEFAULT 0.00,
  `dependents` INT DEFAULT 0,
  `hire_date` DATE NOT NULL,
  `iban` VARCHAR(50) NOT NULL,
  `status` ENUM('active', 'inactive') DEFAULT 'active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_contracts`;
CREATE TABLE `erp_contracts` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `employee_id` VARCHAR(36) NOT NULL,
  `contract_type` ENUM('determinado', 'indeterminado', 'estagio', 'prestacao') NOT NULL,
  `start_date` DATE NOT NULL,
  `end_date` DATE NULL,
  `gross_salary` DECIMAL(15,2) NOT NULL,
  FOREIGN KEY (`employee_id`) REFERENCES `erp_employees` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_payroll_runs`;
CREATE TABLE `erp_payroll_runs` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `employee_id` VARCHAR(36) NOT NULL,
  `employee_name` VARCHAR(100) NOT NULL,
  `month_year` VARCHAR(10) NOT NULL,
  `base_salary` DECIMAL(15,2) NOT NULL,
  `food_allowance` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `transport_allowance` DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  `gross_salary` DECIMAL(15,2) NOT NULL,
  `inss_worker` DECIMAL(15,2) NOT NULL,
  `inss_employer` DECIMAL(15,2) NOT NULL,
  `irt_taxable_base` DECIMAL(15,2) NOT NULL,
  `irt_amount` DECIMAL(15,2) NOT NULL,
  `total_deductions` DECIMAL(15,2) NOT NULL,
  `net_salary` DECIMAL(15,2) NOT NULL,
  `status` ENUM('draft', 'processed', 'paid') NOT NULL DEFAULT 'processed',
  `processed_date` DATE NOT NULL,
  `paid_at` DATETIME NULL,
  `bank_account_id` VARCHAR(36) NULL,
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT,
  FOREIGN KEY (`employee_id`) REFERENCES `erp_employees` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_payroll_lines`;
CREATE TABLE `erp_payroll_lines` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `payroll_run_id` VARCHAR(36) NOT NULL,
  `rubric_code` VARCHAR(20) NOT NULL,
  `rubric_name` VARCHAR(100) NOT NULL,
  `type` ENUM('vencimento', 'subsidio', 'desconto_inss', 'desconto_irt', 'outro') NOT NULL,
  `amount` DECIMAL(15,2) NOT NULL,
  FOREIGN KEY (`payroll_run_id`) REFERENCES `erp_payroll_runs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_fixed_assets`;
CREATE TABLE `erp_fixed_assets` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `company_id` VARCHAR(36) NOT NULL,
  `code` VARCHAR(50) NOT NULL,
  `description` VARCHAR(255) NOT NULL,
  `category` VARCHAR(100) NOT NULL,
  `location` VARCHAR(255) NOT NULL,
  `acquisition_date` DATE NOT NULL,
  `acquisition_cost` DECIMAL(15,2) NOT NULL,
  `annual_depreciation_rate` DECIMAL(5,2) NOT NULL,
  `accumulated_depreciation` DECIMAL(15,2) DEFAULT 0.00,
  `net_book_value` DECIMAL(15,2) NOT NULL,
  `status` ENUM('in_service', 'written_off', 'sold') DEFAULT 'in_service',
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_depreciation_entries`;
CREATE TABLE `erp_depreciation_entries` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `asset_id` VARCHAR(36) NOT NULL,
  `period_year` INT NOT NULL,
  `depreciation_amount` DECIMAL(15,2) NOT NULL,
  `journal_entry_id` VARCHAR(36) NULL,
  `calculated_at` DATE NOT NULL,
  FOREIGN KEY (`asset_id`) REFERENCES `erp_fixed_assets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_project_gates`;
CREATE TABLE `erp_project_gates` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `code` VARCHAR(50) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `status` ENUM('Passed', 'Failed', 'Pending') NOT NULL,
  `target_date` VARCHAR(50) NOT NULL,
  `actual_date` VARCHAR(50) NULL,
  `progress` INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_project_costs`;
CREATE TABLE `erp_project_costs` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `category` VARCHAR(100) NOT NULL,
  `budget` DECIMAL(15,2) NOT NULL,
  `actual` DECIMAL(15,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- DOMÍNIO 14: AUDITORIA, PISTAS DE SEGURANÇA & LOGS (Pontos 21, 22)
-- ====================================================================

-- Tabela de Auditoria com TODAS as colunas solicitadas no Ponto 21:
-- timestamp, user_id, company_id, branch_id, ip, user_agent, module, action, 
-- entity, record_id, result, old_values, new_values, reason, request_id, correlation_id
DROP TABLE IF EXISTS `erp_audit_logs`;
CREATE TABLE `erp_audit_logs` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `user_id` VARCHAR(50) NOT NULL,
  `user_name` VARCHAR(100) NOT NULL,
  `company_id` VARCHAR(36) NOT NULL,
  `branch_id` VARCHAR(36) NULL,
  `ip_address` VARCHAR(45) DEFAULT '127.0.0.1',
  `user_agent` TEXT NULL,
  `module` VARCHAR(50) NOT NULL,
  `action` VARCHAR(50) NOT NULL,
  `entity_type` VARCHAR(50) NOT NULL,
  `entity_id` VARCHAR(50) NOT NULL,
  `result` ENUM('SUCCESS', 'FAILURE', 'WARNING') NOT NULL DEFAULT 'SUCCESS',
  `old_values` JSON NULL,
  `new_values` JSON NULL,
  `reason` VARCHAR(255) NULL,
  `request_id` VARCHAR(64) NULL,
  `correlation_id` VARCHAR(64) NULL,
  `details` TEXT NOT NULL,
  INDEX `idx_audit_module` (`module`),
  INDEX `idx_audit_action` (`action`),
  INDEX `idx_audit_entity` (`entity_type`, `entity_id`),
  INDEX `idx_audit_timestamp` (`timestamp`),
  FOREIGN KEY (`company_id`) REFERENCES `erp_companies` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_security_logs`;
CREATE TABLE `erp_security_logs` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `event_type` VARCHAR(50) NOT NULL,
  `user_id` VARCHAR(36) NULL,
  `ip_address` VARCHAR(45) NOT NULL,
  `severity` ENUM('INFO', 'WARNING', 'CRITICAL') NOT NULL DEFAULT 'INFO',
  `description` TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `erp_integration_logs`;
CREATE TABLE `erp_integration_logs` (
  `id` VARCHAR(36) NOT NULL PRIMARY KEY,
  `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `service_name` VARCHAR(50) NOT NULL,
  `direction` ENUM('INBOUND', 'OUTBOUND') NOT NULL,
  `status` ENUM('SUCCESS', 'FAILED') NOT NULL,
  `payload_summary` TEXT NULL,
  `response_time_ms` INT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
