### DeByte Protocol Network
Ferramenta criada em bash, para automatizar e facilitar a leitura humana em testes de rede, utilizando ferramentas do próprio sistema para os testes.

**Aviso:**
O DPN (DeByte Protocol Network) foi feito exclusivamente para ambientes Linux.

## Objetivo
Facilitar a leitura e automatizar testes de rede de forma leve, utilizando ferramentas do próprio sistema Linux (Como `ping`, `curl` e `getent`).

## Instalação
```bash
git clone https://github.com/Ex3cutor76-V1/DeByte-Protocol-Network.git
cd DPN/
sudo ./install.sh
```

## Comandos

| Comando | Descrição | Exemplo |
|---|---|---|
| `dpn -h` | Exibe a lista de comandos disponíveis | `dpn -h` |
| `dpn -v` | Exibe a versão da ferramenta | `dpn -v` |
| `dpn -c <alvo>` | Realiza teste de conectividade via ping | `dpn -c 8.8.8.8` |
| `dpn -d <domínio>` | Consulta informações DNS IPv4 e IPv6 | `dpn -d google.com` |
| `dpn -hp <url>` | Realiza teste HTTP | `dpn -hp http://example.com` |
| `dpn -hs <url>` | Realiza teste HTTPS e verifica versão TLS | `dpn -hs https://example.com` |
| `dpn -i` | Exibe informações da interface de rede do host | `dpn -i` |
