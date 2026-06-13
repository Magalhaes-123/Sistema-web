<?php

namespace BoaConta\Auth;

use BoaConta\Core\Database;

class Auth
{
    private Database $db;

    public function __construct(Database $db)
    {
        $this->db = $db;
    }

    public static function isAuthenticated(): bool
    {
        return isset($_SESSION['user_id']) && !empty($_SESSION['user_id']);
    }

    public static function getCurrentUser(): ?array
    {
        if (!self::isAuthenticated()) {
            return null;
        }
        return $_SESSION['user'] ?? null;
    }

    public static function getCurrentEmpresa(): ?int
    {
        return $_SESSION['empresa_id'] ?? null;
    }

    public static function login(int $userId, array $user, int $empresaId): void
    {
        $_SESSION['user_id'] = $userId;
        $_SESSION['user'] = $user;
        $_SESSION['empresa_id'] = $empresaId;
        $_SESSION['login_time'] = time();
    }

    public static function logout(): void
    {
        session_destroy();
    }

    public static function hasPermission(string $permission): bool
    {
        return in_array($permission, $_SESSION['permissions'] ?? []);
    }

    public function authenticate(string $email, string $password): ?array
    {
        $result = $this->db->query(
            "SELECT * FROM utilizadores WHERE email = ? AND status = 'ativo'",
            [$email]
        );

        if (empty($result)) {
            return null;
        }

        $user = $result[0];
        
        if (!password_verify($password, $user['password_hash'])) {
            return null;
        }

        return $user;
    }
}
