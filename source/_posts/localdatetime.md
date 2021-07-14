---
title: Datas e hora em Java? Nunca foi tão fácil!
date: 2021-07-13 21:06:29
tags: [java, desenvolvimento]
---
![calendario](calendario.jpg)
### Fala **_pexadas_**!! Tudo bom com vocês?

Neste artigo, vamos abordar uma das novas _features_ trazidas pelo Java 8 (a um bom tempo atrás), mas que alguns desenvolvedores ainda utilizam equivocadamente, ou não conhecem bem o seu funcionamento. Estou falando da api de datas do Java, o **LocalDate** e **LocalDateTime**.

## Introdução
No passado, se algum programador Java precisasse utilizar alguma biblioteca para trabalhar com data ou data/hora, com certeza teria dúvidas em escolher a biblioteca que utilizaria. Isso acontecia, porque cada programador adotava sua biblioteca e utilizava da melhor forma que sabia. Dentre as mais conhecidas estão [Calendar](https://docs.oracle.com/javase/7/docs/api/java/util/Calendar.html), uma subclasse de Calendar chamada [GregorianCalendar](https://docs.oracle.com/javase/7/docs/api/java/util/GregorianCalendar.html), [Date](https://docs.oracle.com/javase/7/docs/api/java/util/Date.html) ou até mesmo usando o próprio _timestamp_ (`System.currentTimeInMilis()`) para fazer as contas malucas e representar as datas de um jeito artesanal.
E em meio a estas alternativas, ainda tinha o [Joda-Time](https://www.joda.org/joda-time/index.html), que virou a biblioteca padrão do Java na versão 8 e será o nosso foco aqui.

De fato usar o `System.currentTimeInMilis()` é muito eficiente, pois ele não cria um objeto que necessite a utilização de um [GC](https://en.wikipedia.org/wiki/Garbage_collection_(computer_science)) para liberar essa memória, mas mesmo sendo muito eficiente, não me parece ser uma boa ideia guardar datas como sendo um _timestamp_ se essas datas precisem de uma conversão todas as vezes que houvesse uma necessidade de exibição em alto nível da data. Sendo assim, as bibliotecas para esses casos são mais utilizadas.
Sem mais delongas, vamos ao que interessa. Demonstrar a utilização da biblioteca padrão do Java.

## Representando datas com LocalDate
Vamos ver um exemplo simples para gerar uma variável com a data de hoje.
```
 LocalDate hoje = LocalDate.now();
 System.out.println(hoje); // 2021-07-13 [no dia em que escrevo]
```
Caso eu precise gerar uma data específica eu posso usar o seguinte método:
```
 LocalDate dia = LocalDate.of(2021, 2, 20);
 System.out.println(dia); // 2021-02-20
```
E o que acontece se eu colocar uma data que não existe por exemplo?
```
 LocalDate dia = LocalDate.of(2021, 2, 30); // DateTimeException
```
Aqui, uma exceção do tipo _DateTimeException_ será lançada. Essa data é, de fato, inválida. Essa verificação precisa ficar por conta do programador, pois o compilador não irá reclamar dessa sintaxe e esse erro só ocorrerá em tempo de execução.
Alguns métodos auxiliares são bastante úteis. Como por exemplo:
```
 LocalDate hoje = LocalDate.now(); // Data atual 2021-07-13
 hoje.getDayOfWeek().equals(DayOfWeek.FRIDAY); // false OH, NO!! 
 LocalDate ontem = hoje.minusDays(1); // Diminui 1 dia
 LocalDate amanha = hoje.plusDays(1);  // Soma 1 dia
 LocalDate mesPassado = hoje.minusMonths(1); // Dimiui 1 mês
 LocalDate mesQueVem = hoje.plusMonths(1); // Soma 1 mês
 LocalDate semanaPassada = hoje.minusWeeks(1); // Diminui 7 dias
 LocalDate semanaQueVem = hoje.plusWeeks(1); // Soma 7 dias
 LocalDate anoPassado = hoje.minusYears(1); // Diminui 1 ano na data | 2020-07-13
 LocalDate anoQueVem = hoje.plusYears(1); // Soma 1 ano na data | 2022-07-13
 System.out.println(hoje.isLeapYear()); // false - Mostra se o ano é bisexto
```
Uma curiosidade é que o _LocalDate_ não possui métodos para trabalhar com hora, minuto, segundo, etc. Isso fica por conta da classe LocalDateTime que veremos depois.
Agora vejamos uma coisa que precisamos nos atentar quando usamos _LocalDate_:
```
public LocalDate semFimDeSemana(LocalDate dia) {
    while(dia.getDayOfWeek().equals(DayOfWeek.FRIDAY) || 
          dia.getDayOfWeek().equals(DayOfWeek.SATURDAY) || 
          dia.getDayOfWeek().equals(DayOfWeek.SUNDAY)) {
        dia.plusDays(1);
    }
    return dia;
}
```
O código acima, foi encontrado em um dos sistemas em que trabalho atualmente, e dando uma olhada na condição do `while`, sabemos que, o que o programador desejava, era que uma data não poderia ser sexta-feira, sábado ou domingo. Mas na verdade esse código produz um loop infinito por um simples erro de entendimento da classe LocalDate. `OS OBJETOS SÃO IMUTÁVEIS`.
A linha 5 do código, indica que eu estou adicionando um dia na data passada como parâmetro, mas o que de fato acontece, é que `dia.plusDay(1)` returna um LocalDate que precisa ser atribuído a uma variável, mas, na verdade, o valor adicionado está perdido. Vejamos como seria o código correto:
```
public LocalDate semFimDeSemana(LocalDate dia) {
    while(dia.getDayOfWeek().equals(DayOfWeek.FRIDAY) || 
          dia.getDayOfWeek().equals(DayOfWeek.SATURDAY) || 
          dia.getDayOfWeek().equals(DayOfWeek.SUNDAY)) {
        dia = dia.plusDays(1);
    }
    return dia;
}
```
Toda utilização de um método auxiliar de LocalDate, produz um novo objeto LocalDate sem modificar o objeto original. Um detalhe simples que passou batido no _code review_ e nos cenários dos testes unitários que causou algumas horas de análise para identificar o problema.

## Representando data com LocalDateTime
LocalDateTime possui os mesmos conceitos do LocalDateTime, mas incluindo métodos auxiliares para trabalhar com hora, minuto, segundo, etc.
```
LocalDateTime hoje = LocalDateTime.now() // 2021-07-13T21:47:51.047569 no momento em que escrevo;
```
Note que uma letra 'T' é utilizada para separar a data da hora, sendo esse o padrão utilizado pelos navegadores atuais usando o [html](https://www.w3schools.com/tags/tryit.asp?filename=tryhtml5_input_type_datetime-local). Além dos métodos auxiliares mostrados para o LocalDate o LocalDateTime possui os seguintes métodos auxiliares:
```
LocalDateTime agora = LocalDateTime.now(); // 2021-07-13T21:47:51.047569
LocalDateTime horaPassada = agora.minusHours(1); // 2021-07-13T20:47:51.047569
LocalDateTime proximaHora = agora.plusHours(1); // 2021-07-13T22:47:51.047569
LocalDateTime minutoPassado = agora.minusMinutes(1); // 2021-07-13T21:46:51.047569
LocalDateTime proximoMinuto = agora.plusMinutes(1); // 2021-07-13T21:48:51.047569
LocalDateTime segundoPassado = agora.minusSeconds(1); // 2021-07-13T21:47:50.047569
LocalDateTime ProximoSegundo = agora.plusSeconds(1); // 2021-07-13T21:47:52.047569
LocalDateTime nanoSegundoPassado = agora.minusNanos(1); // 2021-07-13T21:47:51.047568
LocalDateTime proximoNanoSegundo = agora.plusNanos(1); // 2021-07-13T21:47:51.047570
```
O mesmo que foi falado para a classe LocalDate, serve para o LocalDateTime, os objetos são imutáveis.

## Comparação entre datas
Para comparação entre datas as duas classes tem métodos semelhantes:
```
LocalDateTime agora = LocalDateTime.now();
LocalDateTime horaPassada = agora.minusHours(1);
System.out.println(agora.isAfter(horaPassada)); // true
System.out.println(agora.isBefore(horaPassada)); // false
System.out.println(agora.isBefore(agora)); // false
System.out.println(agora.isBefore(agora)); // false
System.out.println(agora.isEqual(agora)); // true
```
As mesmas assinaturas dos métodos existentes em LocalDateTime estão presentes em LocalDate, somente mudando o tipo do parâmetro de LocalDateTime para LocalDate.

## Conclusão
Existem ainda vários outros métodos, como por exemplo conversão de LocalDate para LocalDateTime e vice-versa. Mas o que foi apresentado neste artigo é suficiente para te tirar de qualquer _perrengue_ que você possa passar na utilização de datas em Java. Não sei se algum dia você já precisou usar alguma api de datas em Java no passado, mas hoje está muito mais simplificado.

Espero que tenham gostado e até a próxima **_pexadas_**!

