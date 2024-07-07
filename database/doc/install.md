# Instalação

## Passo a Passo

1. Subir o Ambiente:

    Primeiro, execute o comando `docker-compose up` para subir o ambiente Docker.

2. Executar o Script de Instalação:

    Após subir o ambiente, use o comando abaixo para executar o script [`install.sh`](../install.sh):

    ```bash
    docker exec database1 /bin/bash /scripts/install.sh
    ```

    Esse script irá listar todos os arquivos `.sql` dentro da pasta [`/install`](../install/) e executá-los no banco de dados.

3. Comandos de Banco de Dados:

    Em caso de sucesso, será feito o `commit` das alterações.

    Em caso de falha, será feito o `rollback` para garantir que o banco de dados não fique em um estado inconsistente.

## Criando Scripts `SQL` Personalizados

Você pode criar scripts `SQL` personalizados para configurar o banco de dados de acordo com suas necessidades. Siga os passos abaixo para adicionar seus scripts:

1. Criar um Novo Script `SQL`:

    Crie um novo arquivo `.sql` dentro da pasta [`/install`](../install/). Por exemplo, `meu_script.sql`.

2. Estrutura do Script:

    Certifique-se de que seu script siga a estrutura correta de comandos `SQL` para a operação desejada.

    Aqui está um exemplo de um script que cria uma tabela simples:

    ```sql
    CREATE TABLE exemplo (
        id INT PRIMARY KEY,
        nome VARCHAR(100)
    );
    ```

3. Adicionar o Script:

    Salve o arquivo na pasta [`/install`](../install/).

4. Executar o Script:

    O script [`install.sh`](../install.sh) automaticamente detectará e executará todos os arquivos `.sql` na pasta [`/install`](../install/) na próxima vez que você executar o comando:

    ```bash
    docker exec database1 /bin/bash /scripts/install.sh
    ```
