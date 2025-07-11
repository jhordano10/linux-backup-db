# 🗄️ Backup Local de PostgreSQL e MariaDB em Servidores Linux

Este repositório contém um script em shell que realiza backup local de servidores Linux com **PostgreSQL** e **MariaDB**, incluindo os **bancos de dados**, **arquivos de configuração**, envio automático para o **Google Drive**, e limpeza automática de arquivos antigos.

---

## 📦 O que o script faz?

1. Realiza o dump de **todos os bancos de dados** do PostgreSQL e MariaDB;
2. Copia os arquivos de configuração:
   - PostgreSQL: `/etc/postgresql/`, `/var/lib/pgsql/`
   - MariaDB: `/etc/mysql/`, `/etc/my.cnf`
   - Sudo: `/etc/sudoers`, `/etc/sudoers.d/`
3. Compacta tudo em um arquivo `.tar.gz` com o nome do servidor e data;
4. Gera um arquivo de log `.txt` com dados da execução:
   - Nome do servidor
   - Horário de início e fim
   - Tamanhos dos dumps e do backup final
   - Resultado do envio ao Google Drive
   - Resultados da limpeza local e remota
5. Envia automaticamente os arquivos de backup e log para uma **pasta definida via variável** no Google Drive, utilizando o `rclone`;
6. Remove arquivos locais e no Google Drive com mais de 3 dias automaticamente.

---

## ⚙️ Requisitos

- Shell Bash (Linux)
- PostgreSQL instalado e funcional
- MariaDB ou MySQL instalado e funcional
- `rclone` instalado e configurado com o Google Drive
- Acesso sudo para executar `pg_dumpall` como `postgres`

---

## 🔧 Instalação e configuração

### 1. Clone o repositório

```bash
git clone git@github.com:jhordano10/linux-backup-db.git
cd linux-backup-db
chmod +x backup_db_local.sh
```

### 2. Configure acesso ao PostgreSQL sem senha

Edite o arquivo `sudoers`:

```bash
sudo visudo
```

Adicione a seguinte linha ao final (substitua `SEU_USUARIO` pelo seu nome de usuário):

```bash
SEU_USUARIO ALL=(postgres) NOPASSWD: /usr/bin/pg_dumpall
```

---

### 3. Configure acesso ao MariaDB sem senha

Crie o arquivo `~/.my.cnf`:

```ini
[client]
user=root
password=SUA_SENHA
```

Proteja o arquivo:

```bash
chmod 600 ~/.my.cnf
```

> 💡 Se o script rodar como root, o arquivo deve estar em `/root/.my.cnf`.

---

### 4. Configure o `rclone` para envio ao Google Drive

#### Instalar o `rclone`:
```bash
curl https://rclone.org/install.sh | sudo bash
```

#### Configurar o Google Drive:
```bash
rclone config
```
Responda:
- `n` (novo remote)
- Nome: `gdrive`
- Tipo: `drive`
- Configure as credenciais do Google Drive

> O `rclone` salva as credenciais em: `/home/USUARIO/.config/rclone/rclone.conf`

#### Exemplo de variável de pasta destino no script:
```bash
DIR_GDRIVE="diretorio/subdiretorio/de/destino"
```

#### Envio automático ao Google Drive:
O script usa:
```bash
/usr/bin/rclone copy "$ARQUIVO_FINAL" "gdrive:$DIR_GDRIVE"
/usr/bin/rclone copy "$LOGFILE" "gdrive:$DIR_GDRIVE"
```
E define:
```bash
export RCLONE_CONFIG=/home/USUARIO/.config/rclone/rclone.conf
```

---

## ⏰ Agendamento via `cron`

Edite o crontab com:

```bash
sudo crontab -e
```

Adicione, por exemplo, para rodar diariamente às 2h:

```bash
0 2 * * * /caminho/para/backup_db_local.sh >> /var/log/backup_banco.log 2>&1
```

Certifique-se de que o `HOME`, `PATH` e `RCLONE_CONFIG` estejam definidos corretamente no script, para que o `rclone` funcione no ambiente do cron.

---

## 🧹 Limpeza automática

Ao final da execução, o script remove:
- Arquivos `.tar.gz` e `.txt` no diretório local com mais de 3 dias, usando `find`:

```bash
find "$DIR_BACKUP" -type f \( -name "*.tar.gz" -o -name "*.txt" \) -mtime +3 -exec rm -f {} \;
```

- Arquivos no Google Drive com mais de 72 horas, usando:

```bash
/usr/bin/rclone delete --min-age 72h "gdrive:$DIR_GDRIVE"
```

Você pode verificar antes com:

```bash
/usr/bin/rclone ls --min-age 72h "gdrive:$DIR_GDRIVE"
```

---

## ✅ Exemplo de saída do backup

```bash
/tmp/backup/backup_nome-do-servidor_2025-07-09_02-00.tar.gz
/tmp/backup/log_backup_nome-do-servidor_2025-07-09_02-00.txt
```
E os arquivos são enviados automaticamente para:
```bash
gdrive:diretorio/subdiretorio/de/destino
```
(Ou para a pasta que você configurar com a variável `DIR_GDRIVE`)

---

## 📁 Estrutura do projeto

```
.
├── backup_db_local.sh
└── README.md
```
