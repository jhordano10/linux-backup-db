# 🗄️ Backup Local de PostgreSQL e MariaDB em Servidores Linux

Este repositório contém um script em shell que realiza backup local de servidores Linux com **PostgreSQL** e **MariaDB**, incluindo os **bancos de dados** e os **arquivos de configuração dos serviços**.

---

## 📦 O que o script faz?

1. Realiza o dump de **todos os bancos de dados** do PostgreSQL e MariaDB;
2. Copia os arquivos de configuração:
   - PostgreSQL: `/etc/postgresql/`, `/var/lib/pgsql/`
   - MariaDB: `/etc/mysql/`, `/etc/my.cnf`
   - Sudo: `/etc/sudoers`, `/etc/sudoers.d/`
3. Compacta tudo em um arquivo `.tar.gz` com o nome do servidor e data;
4. Gera um arquivo de log `.txt` com dados da execução;
5. **Envia automaticamente os arquivos de backup e log para o Google Drive**, usando `rclone`.

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
- Nome: `gdrive` (ou utilize o nome que preferir)
- Tipo: `drive`
- Configure as credenciais do Google Drive

> Após configurar, o `rclone` poderá enviar arquivos ao seu Drive pessoal

#### Testar envio manual:
```bash
rclone copy arquivo.txt gdrive:diretorio/subdiretorio/de/destino
```

---

## ⏰ Agendamento via `cron`

Edite o crontab com:

```bash
crontab -e
```

Adicione, por exemplo, para rodar diariamente às 2h:

```bash
0 2 * * * /caminho/para/backup_db_local.sh >> /var/log/backup_banco.log 2>&1
```

---

## 🔐 Considerações de segurança

- Proteja o arquivo `.tar.gz` gerado pelo backup:  
  Exemplo:

```bash
chmod 600 backup_nome.tar.gz
chown root:root backup_nome.tar.gz
```

- Nunca deixe a senha do banco exposta em arquivos públicos.

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

---

## 📁 Estrutura do projeto

```
.
├── backup_db_local.sh
└── README.md
```