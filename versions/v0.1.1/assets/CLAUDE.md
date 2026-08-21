# Piso de Kotlin (schematize-kotlin) — sempre-on

> No que é de **app** (offline, IAM, push, loja, teste no device), quem manda é a
> **`schematize-mobile`**. Aqui é o que é de **linguagem**.

1. **`!!` é VETADO** — é um NPE que você escolheu. `?.`, `?:`, `requireNotNull(x) { "por quê" }`.
2. **Fronteira com Java mente:** platform type não é checado — trate como anulável na borda.
3. **`GlobalScope` é VETADO**; escopo estruturado sempre (`viewModelScope`, `coroutineScope`).
4. **`CancellationException` não é erro** — relance-o; `runCatching` engole por default.
5. **`Dispatchers` no repositório**, não no chamador; **`runBlocking` VETADO** em app.
6. **`sealed` + `when` sem `else`** — com `else` o compilador cala quando um caso novo aparece.
7. **`catch (e: Exception) { }` VETADO**; `catch (Throwable)` engole `Error` da JVM e o cancelamento.
8. **Android:** nada de `Context`/`Activity` estático; nada de I/O na main thread; `collect` com
   `repeatOnLifecycle`.
9. **Segurança:** segredo nunca no APK; `SharedPreferences` é **XML em claro** (use
   `EncryptedSharedPreferences`/Keystore); `addJavascriptInterface` com remoto é VETADO;
   `android:exported` **explícito**.
10. **Build:** version catalog + lock, **wrapper com checksum**, `allWarningsAsErrors`, toolchain
    declarada, R8 com `keep` **testado**.

Gate: `bash .claude/skills/schematize-kotlin/scripts/check-kotlin.sh .`
