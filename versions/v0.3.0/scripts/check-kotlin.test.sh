#!/usr/bin/env bash
# Vermelho primeiro do gate de Kotlin.
#
# strict-ok: harness de teste — continua depois de um caso vermelho (`schematize-shell` -> `references/piso.md` secao 1)
set -u
AQUI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
G="$AQUI/check-kotlin.sh"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT INT TERM
ok=0; fail=0
caso() {
  local nome="$1" esp="$2" agulha="$3" arq="${4:-Alvo.kt}"
  local d="$TMP/$nome"; mkdir -p "$d"; cat > "$d/$arq"
  local saida; saida="$(bash "$G" "$d" 2>&1)"; local rc=$?
  if [ "$rc" != "$esp" ]; then echo "  ✖ $nome: exit $rc, esperado $esp"; sed 's/^/      /' <<<"$saida"; fail=$((fail+1)); return; fi
  if [ -n "$agulha" ] && ! grep -qF -- "$agulha" <<<"$saida"; then echo "  ✖ $nome: exit certo, saída sem \"$agulha\""; sed 's/^/      /' <<<"$saida"; fail=$((fail+1)); return; fi
  echo "  ✔ $nome"; ok=$((ok+1))
}

echo "== verde de partida =="
caso verde 0 "regras textuais do piso" <<'FIX'
package exemplo

import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.withContext

sealed interface Estado {
    data object Carregando : Estado
    data class Pronto(val itens: List<String>) : Estado
    data class Falhou(val causa: String) : Estado
}

class Repositorio(private val io: kotlinx.coroutines.CoroutineDispatcher) {
    suspend fun buscar(id: String): Result<String> = withContext(io) {
        runCatching { chamar(id) }.onFailure { if (it is CancellationException) throw it }
    }

    private fun chamar(id: String): String = id.ifEmpty { error("id vazio") }
}
FIX

echo "== nulabilidade e corrotina =="
caso bang-bang 1 "NullPointerException que você escolheu" <<'FIX'
package exemplo
fun nome(u: Usuario?): String = u!!.nome
FIX
caso globalscope 1 "sobrevive à tela" <<'FIX'
package exemplo
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
fun sincronizar() { GlobalScope.launch { baixar() } }
FIX
caso runblocking 1 "trava a thread principal" <<'FIX'
package exemplo
import kotlinx.coroutines.runBlocking
fun carregar() = runBlocking { baixar() }
FIX

echo "== erro engolido =="
caso catch-vazio 1 "erro engolido" <<'FIX'
package exemplo
fun salvar() {
    try { gravar() } catch (e: java.io.IOException) { }
}
FIX

echo "== segurança do cliente =="
caso prefs-com-token 1 "XML EM CLARO" <<'FIX'
package exemplo
import android.content.SharedPreferences
fun guardar(prefs: SharedPreferences, token: String) {
    prefs.edit().putString("token", token).apply()
}
FIX
caso js-interface 1 "ponte de execução" <<'FIX'
package exemplo
fun montar(web: android.webkit.WebView) {
    web.addJavascriptInterface(Ponte(), "android")
}
FIX

echo "== manifesto =="
caso exported-implicito 1 "exported" "AndroidManifest.xml" <<'FIX'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <application android:label="app">
    <activity android:name=".MainActivity">
      <intent-filter>
        <action android:name="android.intent.action.MAIN" />
      </intent-filter>
    </activity>
  </application>
</manifest>
FIX
caso cleartext 1 "HTTP em claro" "AndroidManifest.xml" <<'FIX'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <application android:usesCleartextTraffic="true" android:exported="false" />
</manifest>
FIX

echo "== teste pode usar !! =="
caso bang-em-teste 0 "" "RepositorioTest.kt" <<'FIX'
package exemplo
import kotlin.test.Test
class RepositorioTest {
    @Test fun busca() {
        val r = mapOf("a" to 1)["a"]!!
        assert(r == 1)
    }
}
FIX

echo "== nada para verificar =="
d="$TMP/vazio"; mkdir -p "$d"; echo "# prosa" > "$d/LEIA.md"
saida="$(bash "$G" "$d" 2>&1)"; rc=$?
if [ "$rc" = 2 ] && grep -q "não é aprovação" <<<"$saida"; then echo "  ✔ repo sem Kotlin sai 2 (não 0)"; ok=$((ok+1))
else echo "  ✖ repo sem Kotlin: exit $rc"; fail=$((fail+1)); fi

echo; echo "check-kotlin: $ok ok, $fail falha(s)"; [ "$fail" = 0 ]
