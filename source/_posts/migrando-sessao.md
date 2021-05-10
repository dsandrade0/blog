---
title: Migrando sessão!
date: 2021-05-09 22:02:24
tags: devops
---

# TL;DR - Migrando sessão! Do Tomcat para o Redis

Fala galera! Mais uma vez por aqui para compartilhar mais um problema que passei recentemente!

## 1 - Introdução
Ultimamente, escalabilidade tem sido uma das grandes buscas pelos arquitetos de software, para garantir a disponibilidade e até mesmo para ter respostas mais rápidas dos sistemas.

Sendo assim, recebi uma missão. Pensar em uma forma de escalar um sistema que era “stateful”, ou seja, a sessão do usuário fica armazenada dentro do container da aplicação. Uma vez logado no sistema, um simples reboot do mesmo faria com que o usuário perdesse sua sessão! O que impede que a aplicação seja escalada, porque quando um usuário faz login em uma instância da aplicação, a outra não conhece a sessão desse usuário.

O tomcat possue uma solução de replicação de sessão nativo, mas ainda não resolveria um segundo problema que seria o scale up, ou seja, o aumento de mais servidor sem necessidade de mais configurações.

Outra questão é, aplicações stateful, são mais complicadas para serem conteinerizada, ou seja, usar os tão famosos containers do Docker ou algo semelhante.

Sendo assim, uma solução prática para remover a sessão do usuário de dentro do tomcat, é utilizar o Redis como nosso armazenador de sessões ao invés de deixar esse controle no tomcat.

---

## 2 - O que vamos utilizar
* Tomcat versão 9.x
* Redis 2.x
* Para facilitar nosso trabalho, usaremos o Docker para subir uma instância do Redis.

---

## 3 - O passo a passo
**1° passo**: O primeiro passo é garantir que todos os lugares que usam a sessão dentro da aplicação, 
utilizem a sessão do HttpServletRequest do Java EE. Então todos os armazenamentos precisam ser do tipo 
**request.getSession().setAttribute(“key”, value)**. Por mais natural que isso possa parecer, alguns frameworks, 
como Struts 2 por exemplo, possuem uma sessão isolada dentro do framework. No caso do Struts pode ser armazenada fazendo **ActionContext.getContext().put(“key”, value)**.

**2° passo**: Precisamos subir uma instância do Redis usando o docker. Para isso, com o docker instalado, 
abra um terminal (cmd, bash…) e digite o seguinte comando: 
`docker run -d — name redis -p 6379:6379 redis`

Não entraremos em detalhes nos comandos do docker, mas saiba que isso irá criar para nós um banco redis utilizando a porta 6379 da nossa máquina local.

**3° passo**: Agora precisamos configurar o tomcat para registrar nossas sessões no redis. Vá até o arquivo tomcat/conf/context.xml e adicione o seguinte trecho de código.
![tomcat/conf/context.xml](https://miro.medium.com/max/1400/1*3sljfHyOl3Ta42FSNbsUCQ.png)

Vamos explicar algumas coisas aqui:
**configPath**: local onde o arquivo redisson.yml está localizado
**readMode**: modo de leitura dos atributos da sessão. Seus valores são **MEMORY** (atributos salvos no Redis e no Tomcat) | **REDIS** (atributos salvos somente no Redis)
**updateMode**: modo de atualização dos atributos. Seus valores são **DEFAULT** (os atributos só serão salvos no redis, quando usado o Session.setAttribute) | **AFTER_REQUEST** (todos os atributos serão salvos no Redis após cada requisição)
**keyPrefix**: insere um prefixo na frente de cada chave salva no Redis
**broadcastSessionEvents**: se true vai disparar um evento broadcast para todas as instâncias do tomcat e todas os HttpSessionListeners serão disparados para os eventos de sessionCreated e sessionDestoyed.
---

**4º passo**: Precisamos definir o arquivo redisson.yml. Nele iremos declarar somente o endereço do servidor Redis conforme imagem abaixo.
![redisson.yml](https://miro.medium.com/max/1168/1*_v_3TU6xNumtj84D9WV_pg.png)
No endereço inserido no arquivo **redisson.yml**, eu deixei o ip fixo somente para teste. O ideal é que você use o service discovery do docker. Para mais configurações desse arquivo consulte esse [link](https://github.com/redisson/redisson/wiki/2.-Configuration).
---

**5º passo**: Precisamos inserir as bibliotecas necessárias para a serialização por parte do Redis dentro do nosso Tomcat. São elas a [redisson-all](https://mvnrepository.com/artifact/org.redisson/redisson) e a [redisson-tomcat-9](https://mvnrepository.com/artifact/org.redisson/redisson-tomcat-9). A recomendação é que essas bibliotecas estejam dentro do nosso tomcat/lib.

---
## 4 — Conclusão
Seguido esses passos, e tomando os devidos cuidados, seu sistema está pronto para ser inserido dentro de um container (no caso do docker) e preparado para que um login feito em um dos containers, funcione no outro sem a necessidade de maiores dores de cabeça.

Eu vou ficando por aqui. Deixe seu comentário com críticas, elogios e sugestões. Valeu **_pexadas_**.