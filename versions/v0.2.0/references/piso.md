# O piso de Kotlin da casa

> Parte da skill **schematize-kotlin**. A base agnóstica é da **`schematize-engineering`**; o piso
> de **app** (offline-first, IAM mobile, push, lojas, testes no device) é da **`schematize-mobile`**
> — e, no que é de app, **ela manda**. Aqui fica o que é da linguagem e do runtime.

Convenção: **MUST** = o gate cobra · **VETADO** = piso.

---

## 1. Nulabilidade — o compilador só ajuda se você deixar

- **VETADO `!!`** em caminho de produção. Ele é um `NullPointerException` que você **escolheu**, e o
  Kotlin existe justamente para não precisar dele.
- **MUST:** `?.`, `?:` com default explícito, `requireNotNull(x) { "por quê" }` onde a invariante é
  real — a mensagem é o que distingue um crash útil de um `NPE` anônimo.
- **A fronteira com Java é onde o tipo mente:** tudo que vem de Java é **platform type** (`String!`),
  e o compilador **não checa**. Trate como anulável na borda; anote as APIs Java próprias
  (`@Nullable`/`@NonNull`) para o Kotlin poder ajudar.
- **`lateinit` é promessa sem garantia:** só onde o ciclo de vida realmente garante inicialização
  (injeção, `onCreate`), nunca para "resolver" um `null` incômodo — e o erro dele
  (`UninitializedPropertyAccessException`) não diz mais que o `!!`.

## 2. Corrotinas — estruturadas, com escopo e cancelamento

- **MUST: escopo estruturado.** `viewModelScope`/`lifecycleScope` no app, `coroutineScope`/
  `supervisorScope` na lógica. **VETADO `GlobalScope`**: ele não é cancelado por nada, e a corrotina
  sobrevive à tela que a criou — é o vazamento clássico do Android.
- **`Dispatchers` explícito na borda:** `IO` para I/O bloqueante, `Default` para CPU, `Main` para
  UI. `withContext` no **repositório**, não no chamador — quem chama não deveria saber onde a
  função roda.
- **Cancelamento é cooperativo:** laço longo checa `ensureActive()`/`isActive`; código bloqueante
  não é interrompível. E **`CancellationException` não é erro**: `try/catch (e: Exception)` engole o
  cancelamento e transforma "a tela fechou" em erro de negócio — relance sempre.
- **`runBlocking` é VETADO em produção** (é a ponte para código bloqueante em teste/`main`); em app,
  ele trava a thread principal.
- **Flow:** frio por default; `stateIn`/`shareIn` com escopo e política explícitos.
  **`collect` sem escopo com ciclo de vida** é vazamento — no Android, `repeatOnLifecycle`.
- **Exceção em corrotina não sobe pelo `try` de quem lançou:** `launch` propaga para o escopo (e
  derruba os irmãos, salvo `supervisorScope`); `async` guarda até o `await`. Quem trata é o
  `CoroutineExceptionHandler` ou o `try` **dentro** da corrotina.

## 3. Tipos e modelagem

- **`val` por default**, `var` é declaração de mudança. **`data class` para dado**, `sealed
  class`/`sealed interface` para estado — é o que faz o `when` ser **exaustivo em compilação** e o
  estado impossível não compilar.
- **`when` sem `else`** no `sealed`: com `else`, o dia em que alguém acrescenta um caso, o
  compilador **cala** e o bug aparece em produção.
- **Tipos inline/`value class`** para id (`UserId`, `TenantId`) — trocar dois `String` de posição é
  o bug que teste não pega.
- **Nada de `Any` na fronteira**; DTO tipado com serialização declarada (kotlinx.serialization),
  e **fronteira validada** — desserializar não é validar.

## 4. Erro é valor, e exceção é para o excepcional

- Erro de domínio: `sealed class Erro` + `Result`/either. Exceção fica para o que é realmente
  excepcional (I/O impossível, invariante quebrada).
- **VETADO `catch (e: Exception) { }`** e o `catch` que só loga e segue. E cuidado: `catch
  (e: Throwable)` engole `Error` da JVM (`OutOfMemoryError`) e o `CancellationException`.
- **`runCatching` engole tudo, inclusive cancelamento** — em corrotina, ou você relança
  `CancellationException`, ou não use.

## 5. Android — o que é da linguagem e some no review

- **`Context` estático é vazamento**: nada de guardar `Activity`/`View` em `object`, `companion
  object` ou variável de escopo maior. Use `applicationContext` quando o que você precisa é do
  processo.
- **Nada de trabalho na main thread** (I/O, parse grande, cripto). O sintoma é ANR, e o ANR não diz
  quem travou.
- **Ciclo de vida:** `collect`/observer sem `repeatOnLifecycle` continua rodando com a tela em
  background; `Handler`/`Timer` sem cancelamento vaza.
- **`SharedPreferences` não é cofre:** é XML em claro. Credencial vai em
  `EncryptedSharedPreferences`/Keystore (piso da `schematize-mobile`).

## 6. Segurança do cliente

- **Nunca segredo no APK** — constante, `BuildConfig`, `strings.xml`, `.so`: tudo sai com
  `apktool`/`strings`. Piso da `schematize-mobile`.
- **`WebView`:** `setJavaScriptEnabled(true)` só com conteúdo próprio; `addJavascriptInterface` é
  ponte de execução — VETADO com conteúdo remoto.
- **Exported component sem permissão** (`activity`/`receiver`/`provider` com `exported="true"`) é
  superfície de ataque: **declare `exported` explicitamente** e proteja com permissão.
- **`allowBackup="true"`** copia dado do app para fora; decida, não herde o default.
- **Log:** nada de PII/token; `Log.d` some em release **só se** o Proguard/R8 remover — não conte
  com isso por default.

## 7. Teste

Disciplina da **`schematize-qa`**. Aqui: JUnit5 + `kotlinx-coroutines-test` (`runTest`, `TestScope`
com relógio virtual — nada de `Thread.sleep` no teste), MockK no que precisa de dublê, Turbine para
`Flow`. Teste de unidade **sem device**; o resto na pirâmide da `schematize-mobile`.
