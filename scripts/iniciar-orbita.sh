#!/bin/sh
# Sobe a API (8080) e a WebUI (8501) no mesmo contêiner do Nossa Órbita.
#
# A API é o que o Órbita Digital chama, sem domínio. A WebUI é para o operador
# e NÃO tem login: o domínio dela no Easypanel precisa de Basic Auth, porque a
# tela de configurações mostra as chaves do config.toml.
#
# Se um dos dois processos morrer, o script sai e o Easypanel reinicia o
# contêiner inteiro: melhor que ficar com a API de pé e a WebUI morta, ou o
# contrário, sem ninguém perceber.

python3 main.py &
API=$!

streamlit run ./webui/Main.py \
  --server.address=0.0.0.0 \
  --server.port=8501 \
  --server.headless=true \
  --browser.gatherUsageStats=False \
  --client.toolbarMode=minimal \
  --logger.hideWelcomeMessage=True \
  --server.showEmailPrompt=False &
WEBUI=$!

trap 'kill "$API" "$WEBUI" 2>/dev/null' TERM INT

while kill -0 "$API" 2>/dev/null && kill -0 "$WEBUI" 2>/dev/null; do
  sleep 5
done

echo "iniciar-orbita: um dos processos parou (API=$API, WebUI=$WEBUI); encerrando." >&2
kill "$API" "$WEBUI" 2>/dev/null
exit 1
