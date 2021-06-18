---
title: Java Optional. Você está usando ele errado!
date: 2021-06-17 21:03:34
tags: [desenvolvimento, java]
---
Fala **pexadas**. No últimos dias, tenho encontrado muitos erros na utilização do Optional nos projetos que tenho trabalhado.
Sendo assim, resolvi criar um este artigo é tentar mostrar algumas formas corretas de utilizar o Optional.

#Introdução

O Java 8 trouxe consigo uma infinidade de novidades que fizeram com que essa versão fosse a queridinha de muita gente. Dentre elas está o famoso **Optional**.

O objetivo inicial do Optional era ser utilizado como retorno das funções onde o seu retorno pudesse, por ventura, não conter valores. Assim quem chamou uma função que devolvesse um Optional, poderia verificar se o retorno possui ou não valores antes de tentar utilizar. Caso o valor não exista, pode ser facilmente substituído por um valor padrão caso seja necessário.

Sendo assim, o principal objetivo dessa "biblioteca", é reduzir os famosos **NPE** (Null Pointer Exception). 
Vamos discutir agora um pouco sobre o uso dessa ferramenta.

### Onde não utilizar Optional 

#### Evite usar como atributos de classe POJO, DTO e Comando
O Java Optional não é recomendado para classes tipo POJO, DTO e Comandos pelo simples fato de que eles não são serializáveis. Sendo assim se você ainda precisa ter um atributo de classe optional, **use um atributo com valor nulo e na seu método "get" faça ele retornar o Optional do seu campo.**

#### Evite usar como parâmetros dos métodos
Vamos pensar pelo seguinte ponto de vista. Quando eu recebo um parâmetro, eu tenho 2 possíveis situações: não nulo ou nulo. Quando eu passo um Optional como parâmetro agora eu tenho 3 possíveis situações: nulo, não nulo com valor ou não nulo sem valor.
Vamos fazer alguns exemplos:

`metodo("bola", Optional.of("chuteira"));`
`metodo("bola", Optional.empty());`
`metodo("bola", null);`

Se você precisa ter um optional como o segundo paramêtro, talvez seja melhor fazer uma sobrecarga do método para aceitar com um ou dois parâmetros como abaixo:

`metodo("bola");`
`metodo("bola", "chuteira");`

#### Evite usar Optional em listas
Tenho percebido que algumas pessoas gostam de usar o Optional em listas como `List<Optional<T>` ou 
`Map<String, Optional<T>>`. Talvez isso pareça uma boa idéia, mas na prática pode causar mais confusão. Talvez seja melhor colocar o valor nulo e fazer uma verificação no momento de utilizar os dados da lista.

## Conclusão
Tirando esses principais pontos, acredito que não exista outros pontos críticos para a utilização do Java Optional. Então utilizem essa biblioteca com saberia e refatorem seus códigos onde estiverem utilizando da forma inadequada.

Até a próxima **pexadas**.

