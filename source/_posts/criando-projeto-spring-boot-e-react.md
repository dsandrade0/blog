---
title: Criando um projeto com Spring Boot e React
date: 2021-05-10 20:22:20
tags: [desenvolvimento, java, react]
---

![slogan](https://miro.medium.com/max/1228/1*CdMsiQpKpyy1wja9sElnVQ.png)

Cada dia mais, a combinação de Spring Boot + ReactJS está dominando o mercado. E como separar meu projeto em backend e frontend, e juntar no build???

Precisei fazer isso a um tempo atrás e decidi postar a solução. Então, mãos à obra.

---

O primeiro passo é ir até http://start.spring.io para gerar nosso projeto Spring Boot. E para efeitos práticos vamos direto ao ponto. Vamos utilizar o Maven para cuidar do nosso build, então selecione o Maven Project. Na sessão das dependências vamos selecionar "web" como na imagem abaixo:
![dependencias](https://miro.medium.com/max/1400/1*wnnPxSiF9zqOft5pp4TDSg.png)
Isso será necessário para configurar nosso projeto. Agora basta clicar em "Generate the project" para baixar o projeto configurado.

Para faciliar nosso entendimento, crie uma pasta com um nome da sua preferência, no meu caso vou colocar o nome de "Aula". Descompacte o arquivo do projeto gerado pelo site, dentro da sua pasta e renomei-o para "backend".

O próximo passo é criar o nosso projeto ReactJS. Para isso é preciso ter o [NodeJS](https://nodejs.org/en/) instalado. Depois de instalado o gerenciador de pacote NPM estará instalado, então vamos rodar o seguinte comando em nosso terminal:
```
npm install create-react-app -g
```
O create-react-app foi criado para faciliar a criação de um projeto ReactJS, então não vamos destrinchar ele, basta usar. É importante notar que o parâmetro "-g" será necessário para que possamos instalar o create-react-app de forma global, e poder usar ele em qualquer diretório do nosso sistema operacional.

Agora basta agente navegar pelo terminal até a pasta onde está nosso backend, no meu caso na pasta "Aula" e rodar o seguinte comando:
```
create-react-app frontend
```
Depois desse comando, nosso diretório ficará mais ou menos assim.
![diretorio](https://miro.medium.com/max/1400/1*Sc9veaefbTMYqfeYEQsH6w.png)

Agora abra a IDE java de sua preferência. Como estamos usando Maven, o ideal é que sua IDE tenha suporte a ele. Eu utilizo o IntelliJ, então basta importar o projeto do backend para dentro da sua IDE e vamos começar a brincadeira.

Basicamente o que temos que fazer é dentro da pasta backend, abra o arquivo pom.xml. Dentro dele está a definição de dependências, informações do seu projeto spring boot e etc. Mas estamos interessados na sessão build, para automatizar e configurar nosso projeto React junto com o spring.

Vamos adicionar o seguinte plugin abaixo:
```
<plugin>
   <groupId>com.github.eirslett</groupId>
   <artifactId>frontend-maven-plugin</artifactId>
   <version>1.6</version>
   <configuration>
       <workingDirectory>../frontend/</workingDirectory>
       <installDirectory>target</installDirectory>
   </configuration>
   <executions>
       <execution>
           <id>install node and npm</id>
           <goals>
               <goal>install-node-and-npm</goal>
           </goals>
           <configuration>
               <nodeVersion>v8.11.3</nodeVersion>
               <npmVersion>5.6.0</npmVersion>
           </configuration>
       </execution>
       <execution>
           <id>npm install</id>
           <goals>
               <goal>npm</goal>
           </goals>
           <configuration>
               <arguments>install</arguments>
           </configuration>
       </execution>
       <execution>
           <id>npm run build</id>
           <goals>
               <goal>npm</goal>
           </goals>
           <configuration>
               <arguments>run build</arguments>
           </configuration>
       </execution>
   </executions>
</plugin>
```
Vamos destrinchar esse plugin? O que esse plugin vai fazer na verdade é se certificar que na máquina onde será feito o build da nossa aplicação, contenha os requisitos necessários para rodar o nosso build. Então caso não tenha o nodeJS nem o NPM, ele irá se encarregar de fazer isso pra você. Nas linhas 16 e 17 você pode especificar uma versão tanto do nodeJS quanto do NPM caso deseje.

Apos instalar, o plugin também irá rodar o comando "npm build" na nossa pasta frontend, isso garantirá que nosso frontend seja comiplado e minificado segundo as regras do ReactJS.

Nosso segundo e ultimo plugin, simplesmente colocará o nosso frontend no local correto para que o Spring Boot possa subir junto com seu servidor de aplicação. Segue o plugin.
```
<plugin>
  <artifactId>maven-antrun-plugin</artifactId>
  <executions>
      <execution>
          <phase>generate-resources</phase>
          <configuration>
              <target>
                  <copy todir="${project.build.directory}/classes/static">
                      <fileset dir="${project.basedir}/../frontend/build" />
                  </copy>
              </target>
          </configuration>
          <goals>
              <goal>run</goal>
          </goals>
      </execution>
  </executions>
</plugin>
```
Esse segundo plugin simplesmente irá pegar a pasta gerada pelo build feito na pasta frontend e irá colocar na pasta static do nosso spring, onde a parte Web precisa está para funcionar corretamente.

Com esses dois plugins no devido lugar, basta agora a gente ir ao terminal, navegar até a pasta do nosso backend, e rodar o comando:
```
mvn clean package
```
Esse comando vai se encarregar de chamar nossos alvos do Maven para construir o nosso build de forma correta.

Ao final desse processo, foi criado uma pasta target dentro do nosso backend, e dentro um Jar contendo o nome do projeto que você colocou no site do spring. Agora para finalizar, basta rodar o segunte comando na pasta target.
```
java -jar nomeDoSeArquivo.jar
```
Vá até o seu navegador e digite http://localhost:8080/ e veja seu backend e frontend funcionando perfeitamente.

Agora você pode perfeitamente ter dois times separados, um trabalhando no frontend e outro trabalhando no backend de forma simultânea e no fim o build se encarrega de colocar todo mundo junto num unico jar.

Bom pessoal, espero que tenham gostado desse pequeno tutorial. O primeiro de muitos. Nos vemos em breve **_pexadas_**.
