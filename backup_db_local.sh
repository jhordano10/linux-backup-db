#!/bin/bash

# ===============================
# Backup de PostgreSQL, MariaDB e arquivos de configuração
# ===============================

# Variáveis
DATA=$(date +%F_%H-%M)
NOME_SERVIDOR=$(hostname)
DIR_BACKUP="/tmp/backup"
DIR_DESTINO="${DIR_BACKUP}/backup_${DATA}"
ARQUIVO_FINAL="${DIR_BACKUP}/backup_${NOME_SERVIDOR}_${DATA}.tar.gz"
USUARIO_PG="postgres"
USUARIO_MYSQL="root"
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Criar diretório de backup, se não existir
if [ ! -d "$DIR_DESTINO" ]; then
    echo "📁 Diretório $DIR_DESTINO não existe. Criando..."
    mkdir -p "$DIR_DESTINO"
else
    echo "📁 Diretório $DIR_DESTINO já existe. Prosseguindo..."
fi

# Backup PostgreSQL
echo "📦 Backup PostgreSQL..."
sudo -u "$USUARIO_PG" /usr/bin/pg_dumpall | tee "${DIR_DESTINO}/postgresql_dump.sql" > /dev/null

# Arquivos de configuração PostgreSQL
echo "🗂️ Copiando configs PostgreSQL..."
cp -r /etc/postgresql/ "${DIR_DESTINO}/etc_postgresql/" 2>/dev/null || true
cp -r /var/lib/pgsql/ "${DIR_DESTINO}/var_lib_pgsql/" 2>/dev/null || true

# Backup MariaDB
echo "📦 Backup MariaDB..."
/usr/bin/mysqldump -u "$USUARIO_MYSQL" --all-databases --single-transaction --routines --triggers > "${DIR_DESTINO}/mariadb_dump.sql"

# Arquivos de configuração MariaDB
echo "🗂️ Copiando configs MariaDB..."
cp -r /etc/mysql/ "${DIR_DESTINO}/etc_mysql/" 2>/dev/null || true
cp -r /etc/my.cnf "${DIR_DESTINO}/my.cnf" 2>/dev/null || true

# Backup das configurações de sudo
echo "🛡️ Copiando arquivos de configuração do sudo..."
cp /etc/sudoers "${DIR_DESTINO}/sudoers" 2>/dev/null || true
cp -r /etc/sudoers.d "${DIR_DESTINO}/sudoers.d" 2>/dev/null || true

# Compactar tudo
echo "📦 Compactando backup..."
tar -czf "$ARQUIVO_FINAL" -C "$DIR_BACKUP" "backup_${DATA}"

# Remover pasta temporária
rm -rf "$DIR_DESTINO"

# Proteção do arquivo de backup
chmod 600 "$ARQUIVO_FINAL"

echo "✅ Backup concluído com sucesso: $ARQUIVO_FINAL"
