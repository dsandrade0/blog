---
title: Ainda usa Java legado? Você precisa disso!
date: 2022-07-17 17:45:25
tags: [java, performance, jvm, compilador]
---

Fala `pexadas`. Cada dia mais rápida, a Oracle está lançando uma release Java LTS. E com tanta novidade, sempre estamos tentando fazer upgrade das versões das nossas aplicações.
Mas o que acontece com as aplicações que usam a versão mais antiga do Java?
Decidi escrever esse artigo para dar uma turbinada nas aplicações que ainda usam a versão 7 do Java.


# Introdução
Uma coisa que influencia diretamente na performance de aplicações Java é a compilação do Java Bytecode para Assambly. Essa compilação é feita no momento da execução do código pela JVM.
Então para entender como utilizar o melhor da JVM em suas aplicações legadas, vamos entender como é feita essa compilação primeiro.


# Compilando na JVM
Quando startamos nossa aplicação desenvolvida em Java, a JIT (Just-In-Time Compilation) entra em ação, transformanco o JavaBytecode em Assembly. Essa compilação é feita pelo compilador setado como padrão pela JVM.
Basicamente temos 2 compiladores disponíveis para fazer esse trabalho, o `C1` e o `C2`. Vamos primeiro entender qual a especialidade de cada compilador. 

## C1
O compilador C1 também é conhecido como `client`, e sua principal característica é que ele compila o código muito rápido, porém o assembly gerado por ele não é muito eficiente.
Ele possui 4 níveis de compilação, são eles:

Nível | Descrição
----------|-------------
0|Interpretado
1|Compilação simples
2|Compilação média
3|Compilacão completa

Como as próprias descrição já dizem, a medida que o nível é aumentado, a compilação é feita de forma mais performática.
Esse compilador é extremamente rápido nos primeiros níveis de compilação, esse detalhe é muito importante quando o tempo de bootstrap da aplicação é um requisito que precisa ser observado.

## C2
O compulador C2 também é conhecido como `server` e sua função é compilar, da forma mais agressiva possível, utilizando todas as informações disponíveis sobre o código em execução.
Esse compilador é mais lento que o `C1`, porém o assembly produzido por ele é muito rápido.

# Compiladores na JVM
Nas versões anteriores ao Java 7, a única coisa que se tinha para fazer com relação a escolha dos compiladores era escolher entre os compiladores `C1` e `C2` como parâmetro de execução da sua aplicação. Com isso, era necessário fazer um _trade-off_ para saber quais seriam as vantagens e desvantagens da cada compilador de acordo com a aplicação.

Porém, nas primeiras versões do Java 7, a flag `TieredCompilation` foi implantada. Basicamente o que ela oference é a possibilidade de trabalhar com os dois compiladores na mesma aplicação.
Mas para isso ser possível é necessário passar o parâmetro `+XX:+TieredCompilation`.

# Tiered Compilation

Quando o Tiered Compilation está ativado, a aplicação starta sendo compilada com o `C1`, e a medida que em que os códigos vão sendo chamados repetidamente e atigem determinado limiar, o código que alcançou esse limiar, será compilado pelo `C2`.
Sendo assim, os dois compiladores serão utilizados pela JVM. Agora flags que determinam os limiares dos compiladores podem ser utilizados para determinar quando o `C2` será utilizado.

Nas versões **Java 8+**, o `Tiered Compilation` vem ativado por padrão. Ainda é possível desativá-lo utilizando a flag `-XX:-TieredCompilation`. Mas vale a pena lembrar que quando essa flag é desligada, somente um dos compiladores será utilizado. Por padrão o compilador a ser utilizado quando esta flag é desligada, depende da plataforma em que a JVM será executada. 

# Conclusão

Para aplicações que utilizam Java 7 e a migração para versões mais novas do Java não podem ser utilizadas, essa flag é fortemente recomendada. Sempre que possível permita que o `Tiered Compilation` turbine seus códigos.

Por hoje é tudo **_PEXADAS_**!!
