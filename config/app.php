<?php

return [
    'name' => 'BOA CONTA - Sistema Universal de Gestão Empresarial',
    'version' => '1.0.0',
    'timezone' => 'America/Sao_Paulo',
    'locale' => 'pt_BR',
    
    // Configuração Global
    'global' => [
        'pais_padrao' => 'AO',
        'idioma_principal' => 'pt_PT',
        'modo_online' => true,
    ],
    
    // Multi-País
    'paises' => [
        'AO' => ['nome' => 'Angola', 'moeda' => 'AOA', 'idioma' => 'pt_PT'],
        'MZ' => ['nome' => 'Moçambique', 'moeda' => 'MZN', 'idioma' => 'pt_PT'],
        'PT' => ['nome' => 'Portugal', 'moeda' => 'EUR', 'idioma' => 'pt_PT'],
        'BR' => ['nome' => 'Brasil', 'moeda' => 'BRL', 'idioma' => 'pt_BR'],
    ],
    
    // Multi-Moeda
    'moedas' => [
        'AOA' => 'Kwanza Angolano',
        'MZN' => 'Metical Moçambicano',
        'EUR' => 'Euro',
        'BRL' => 'Real Brasileiro',
        'USD' => 'Dólar Americano',
    ],
];
