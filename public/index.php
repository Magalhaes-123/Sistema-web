<?php

session_start();

require_once __DIR__ . '/../vendor/autoload.php';

// Carregar configurações
$config = require __DIR__ . '/../config/app.php';
$dbConfig = require __DIR__ . '/../config/database.php';

try {
    // Inicializar banco de dados
    $db = new BoaConta\Core\Database($dbConfig[$dbConfig['default']]);
    
    // Verificar autenticação
    if (!BoaConta\Auth\Auth::isAuthenticated()) {
        header('Location: index.php?page=login');
        exit;
    }
    
    // Router simples
    $page = $_GET['page'] ?? 'dashboard';
    
    switch ($page) {
        case 'login':
            require __DIR__ . '/../views/auth/login.php';
            break;
        case 'dashboard':
            require __DIR__ . '/../views/dashboard.php';
            break;
        case 'clientes':
            require __DIR__ . '/../views/comercial/clientes.php';
            break;
        case 'faturas':
            require __DIR__ . '/../views/faturacao/faturas.php';
            break;
        case 'funcionarios':
            require __DIR__ . '/../views/rh/funcionarios.php';
            break;
        case 'relatorios':
            require __DIR__ . '/../views/relatorios/relatorios.php';
            break;
        case 'logout':
            BoaConta\Auth\Auth::logout();
            header('Location: index.php?page=login');
            exit;
        default:
            require __DIR__ . '/../views/404.php';
    }
} catch (\Exception $e) {
    die('Erro: ' . htmlspecialchars($e->getMessage()));
}
