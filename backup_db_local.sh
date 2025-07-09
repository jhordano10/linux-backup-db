#!/bin/bash

# =============================================
# SCRIPT DE BACKUP LOCAL - PostgreSQL e MariaDB
# =============================================
# Autor: Jhordano Malacarne Bravim
# Descrição: Este script realiza o backup completo
#            dos bancos PostgreSQL e MariaDB, incluindo
#            arquivos de configuração e geração de log.
# Execução: Pode ser agendado via cron.
# Saída: Arquivo .tar.gz com o nome do servidor e timestamp
# Log: Arquivo .txt contendo informações da execução
# =============================================

# Variáveis
DATA=$(date +%F_%H-%M)
NOME_SERVIDOR=$(hostname)
DIR_BACKUP="/tmp/backup"
DIR_DESTINO="${DIR_BACKUP}/backup_${DATA}"
DIR_GDRIVE="diretorio/subdiretorio/destino"
ARQUIVO_FINAL="${DIR_BACKUP}/backup_${NOME_SERVIDOR}_${DATA}.tar.gz"
LOGFILE="${DIR_BACKUP}/log_backup_${NOME_SERVIDOR}_${DATA}.txt"
USUARIO_PG="postgres"
USUARIO_MYSQL="root"
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Início do log
echo "🔒 Servidor: $NOME_SERVIDOR" > "$LOGFILE"
echo "🕒 Início do backup: $(date)" >> "$LOGFILE"

# Criar diretório de backup
if [ ! -d "$DIR_DESTINO" ]; then
    echo "📁 Criando diretório $DIR_DESTINO"
    mkdir -p "$DIR_DESTINO"
else
    echo "📁 Diretório $DIR_DESTINO já existe"
fi

# Backup PostgreSQL
echo "📦 Backup PostgreSQL..."
sudo -u "$USUARIO_PG" /usr/bin/pg_dumpall > "${DIR_DESTINO}/postgresql_dump.sql"
TAM_PG=$(du -m "${DIR_DESTINO}/postgresql_dump.sql" | cut -f1)
echo "📄 Tamanho do dump PostgreSQL: ${TAM_PG} MB" >> "$LOGFILE"

# Arquivos de configuração PostgreSQL
cp -r /etc/postgresql/ "${DIR_DESTINO}/etc_postgresql/" 2>/dev/null || true
cp -r /var/lib/pgsql/ "${DIR_DESTINO}/var_lib_pgsql/" 2>/dev/null || true

# Backup MariaDB
echo "📦 Backup MariaDB..."
/usr/bin/mysqldump --all-databases --single-transaction --routines --triggers > "${DIR_DESTINO}/mariadb_dump.sql"
TAM_MYSQL=$(du -m "${DIR_DESTINO}/mariadb_dump.sql" | cut -f1)
echo "📄 Tamanho do dump MariaDB: ${TAM_MYSQL} MB" >> "$LOGFILE"

# Arquivos de configuração MariaDB
cp -r /etc/mysql/ "${DIR_DESTINO}/etc_mysql/" 2>/dev/null || true
cp -r /etc/my.cnf "${DIR_DESTINO}/my.cnf" 2>/dev/null || true

# Backup das configurações de sudo
cp /etc/sudoers "${DIR_DESTINO}/sudoers" 2>/dev/null || true
cp -r /etc/sudoers.d "${DIR_DESTINO}/sudoers.d" 2>/dev/null || true

# Compactar tudo
echo "📦 Compactando backup..."
tar -czf "$ARQUIVO_FINAL" -C "$DIR_BACKUP" "backup_${DATA}"

# Verificar tamanho do arquivo compactado
TAM_FINAL=$(du -m "$ARQUIVO_FINAL" | cut -f1)
echo "🗜️ Tamanho do backup compactado: ${TAM_FINAL} MB" >> "$LOGFILE"

# Limpar diretório temporário
rm -rf "$DIR_DESTINO"

# Final do log
echo "✅ Backup concluído em: $(date)" >> "$LOGFILE"

# Enviar arquivos para o Google Drive via rclone
echo "📤 Enviando arquivos para Google Drive..."

rclone copy "$ARQUIVO_FINAL" "gdrive:$DIR_GDRIVE"

if [ $? -eq 0 ]; then
    echo "✅ Envio concluído com sucesso."
    echo "✅ Envio concluído com sucesso." >> "$LOGFILE"
else
    echo "❌ Falha no envio para o Google Drive."
    echo "❌ Falha no envio para o Google Drive." >> "$LOGFILE"
fi

rclone copy "$LOGFILE" "gdrive:$DIR_GDRIVE"