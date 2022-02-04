# blog
Site pessoal


```mermaid
graph LR
    COTAÇÃO --> |chama| MOTOR 
    CONTRATAÇÃO --> |chama| MOTOR 
    ENDOSSO --> |chama| MOTOR 

    MOTOR --> |alertas| COTAÇÃO
    MOTOR --> |ação| CONTRATAÇÃO
    MOTOR --> |ação| ENDOSSO
```
