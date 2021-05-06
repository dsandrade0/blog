---
title: Nginx ou Apache??
date: 2016-12-25 02:06:52
tags: webserver
---

Quando vamos trabalhar com sistemas web, temos algumas preocupações a serem levadas em consideração. Uma delas é qual servidor web utilizar? E de primeira me vinham dois servidores, Apache e Nginx.

Durante algum tempo me fiz essa pergunta. Qual o melhor servidor, Nginx ou Apache?
Primeiro vamos deixar uma coisa bem clara. Qualquer um destes servidores certamente irá servir para seu projeto sem sombras de dúvidas. Porém alguns detalhes desses servidores web, precisam ser entendidos antes de iniciar o seu projeto.

Aqui vamos mostrar alguns pontos positivos que podem ser utilizados por você para decidir qual servidor irá utilizar em seu projeto, seja ele pessoal ou profissional.

# 1 - Instalação
O primeiro passo é a instalação. Não queremos perder muito tempo para poder instalar e configurar um projeto seja ele em qualquer plataforma de programação back-end.

### Apache
Na maioria dos sistemas operacionais do pinguin (Linux), o Apache já está disponível de forma nativa, bastando apenas startar e utilizar.

### Nginx
Apesar de não aparecer como nativo na maioria das distribuições Linux, o Nginx não é de difícil instalação. Basicamente se resume em:

``` sh
#para distribuições  Debian | Ubuntu ...
sudo apt-get install nginx

#para distribuições  Redhat | CentOS ...
sudo yum install nginx
```
# 2 - Compressão de arquivos
Uma coisa bem interessante nos servidores web atuais, é a capacidade de comprimir alguns dados antes de enviar do servidor para o cliente. Isso faz com que o carregamento aconteça de forma mais rápida. Como alguns dados trafegam na rede compactados, eles passam a ter um tamanho menor

Ambos os servidores web cumprem bem esse requisito. E possuem uma forma bem fácil de dizer que queremos ativar essa função.

``` sh
# Configuração no Apache
AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript
```
``` sh
# Configuração no Nginx
server {
	gzip on;
	gzip_types      text/plain application/xml text/javascript text/css text/plain text/html;
	...
}
```

# 3 - Velocidade
Neste tópico as coisas começam a esquentar. Embora o Apache tenha muito mais tempo de mercado, o **Nginx** leva muita vantagem nesse quesito. Isso só é possível graças ao socket assíncrono que utiliza e não espalha processos como o Apache faz. Somente isso é capaz de fazer com que o Nginx dê conta de milhares de requisições simultâneas.

# 4 - Modularidade
Aqui o Apache dá um banho no Nginx. A experiência do Apache no mercado faz com que os usuários consigam desenvolver complementos e módulos para serem carregados dinamicamente pelo servidor, bastando apenas especificar no seu arquivo de configuração que deseja utilizar os módulos e a mágica acontece.

# 5 - HTTPS
Ambos possuem suporte a este protocolo de forma fácil e sem complicações, porém o **Apache**, por ter mais tempo no mercado e ainda dominar o mercado, possui um grande número de exemplos e de tutoriais disponíveis na internet.

# Conclusão

Então mais uma vez chegamos a uma conclusão inconclusiva. Dependendo da sua experiência no mundo dos webservers,  pode fazer você escolher o servidor que já tem mais custume.
Porém se pretende ter escalabilidade no seu projeto, é altamente recomendado o **Nginx**, porque aguenta bem o tranco. Porém o Apache também pode ser utilizado de forma escalável, mas você precisaria de um pouco de experiência com este servidor web.

Tente teste e descubra o que melhor se adequa a sua necessidade.

Ficamos por aqui e até breve!!!!
