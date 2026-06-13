<?php

namespace BoaConta\Core;

class Container
{
    private array $bindings = [];
    private array $singletons = [];

    public function bind(string $name, callable $resolver): void
    {
        $this->bindings[$name] = $resolver;
    }

    public function singleton(string $name, callable $resolver): void
    {
        $this->bind($name, $resolver);
        $this->singletons[$name] = true;
    }

    public function make(string $name): mixed
    {
        if (!isset($this->bindings[$name])) {
            throw new \Exception("Binding '{$name}' não encontrado no container");
        }

        $resolver = $this->bindings[$name];
        $instance = $resolver($this);

        return $instance;
    }
}
