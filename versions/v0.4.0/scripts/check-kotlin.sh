#!/usr/bin/env bash
# schematize-kotlin — o gate. Cobra o piso de `references/piso.md` sobre o Kotlin do repo.
#
# HONESTIDADE SOBRE O ALCANCE: este gate é TEXTUAL — ele não compila e não roda o R8. Onde
# existirem `ktlint`/`detekt` e o compilador, são ELES que mandam, e o gate diz isso na saída.
#
# strict-ok: COLETOR — varre tudo e soma os achados (`schematize-shell` -> `references/piso.md` secao 1)
set -uo pipefail

raiz="${1:-.}"
erros=(); avisos=()

arquivos=()
while IFS= read -r -d '' f; do arquivos+=("$f"); done < <(
  find "$raiz" -type f \( -name '*.kt' -o -name '*.kts' \) \
    -not -path '*/build/*' -not -path '*/.git/*' -not -path '*/.gradle/*' \
    -not -path '*/versions/*' -print0 2>/dev/null
)
manifestos=()
while IFS= read -r -d '' f; do manifestos+=("$f"); done < <(
  find "$raiz" -type f -name 'AndroidManifest.xml' -not -path '*/build/*' -print0 2>/dev/null
)

if [ "${#arquivos[@]}" -eq 0 ] && [ "${#manifestos[@]}" -eq 0 ]; then
  echo "✖ nenhum .kt/.kts nem AndroidManifest.xml em $raiz — nada para verificar (ausência de material não é aprovação)." >&2
  exit 2
fi

command -v ktlint >/dev/null 2>&1 || command -v detekt >/dev/null 2>&1 \
  || avisos+=("ktlint/detekt ausentes nesta máquina: o gate rodou só as regras TEXTUAIS. Onde houver, são eles que mandam")

for f in "${arquivos[@]}"; do
  nome="${f#"$raiz"/}"
  ehTeste=0; case "$nome" in *[Tt]est*|*/androidTest/*) ehTeste=1 ;; esac
  # ordem: string primeiro, comentário depois (o `//` dentro de string truncaria a linha)
  codigo="$(sed -e 's/"[^"]*"/""/g' -e 's|//.*$||' "$f")"

  if [ "$ehTeste" = 0 ]; then
    # `[]A-Za-z_)]` com o `]` PRIMEIRO: dentro de uma classe POSIX a barra invertida é LITERAL, então
    # `[A-Za-z_)\]]` exigia um `]` logo depois da classe — e a regra nunca casava. Gate cego não
    # reprova nada e parece verde.
    grep -qE '[]A-Za-z_)]!![]. ),;]|[]A-Za-z_)]!!$' <<< "$codigo" \
      && erros+=("$nome: usa \`!!\` — é um NullPointerException que você escolheu; use \`?:\`, \`?.\` ou requireNotNull(x) { \"por quê\" }")
    grep -qE '\brunBlocking\b' <<< "$codigo" \
      && erros+=("$nome: \`runBlocking\` fora de teste/main — em app ele trava a thread principal (piso.md secao 2)")
  fi
  grep -qE '\bGlobalScope\b' <<< "$codigo" \
    && erros+=("$nome: \`GlobalScope\` — não é cancelado por nada: a corrotina sobrevive à tela que a criou (vazamento clássico do Android)")
  grep -qE 'catch\s*\([^)]*\)\s*\{\s*\}' <<< "$codigo" \
    && erros+=("$nome: \`catch { }\` vazio — erro engolido")
  grep -qE 'catch\s*\(\s*[a-z]+\s*:\s*(Exception|Throwable)\s*\)' <<< "$codigo" \
    && ! grep -qE 'CancellationException' "$f" \
    && avisos+=("$nome: \`catch (e: Exception/Throwable)\` sem tratar \`CancellationException\` — engolir o cancelamento transforma \"a tela fechou\" em erro de negócio")
  grep -qE '\brunCatching\b' <<< "$codigo" \
    && ! grep -qE 'CancellationException' "$f" \
    && avisos+=("$nome: \`runCatching\` engole tudo, inclusive \`CancellationException\` — relance-o em corrotina")
  grep -qE '\blateinit var\b' <<< "$codigo" \
    && avisos+=("$nome: \`lateinit\` — só onde o ciclo de vida garante a inicialização; o erro dele não diz mais que um NPE")
  grep -qE 'SharedPreferences' <<< "$codigo" \
    && grep -qiE 'token|senha|password|secret' "$f" \
    && erros+=("$nome: credencial em \`SharedPreferences\` — é XML EM CLARO; use EncryptedSharedPreferences/Keystore")
  grep -qE 'addJavascriptInterface' <<< "$codigo" \
    && erros+=("$nome: \`addJavascriptInterface\` — ponte de execução: VETADO com conteúdo remoto")
  grep -qE 'setJavaScriptEnabled\s*\(\s*true' <<< "$codigo" \
    && avisos+=("$nome: \`setJavaScriptEnabled(true)\` — só com conteúdo próprio")
  grep -qE 'when\s*\(' <<< "$codigo" && grep -qE '\bsealed\b' "$f" && grep -qE '^\s*else\s*->' <<< "$codigo" \
    && avisos+=("$nome: \`when\` sobre sealed com \`else\` — o dia em que alguém acrescentar um caso, o compilador CALA")
done

for m in "${manifestos[@]:-}"; do
  [ -n "$m" ] || continue
  nome="${m#"$raiz"/}"
  grep -qE 'android:allowBackup="true"' "$m" \
    && avisos+=("$nome: \`allowBackup=\"true\"\` — copia dado do app para fora; decida, não herde o default")
  # componente com intent-filter e SEM exported explícito
  if grep -qE '<intent-filter' "$m" && ! grep -qE 'android:exported=' "$m"; then
    erros+=("$nome: componente com intent-filter e SEM \`android:exported\` explícito — é obrigatório desde a API 31 e é superfície de ataque")
  fi
  grep -qE 'android:usesCleartextTraffic="true"' "$m" \
    && erros+=("$nome: \`usesCleartextTraffic=\"true\"\` — HTTP em claro no app inteiro")
done

for a in "${avisos[@]:-}"; do [ -n "$a" ] && echo "  ! $a" >&2; done
if [ "${#erros[@]}" -gt 0 ]; then
  echo "" >&2
  echo "✖ KOTLIN REPROVADO — ${#erros[@]} problema(s):" >&2
  for e in "${erros[@]}"; do echo "  · $e" >&2; done
  exit 1
fi
echo "✔ kotlin: ${#arquivos[@]} fonte(s) e ${#manifestos[@]} manifesto(s) nas regras textuais do piso."
