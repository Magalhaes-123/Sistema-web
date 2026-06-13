<?php

namespace BoaConta\Core;

class Validator
{
    private array $errors = [];
    private array $data;
    private array $rules;

    public function __construct(array $data, array $rules)
    {
        $this->data = $data;
        $this->rules = $rules;
    }

    public function validate(): bool
    {
        foreach ($this->rules as $field => $ruleString) {
            $rules = explode('|', $ruleString);
            
            foreach ($rules as $rule) {
                $this->applyRule($field, $rule);
            }
        }
        
        return empty($this->errors);
    }

    private function applyRule(string $field, string $rule): void
    {
        $value = $this->data[$field] ?? null;
        $ruleParts = explode(':', $rule);
        $ruleName = $ruleParts[0];

        match ($ruleName) {
            'required' => $this->validateRequired($field, $value),
            'email' => $this->validateEmail($field, $value),
            'numeric' => $this->validateNumeric($field, $value),
            'min' => $this->validateMin($field, $value, $ruleParts[1] ?? null),
            'max' => $this->validateMax($field, $value, $ruleParts[1] ?? null),
            'unique' => $this->validateUnique($field, $value, $ruleParts[1] ?? null),
            default => null,
        };
    }

    private function validateRequired(string $field, mixed $value): void
    {
        if (empty($value)) {
            $this->errors[$field][] = "Campo {$field} é obrigatório";
        }
    }

    private function validateEmail(string $field, mixed $value): void
    {
        if ($value && !filter_var($value, FILTER_VALIDATE_EMAIL)) {
            $this->errors[$field][] = "Campo {$field} deve ser um email válido";
        }
    }

    private function validateNumeric(string $field, mixed $value): void
    {
        if ($value && !is_numeric($value)) {
            $this->errors[$field][] = "Campo {$field} deve ser numérico";
        }
    }

    private function validateMin(string $field, mixed $value, ?string $min): void
    {
        if ($value && strlen($value) < (int)$min) {
            $this->errors[$field][] = "Campo {$field} deve ter no mínimo {$min} caracteres";
        }
    }

    private function validateMax(string $field, mixed $value, ?string $max): void
    {
        if ($value && strlen($value) > (int)$max) {
            $this->errors[$field][] = "Campo {$field} deve ter no máximo {$max} caracteres";
        }
    }

    private function validateUnique(string $field, mixed $value, ?string $table): void
    {
        // Implementar validação de unicidade com banco de dados
    }

    public function getErrors(): array
    {
        return $this->errors;
    }

    public function hasErrors(): bool
    {
        return !empty($this->errors);
    }
}
