<!DOCTYPE html>
<html lang="pt_PT">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo $title ?? 'BOA CONTA'; ?> - Sistema de Gestão Empresarial</title>
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body>
    <div class="container">
        <!-- Sidebar -->
        <nav class="sidebar">
            <div class="logo">
                <h1>BOA CONTA</h1>
                <p>Gestão Empresarial</p>
            </div>
            
            <?php if (BoaConta\Auth\Auth::isAuthenticated()): ?>
            <div class="user-info">
                <p><?php echo htmlspecialchars(BoaConta\Auth\Auth::getCurrentUser()['nome'] ?? ''); ?></p>
            </div>
            
            <ul class="menu">
                <li><a href="?page=dashboard">Dashboard</a></li>
                <li><a href="?page=clientes">Comercial</a></li>
                <li><a href="?page=faturas">Faturação</a></li>
                <li><a href="?page=funcionarios">Recursos Humanos</a></li>
                <li><a href="?page=relatorios">Relatórios</a></li>
                <li><a href="?page=logout">Logout</a></li>
            </ul>
            <?php endif; ?>
        </nav>

        <!-- Main Content -->
        <main class="content">
            <?php echo $content ?? ''; ?>
        </main>
    </div>
    
    <script src="/assets/js/main.js"></script>
</body>
</html>
