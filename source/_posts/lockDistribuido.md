---
title: Lock distribuído! Como fazer?
date: 2025-06-06 15:04:21
tags: [desenvolvimento, java, microservicos, redis]
---

![lock.png](lock-logo.png)

# Fala **_pexadas_**!! Tudo bom com vocês?

Recentemente, um amigo pessoal escreveu um [artigo no Linkedin](https://www.linkedin.com/posts/felipeoc_weekend-rust-excursion-implementing-a-semaphore-activity-7335310959206354944-p05K) mostranddo uma implementação de um semáforo em Rust. Fiquei pensando por um tempo e lembrei que muitas vezes temos um problema em que um semáforo seria uma solução, porém poucas pessoas entendem como funciona e muito menos como implementa.

Então decidi escrever este artigo trazendo um caso real e como faríamos para implementar um semáforo num cenário de microserviços.

## O que é um Lock Distribuído e Como Funciona?
Em sistemas distribuídos, onde várias instâncias de uma aplicação estão executando simultaneamente, pode ser necessário garantir que apenas uma delas acesse ou modifique um recurso compartilhado por vez. É aqui que entra o conceito de **lock distribuído**.

### 🔐 O Que é um Lock Distribuído?
É um mecanismo de sincronização que permite que diferentes processos ou nós (em servidores diferentes) garantam acesso exclusivo a um recurso compartilhado, evitando conflitos e concorrência descontrolada.

### ✅ Características de um Lock Distribuído
 - **Exclusão mútua**: Apenas um cliente detém o lock.
 - **Segurança contra bloqueios**: O lock ter um tempo de expiração para evitar que ele fique travado para sempre se algum processo falhar.
 - **Prioridade de fila**: Pode ser implementado para garantir que quem chega primeiro tem prioridade, embora nem todo sistema adote isso.


## ⚠️ O Problema
O caso real onde precisei implementar essa solução não posso revelar, mas podemos criar um problema parecido que resolve da mesma forma.

### 📝 Caso hipotético
Vamos supor então, que estamos criando um sistema para controlar as reservas de corretores de imóveis em uma imobiliária. Cada corretor pode reservar uma unidade por um período de tempo até que a reserva "caia" sozinha, ou que ele mesmo remova sua reserva. Uma vez a unidade reservada por um corretor, o outro não pode reservar a mesma unidade. Vamos definir que o corretor tem um prazo de 2 horas até que a sua reserva "caia" por falta de atividade.

Com o problema descriminado, agora precisamos de fato fazer uma implementação dessa solução

##  Implementação
Para essa implementação vamos usar uma stack com Java, Spring Boot, Redis e Lua.
A primeira coisa que precisamos fazer dois endpoints, um que irá fazer o bloqueio do recurso e o seguindo que fará a liberação do recurso.
```java
@RestController
public class ReservaController {
    @Autowired
    private ReservaService reservaService;

    @PostMapping("/lock")
    public String reservar(@RequestBody ReservaCmd cmd) {
        reservaService.reservar(cmd);
        return "ok";
    }

    @PostMapping("/release")
    public String release(@RequestBody ReservaCmd cmd) {
        reservaService.liberarReserva(cmd);
        return "ok";
    }
}
```
A classe nomeada como `ReservaCmd` está relacionada abaixo:
```java
public record ReservaCmd(
        String idUsuario,
        String idImovel
) {
}
```

Uma vez definido nosso `Controller` precisamos implementar a lógica da reserva. E na classe `ReservaServico` está base da implementação da lógica por trás do lock/relase.

```java
@Service
public class ReservaService {

    private final LockService lockService;
    
    public ReservaService(LockService lockService) {
        this.lockService = lockService;
    }

    public void reservar(ReservaCmd cmd) {
        try {
            lockService.acquireLock(cmd.idImovel(), cmd.idUsuario());
            //TODO codigo de realizacao da reserva em banco de dados
        } catch(IllegalStateException e) {
            throw new IllegalStateException("Não foi possível adiquirir o lock");
        }
    }

    public void liberarReserva(ReservaCmd cmd) {
        try {
            //TODO codigo para liberar a reserva em banco de dados
            lockService.releaseLock(cmd.idImovel(), cmd.idUsuario());
        } catch(IllegalStateException e) {
            throw new IllegalStateException("Não foi possivel liberar a reserva");
        }
    }
}
```

Com todo esse código feito você deve está se perguntando: Mas o que esse `LockService` faz de fato? E é ai que vamos precisar aprofundar um pouco mais os conceitos.
O código abaixo mostra a implementação da classe `LockService`, e vamos precisar destrinchar algumas linhas de forma explícita.
```java
@Service
public class LockService {
    private final RedisTemplate<String, String> redisTemplate;

    private static final RedisScript<Boolean> releaseScript = RedisScript.of(
            new ClassPathResource("redis/scripts/lock_release.lua"),
            Boolean.class
    );

    public LockService(RedisTemplate<String, String> redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    private static final String PREFIXO_LOCK = "LOCK-RESERVA::";
    private static final Duration DURACAO_LOCK = Duration.of(2, ChronoUnit.HOURS);

    public synchronized void acquireLock(String idImovel, String idUsuario) {
        Boolean realizouLock = redisTemplate
                .opsForValue()
                .setIfAbsent(PREFIXO_LOCK + idImovel, idUsuario, DURACAO_LOCK);

        if (Boolean.FALSE.equals(realizouLock)) {
            throw new RuntimeException("Recurso bloqueado");
        }
    }

    public synchronized void releaseLock(String idImovel, String idUsuario) {

        Boolean executou = redisTemplate.execute(
                releaseScript,
                List.of(PREFIXO_LOCK + idImovel),
                idUsuario);

        if (!executou) {
            throw new RuntimeException("Lock não pode ser removido.");
        }
    }
}
```

- Nas linhas 5 à 8 estamos fazendo o carregamento de um script em Lua que iremos mostrar e explicar posteriormente.
- A linha 14 define a base da chave que será usada para armazenar no Redis.
- A linha 15 define o tempo que o lock ficará definido caso o dono do lock não libere. Assim a reserva "cai" por padrão quando esse tempo é atingido.
- A linha 17 mostra a definição da função que tenta fazer o lock de um recurso para um determinado usuário.
 
A função **redisTemplate.opsForValue().setIfAbsent()** nas linhas 18 à 20, retorna _**True**_ quando a chave não existe no redis e ele consegue incluir essa chave, e retorna _**False**_ quando a chave já existe ou ele não consegue inserir a chave. O valor inserido dentro dessa chave é o id do usuário.
Até aqui nenhuma novidade pra quem tem familiaridade com o Redis. O negócio fica interessante na implementação do release(liberação) do lock inicial. E para explicar melhor precisamos fazer uma comparação do método junto com o script Lua que criamos.

```lua
--lock_release.lua
if redis.call("get", KEYS[1]) == ARGV[1] then
    return redis.call("del", KEYS[1])
else
    return 0
end
```

```java
 public synchronized void releaseLock(String idImovel, String idUsuario) {

        Boolean executou = redisTemplate.execute(
                releaseScript,
                List.of(PREFIXO_LOCK + idImovel),
                idUsuario);

        if (!executou) {
            throw new RuntimeException("Lock não pode ser removido.");
        }
    }
```

A função `releaseLock` precisa fazer 3 ações. A primeira é saber se a chave existe, a segunda é saber se o usuário que está tentando liberar esse lock é o dono do lock e a terceira é liberar o lock caso tudo esteja correto. 
Então para isso nós iriamos precisar fazer 2 chamadas no Redis. A primeira buscando o valor da chave, com o valor na mão iriámos comparar se o valor é igual ao usuário que está tentando liberar e depois fazer uma nova chamada para o Redis deletando a chave.

Com o script nós conseguimos passar essa comparação para dentro do Redis, dessa forma, uma única chamada no Redis é capaz de fazer todas as verificações necessárias para liberação, e se tudo estiver certo, apagar a chave.

### Considerações
Percebam que as funções `acquireLock` e `releaseLock` não retornam nada e irão estourar uma exceção caso não consiga executar a função. Todas essas implementações podem ser modificadas para retornar um booleano. Existem ainda outra variações como no exemplo abaixo.
```java
public void realizaOperacao(Cmd cmd) {
    try {
        String identificador = lockService.acquireLock(cmd.id);
        
        //TODO Realiza código que não pode ser concorrente
        
        lockService.releaseLock(cmd.id, identificador);
    } catch(IllegalStateException e) {
        throw new IllegalStateException("Não foi possível realizar opração");
    }
}
```
Observem que no código acima, a função `acquireLock` devolve um identificador do bloqueio, fazendo com que esse identificador foi colocado como valor da chave, assim somente de posse desse identificador pode liberar o lock, tornando essa utilização mais contida dentro de uma mesma operação.
Esse tipo de utilização pode ser muito útil quando se está fazendo alteração em banco de dados NoSQL como DynamoDB por exemplo, que pode fazer com que se 2 execuções aconteçam simultaneamente, a última a terminar irá sobrescrever a operação que inicio primeiro, fazendo com que algumas alterações tenham se perdido no meio do caminho.


## Conclusão
Esse foi um caso onde um semáforo pode ser aplicado num cenário de sistemas distribuído como temos nos dias atuais. É muito importante ter em sua mente que soluções como essa podem ser aplicadas em diversos cenários como: reservas de cinema, reservas de imóveis como sugerimos, marcação de horários em agendas...
Os cenários podem ser os mais variados que se possa imaginar. Usem a criatividade e soluções que sejam simples e eficazes.

Os códigos usados nesse experimento estão no [github](https://github.com/dsandrade0/lock-distribuido), aproveitem e façam seus experimentos.

## Sem mais eu vou ficando por aqui **_PEXADAS_**. Até a próxima
