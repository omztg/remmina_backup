#!/bin/bash

## Remmina Script de Backup data  ##
echo “Backup Diário”

## Montando a unidade de backup ##
mount -t cifs //172.16.0.53/D /mnt/backup -o user=user,password=passwd

## Criar diretórios usados no backup ##
mkdir /home/user/Documentos/Backup_Remmina/
mkdir /home/user/Documentos/Backup_Remmina/Keyring/
mkdir /home/user/Documentos/Backup_Remmina/Remmina/
mkdir /home/user/Documentos/Backup_Remmina/Cliente/
mkdir /home/user/Documentos/Backup_Remmina/Aplicacoes
chmod 777 /home/user/Documentos/Backup_Remmina/*

## Copiando os arquivos do backup ##
cp -R /home/user/.local/share/keyrings /home/user/Documentos/Backup_Remmina/Keyring/
cp -R /home/user/.local/share/remmina/ /home/user/Documentos/Backup_Remmina/Remmina/
cp -R /home/user/Documentos/Clientes/ /home/user/Documentos/Backup_Remmina/Cliente/
cp -r /home/user/Documentos/NOTAS/ /home/user/Documentos/Backup_Remmina/
cp -r /home/user/.vim/ /home/user/Documentos/Backup_Remmina/Aplicacoes
cp -r /home/user/.ssh/ /home/user/Documentos/Backup_Remmina/Aplicacoes
cp -r /home/user/Documentos/backup_DIARIO.sh /home/user/Documentos/Backup_Remmina/Aplicacoes

## Compactando e limpando o log da execução do script na Crontab ##
if [ -d /var/logs/Backup ] 
then 
    tar czvf /home/user/Documentos/Backup_Remmina/Aplicacoes/Backup_Logs_Cron.tar.gz /var/log/Backup* 
    find /var/log/Backup* -type f -exec bash -c 'cat /dev/null > "$1"' _ {} \;
fi 

## Execução do backup diário ##
#START
TIME=`date +%d-%b-%y`         						# Este comando irá adicionar a data no Nome do Arquivo de Backup.
FILENAME=Backup_DIARIO-$TIME.tar.gz  				# Aqui eu defino o formato do nome do arquivo de backup.
SRCDIR=/home/user/Documentos/Backup_Remmina/    	# Local Fonte     - onde estão os arquivos a serem feitos backup.
DESDIR=/mnt/backup/MEGAsync            		        # Local Destino - onde o Backup será salvo.
tar -cpzf $DESDIR/$FILENAME $SRCDIR
 #END

## Removendo diretórios usados no backup ##
rm -fr /home/user/Documentos/Backup_Remmina

## Update do sistema ##
apt-get update && apt-get full-upgrade -y
apt-get autoremove -y

## Executando limpeza de cache do SO e Logs##
umount /mnt/backup
sleep 180
journalctl --vacuum-time=8d
truncate /var/log/*.log --size 0
rm -f /var/log/*.gz
echo 3 > /proc/sys/vm/drop_caches
systemctl -w vm.drop_caches=3
clear

## Limpa arquivos compactados ##
cd /var/log
compact=`find -name "*.gz" | wc -l`
if [ $compact -gt 0 ]
then

 ##Procura tudo que for .gz log compactatdo dentro do /var/log ##
 compact2=`find -iname "*.gz"`
 #apaga arquivos compactatdos
 for apaga in $compact2
 do
 rm -f $apaga
 done
  
 ## Cria lista de todos os arquivos de log que serao limpos ##
 lista=`find -type f`
 # executa a limpeza dos logs
 for i in $lista
 do
 echo -n >$i &>/dev/null
 done

else

 ## Cria lista de todos os arquivos de log que serao limpos ##
 lista=`find -type f`
 # executa a limpeza dos logs
 for i in $lista
 do
 echo -n >$i &>/dev/null
 done
fi