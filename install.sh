#!/usr/bin/env bash

# Cores
VERMELHO=$'\033[31m'
VERDE=$'\033[32m'
CIANO=$'\033[36m'
AMARELO=$'\033[33m'
RESET=$'\033[0m'

# Variáveis importantes

APP_NAME="DPN"

INSTALL_DIR="/opt/$APP_NAME"
BIN_PATH="/usr/local/bin/dpn"

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMP_DIR="$(mktemp -d)"

ZIP_FILE="DPN.zip"

# Limpeza

cleanup() {
    rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

# Função

erro() {
    printf "${VERMELHO}[ERRO]${RESET} %s\n" "$1"
    exit 1
}

info() {
    printf "${CIANO}[*]${RESET} %s\n" "$1"
}

sucesso() {
    printf "${VERDE}[+]${RESET} %s\n" "$1"
}

aviso() {
    printf "${AMARELO}[!]${RESET} %s\n" "$1"
}

# Verificação Root

if [[ "$EUID" -ne 0 ]]; then
    erro "Execute o instalador como root.

Use:

    sudo ./install.sh"
fi

printf "${AMARELO}========================================${RESET}\n"
printf "${AMARELO}       DPN - Instalação do DPN        ${RESET}\n"
printf "${AMARELO}========================================${RESET}\n\n"

# Procurando arquivo zip

info "Procurando pacote ZIP..."

mapfile -t ZIP_FILES < <(
    find "$BASE_DIR" \
        -maxdepth 1 \
        -type f \
        -iname "*.zip" \
        -print
)

if [[ "${#ZIP_FILES[@]}" -eq 0 ]]; then
    erro "Nenhum arquivo ZIP encontrado em:

$BASE_DIR"
fi

if [[ "${#ZIP_FILES[@]}" -gt 1 ]]; then
    erro "Mais de um arquivo ZIP foi encontrado.

Deixe apenas o pacote do DPN no diretório do instalador."
fi

ZIP_FILE="${ZIP_FILES[0]}"

sucesso "Pacote encontrado: $(basename "$ZIP_FILE")"

# Verificação do unzip

info "Verificando dependência: unzip"

if ! command -v unzip >/dev/null 2>&1; then
    erro "O comando 'unzip' não está instalado.

Instale o unzip e execute o instalador novamente."
fi

sucesso "unzip encontrado."

# Extração de pacotes

info "Extraindo pacote..."

unzip -q "$ZIP_FILE" -d "$TEMP_DIR"

sucesso "Pacote extraído."

# Localizar script dpn.sh

info "Procurando dpn.sh..."

DPN_SCRIPT=$(find "$TEMP_DIR" \
    -type f \
    -name "dpn.sh" \
    -print -quit)

if [[ -z "$DPN_SCRIPT" ]]; then
    erro "dpn.sh não encontrado dentro do pacote."
fi

PACKAGE_DIR="$(dirname "$DPN_SCRIPT")"

sucesso "dpn.sh encontrado."

# Verificação de diretórios do script

if [[ ! -d "$PACKAGE_DIR/scripts" ]]; then
    erro "Diretório 'scripts' não encontrado no pacote."
fi

sucesso "Diretório scripts encontrado."

# scripts obrigatórios da ferramenta

REQUIRED_SCRIPTS=(
    "dns.sh"
    "http.sh"
    "https.sh"
    "interface.sh"
    "ping.sh"
)

info "Verificando scripts..."

for script in "${REQUIRED_SCRIPTS[@]}"; do

    if [[ ! -f "$PACKAGE_DIR/scripts/$script" ]]; then
        erro "Script obrigatório não encontrado:

scripts/$script"
    fi

    sucesso "$script encontrado."

done

# Verificação de dependências

printf "\n"
info "Verificando dependências do sistema..."

DEPENDENCIES=(
    "bash"
    "curl"
    "getent"
    "ping"
    "ip"
)

MISSING=()

for command in "${DEPENDENCIES[@]}"; do

    if ! command -v "$command" >/dev/null 2>&1; then
        MISSING+=("$command")
    fi

done

if [[ "${#MISSING[@]}" -gt 0 ]]; then

    printf "\n"

    aviso "As seguintes dependências não foram encontradas:"

    for dependency in "${MISSING[@]}"; do
        printf "    - %s\n" "$dependency"
    done

    printf "\n"

    erro "Instale as dependências acima e execute o instalador novamente."

fi

sucesso "Todas as dependências foram encontradas."

# Instalação

printf "\n"
info "Preparando instalação..."

rm -rf "$INSTALL_DIR"

mkdir -p "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/scripts"

info "Copiando dpn.sh..."

cp "$DPN_SCRIPT" "$BIN_PATH"

info "Copiando scripts..."

cp -r "$PACKAGE_DIR/scripts/." "$INSTALL_DIR/scripts/"

# Permissões

info "Configurando permissões..."

chmod +x "$BIN_PATH"

find "$INSTALL_DIR/scripts" \
    -type f \
    -name "*.sh" \
    -exec chmod +x {} \;

# Verificação final

printf "\n"
info "Verificando instalação..."

if [[ ! -f "$BIN_PATH" ]]; then
    erro "Falha ao instalar o executável."
fi

if [[ ! -d "$INSTALL_DIR/scripts" ]]; then
    erro "Falha ao instalar os scripts."
fi

for script in "${REQUIRED_SCRIPTS[@]}"; do

    if [[ ! -f "$INSTALL_DIR/scripts/$script" ]]; then
        erro "Falha ao instalar scripts/$script"
    fi

done

# Final da instalação

printf "\n"
printf "${VERDE}========================================${RESET}\n"
printf "${VERDE}       DPN instalado com sucesso!      ${RESET}\n"
printf "${VERDE}========================================${RESET}\n\n"

printf "${CIANO}Instalação:${RESET}\n"
printf "  %s\n\n" "$INSTALL_DIR"

printf "${CIANO}Executável:${RESET}\n"
printf "  %s\n\n" "$BIN_PATH"

printf "${CIANO}Execute:${RESET}\n"
printf "  dpn -h\n\n"

printf "${VERDE}Pronto!${RESET}\n"

# Auto limpeza do instalador

printf "\n"
info "Removendo arquivos de instalação..."

rm -f "$BASE_DIR/install.sh"
rm -f "$ZIP_FILE"

sucesso "Arquivos temporários removidos."
