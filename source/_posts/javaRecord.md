---
title: Java Record! Será o fim do DTO?
date: 2022-02-22 22:53:21
tags: [desenvolvimento, java, microservicos]
---

![Java Record](records-java14.png)

## Fala **_pexadas_**!! Tudo bom com vocês?

Com a chegada do Java 17, mais uma release LTS (Long-Term Support), apareceram novas e interessantes features. Entre _Text blocks_, _ZGC_ e _Shenandoah_ (Garbages Collectors), novos métodos na classe String, _Sealed Classes_, vieram também os **_Records_**. Vamos entender um pouco mais sobre **Records**?

# Introdução
Um **_Record_** nada mais é que um tipo de classe projetada para gerar um [JavaBean](https://pt.wikipedia.org/wiki/JavaBeans) tradicional. O ponto que difere das classes existentes, é que ele cria uma classe que possui construtor, métodos acessórios, **toString()**, **hashCode()**, **equals()**, mas é uma classe imutável, ou seja, uma vez criado o objeto, não permite alteração dos dados do objeto.
Mas por que eu deveria considerar usar **Records**? Aí vai algumas vantagens:

1. Imutabilidade
2. Diminui a escrita de código
3. Remove a necessidade de utilizar bibliotecas para gerar _beans_, como por exemplo o [Lombok](https://projectlombok.org)

# Show me code!
Para ilustrar o que podemos fazer com os **Records** vamos usar a classe _Pessoa_ abaixo como exemplo.

```java
public class Pessoa {
    private String nome;
    private Integer idade;

    public Pessoa(String nome, Integer idade) {
        this.nome = nome;
        this.idade = idade;
    }

    public Integer getIdade() {
        return idade;
    }

    public String getNome() {
        return nome;
    }

    public void setIdade(Integer idade) {
        this.idade = idade;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Pessoa pessoa = (Pessoa) o;
        return nome.equals(pessoa.getNome()) && idade.equals(pessoa.getIdade());
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(nome, idade);
    }
    
    @Override
    public String toString() {
        //Utilizando o TEXT BLOCK do Java 13
        return """
                 Pessoa {nome: %s, idade: %d}
                """.formatted(nome, idade);
    }
}
```

Ufa! Terminanos de escrever o nosso _bean_ padrão. O código acima, faz parte do dia a dia do programador Java. Escrevemos essas classes o tempo todo. 
Para substituir o código acima com **Records**, faremos o seguinte código:
```java
public record Pessoa(String nome, Integer idade) {}
```

Pois é, com o código acima reproduzimos "praticamente" o mesmo comportamento do primeiro código que fizemos. Para analisar um pouco mellhor, vamos ver o que o compilador Java nos entrega com o **Record**:
```java
public record Pessoa(String nome, Integer idade) {
    public Pessoa(String nome, Integer idade) {
        this.nome = nome;
        this.idade = idade;
    }

    public String nome() {
        return this.nome;
    }

    public Integer idade() {
        return this.idade;
    }
}
```
Olhando atentamente, veremos que os métodos _Setters_ não foram criados. Isso é o reflexo da imutabilidade da classe, onde só é possivel passar os dados para um objeto através do construtor.
Perceba também que não aparecem os métodos _hash_, _equals_ e _toString_. Acontece que esses métodos serão entrgues de maneira implícita pela JVM, fazendo com que esses métodos sejam implementados utilizando todos os atributos declarados no Record.
Não impede que você possa implementar esses métodos manualmente. Caso essa implementação esteja explicita dentro do seu **Record**, ele irá sobscrever o método implícito gerado.

# Utilização de libs terceiras
Vocês podem está se perguntando: "Mas o Lombok já faz isso pra mim.", e de fato faz. O único problema que precisamos deixar claro, é que o Lombok é uma biblioteca terceira, e como toda lib externa é necessário que se escreva testes unitários para garantir que as funcionalidades utilizadas por essa biblioteca estejam funcionando mesmo se passar por uma atualização.
Vamos fazer um exemplo para deixar um pouco mais claro. Suponha que a classe Objeto abaixo esteja utilizando o Lombok.

```java
@Getter
public class Objeto {
    private String nomel;
}
```
Nesse caso em específico estamos utilizando a anotação **@Getter** e precisamos garantir que ela esta funcionalidade está funcionando corretamente na versão em que estamos utilizando. Sendo assim  o seguinte teste deveria ser implementado:
```java
    @Test
    void testaMetodoGetNome() throws NoSuchMethodException {
        Objeto carro = new Objeto("carro");
        Method metodoGetNome = carro.getClass().getMethod("getNome");
        assertTrue(Objects.nonNull(metodoGetNome));
    }
```
Isso não precisa ser feito com o **Record** por que ele faz parte da biblioteca padrão disponível no Java.lang.

# E como ele substitui o DTO?
Aí é que vem a parte mais legal. Na sua função primordial, um DTO (Data Transfer Object) só deveria servir para transportar os dados de um lugar para o outro dentro da aplicação. Sendo assim, não deveriamos ter métodos que alterassem seus valores como fazem os métodos _Setters_. Então o fato de que **Records** são serializáveis, poderia substituir facilmente os DTOs convencionais que costumamos usar dentro das aplicações.
Para ilustrar, vamos criar um o mesmo **Record** feito anteriormente, só que iremos adicionar funcionalidades já conhecida por muitos que utilizam frameworks Java disponíveis no mercado. Vamos fazer uma demostração utilizando o [Hibernate Validator](https://hibernate.org/validator/).
```java
public record Pessoa(
    @NotEmpty(message = "Um nome precisa ser inserido")
    String nome,
    @NotNull(message = "Uma idade pracisa ser informada")
    @Positive(message = "Uma idade pracisa ser maior que zero")
    Integer idade) {
}
```
No código acima, podemos validar uma entrada (Comando) em um **Controller** utilizando o framework [Spring Boot](https://spring.io/quickstart) sendo feita apenas com a anotação **@Valid** (disponibilizada pelo _Hibernate Validator_) como no exemplo abaixo:
```java
    @PostMapping("/pessoa")
    public ResponseEntity<?> salvarPessoa(@RequestBody @Valid Pessoa pessoa) {
        return ResponseEntity.status(HttpStatus.CREATED).body(pessoa);
    }
```
Perceba que nesse código acima, estamos recebendo nosso **Record** como o _body_ dessa requisição e ao mesmo tempo estamos retornando ele na resposta da requisição. Mostrando que O [JSON-B e JSON-P](https://cloud.ibm.com/docs/java?topic=java-mp-json&locale=pt-BR) funcionam perfeitamente com os **Records**.

# E tem pontos negativos?
Como tudo no mundo do desenvolvimento exige _trade-off_, com o **Record** não poderia ser diferente. Uma das coisas que podem ser ditas como uma desvantagem são algumas menipulações pelas bibliotecas de Serialização e Deserialização como [Jackson](https://github.com/FasterXML/jackson).
Caso você precise por exemplo ignorar uma propriedade especifica na serialização usando Jackson por exemplo, seu código deveria ficar mais ou menos assim:
```java
public record Pessoa(
    String nome,
    @JsonIgnore
    Integer idade) {
}
```
Porém, esse mesmo código agora não poderá fazer a função de JSON-B (Deserialização de uma requisição por exemplo). O Jackson entende que deve de fato ignorar essa propriedade. Assim ela não será desserializada para dentro do **Record**.

# Conclusão
Os **Records** agora são uma realidade a partir do Java 14, porem é recomendado que se for utilizar que usem na versão 17, sendo essa a primeira versão LTS que suporta essa funcionalidade.
E quanto a substituir os DTOs, bem, isso cabe a cada desenvolvedor, saber o que pode ser melhor para o seu desenvolvimento. Mas esteja certo que essa funcionalidade dá uma nova cara para padrões como COMMAND, que utiliza DTOs específicos para entrada de dados no contexto da aplicação.

## Sem mais eu vou ficando por aqui **_PEXADAS_**. Até a próxima

### REFERENCIAS
1. https://docs.oracle.com/en/java/javase/14/language/records.html
2. https://spring.io/quickstart
3. https://github.com/FasterXML/jackson
4. https://hibernate.org/validator/


