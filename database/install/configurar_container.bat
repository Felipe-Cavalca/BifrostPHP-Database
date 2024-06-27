@echo off
set caminhoScript1=create_user.sh
set caminhoScript2=config_master.sh

echo Executando o script1 em todos os containers de banco de dados...
for /f "tokens=*" %%i in ('docker ps -q --filter "label=tipo=db"') do (
    echo Executando o script1 no container de banco de dados: %%i
    docker exec %%i /bin/sh %caminhoScript1%
)

echo Aguardando 30 segundos antes de executar o script2...
timeout /t 30

echo Executando o script2 em todos os containers de banco de dados...
for /f "tokens=*" %%i in ('docker ps -q --filter "label=tipo=db"') do (
    echo Executando o script2 no container de banco de dados: %%i
    timeout /t 5
    docker exec %%i /bin/sh %caminhoScript2%
)

echo Todos os scripts foram executados.
