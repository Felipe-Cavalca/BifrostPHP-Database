# Instalação

## Passo a Passo

1. Executar o Script de Atualização:

    Com o ambiente rodando, você pode usar o comando abaixo para executar o script [`update.sh`](../update.sh):

    ```bash
    docker exec database1 /bin/bash /scripts/update.sh
    ```

    Esse script irá listar todos os arquivos `.sql` dentro da pasta [`/update`](../update/) e executá-los no banco de dados.

2. Comandos de Banco de Dados:

    Em caso de sucesso, será feito o `commit` das alterações.

    Em caso de falha, será feito o `rollback` para garantir que o banco de dados não fique em um estado inconsistente.

## Criando Scripts `SQL` Personalizados

Você pode criar scripts `SQL` personalizados para configurar o banco de dados de acordo com suas necessidades. Siga os passos abaixo para adicionar seus scripts:

1. Criar um Novo Script `SQL`:

    Crie um novo arquivo `.sql` dentro da pasta [`/update`](../update/). Por exemplo, `meu_script.sql`.

2. Estrutura do Script:

    Certifique-se de que seu script siga a estrutura correta de comandos `SQL` para a operação desejada.

    Aqui está um exemplo de um script

    ```sql
    ALTER TABLE users ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER updated_ad;
    ```

3. Adicionar o Script:

    Salve o arquivo na pasta [`/update`](../update/).

4. Executar o Script:

    O script [`update.sh`](../update.sh) automaticamente detectará e executará todos os arquivos `.sql` na pasta [`/update`](../update/) na próxima vez que você executar o comando:

    ```bash
    docker exec database1 /bin/bash /scripts/update.sh
    ```
