# Changelog — schematize-kotlin

Todas as mudanças relevantes deste pacote, no formato [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
com versionamento [SemVer](https://semver.org/lang/pt-BR/).

## [0.2.1] — 2026-09-30
Pedido do dono: agents idle poluem a tela e seguram recurso.

### Adicionado
- Piso de orquestração ganha a regra de frota ociosa (idle com pendência volta ao trabalho; dependente de outro agent → mata e enfileira com gatilho; terminou → mata); detalhe na `schematize-engineering` §9.6.

## [0.2.0] — 2026-09-30

Pedido do dono, por **custo**: o orquestrador não desenvolve; ação onerosa vira micro-tasks baratas; `sonnet` é o default dos subagents e `opus` só entra após falha.

### Adicionado
- **Piso "Orquestrador não desenvolve; subagent barato executa"** no `assets/CLAUDE.md` e no `SKILL.md`: o agent principal só planeja, despacha e revisa; ação onerosa vira micro-tasks para subagents em `sonnet` (falhou → o mesmo subagent corrige → re-decompõe → só então `opus`, com motivo). Detalhe na base: `schematize-engineering` → `references/orquestracao.md` §9.

### Mantido (piso inalterado)
- Todos os pisos anteriores e o gate de `scripts/` seguem exatamente como estavam; a mudança é só de orquestração, não de código.

## [0.1.1] — 2026-08-21

### Corrigido
- Os comandos `/kotlin-load`, `/kotlin-review` e `/kotlin-cc` carregavam **texto do template de Swift** (`@MainActor`, `Sendable`, ARC, "Kotlin 6 mode") — resíduo de cópia adaptada por substituição. Reescritos para o que é de Kotlin/Android: `GlobalScope`, `Dispatchers` no repositório, `CancellationException` que não se engole, `when` sobre `sealed` sem `else`, `repeatOnLifecycle`, `exported` no manifesto e **R8 com `keep` testado**. *A Classe C reaparecendo na skill nova, no primeiro dia — registrada aqui de propósito.*

## [0.1.0] — 2026-08-21

Primeira versão. A `schematize-mobile` promete escolha *"nativo vs cross por fit + ADR"* e **não havia skill por trás de nenhuma das opções** — promessa **publicada e não sustentada** (vistoria de 2026-08-21). Publicada no mesmo marco que `schematize-swift`, `schematize-dart` e o conserto da `schematize-mobile` (v0.3.0).

### Adicionado
- **`references/piso.md`** — nulabilidade (**`!!` é um NPE que você escolheu**; a **fronteira com Java mente**, porque platform type não é checado; `lateinit` é promessa sem garantia e o erro dele não diz mais que um NPE); **corrotinas estruturadas** (**`GlobalScope` não é cancelado por nada e sobrevive à tela** — o vazamento clássico do Android; `withContext` no **repositório**, porque quem chama não deveria saber onde a função roda; **cancelamento cooperativo** e o ponto que mais engana: **`CancellationException` não é erro** — engoli-lo transforma "a tela fechou" em erro de negócio, e `runCatching` engole por default; e a propagação de exceção que **não sobe pelo `try` de quem lançou**); `sealed` + **`when` sem `else`** (com `else`, o dia em que alguém acrescenta um caso o compilador **cala**); Android (Context estático, ciclo de vida, `SharedPreferences` é **XML em claro**); segurança do cliente; teste.
- **`references/plataforma.md`** — Gradle com **version catalog**, dependency locking e **wrapper com `distributionSha256Sum`** (*wrapper sem checksum é execução de binário baixado sem verificação — a cadeia de suprimentos começa aí*); `targetSdk` que **bloqueia publicação** quando envelhece; **R8 com regras de `keep` testadas** (o crash clássico de release é reflexão que o R8 removeu, e ele **não aparece em debug**); `android:exported` explícito; **KMP como decisão de arquitetura com ADR**; interop Java (`List` do Kotlin é read-only, **não imutável**).
- **`scripts/check-kotlin.sh`** + **`check-kotlin.test.sh`** (**11 casos**, 9 vermelhos): `!!`, `GlobalScope`, `runBlocking`, `catch {}` vazio, `catch(Exception)` sem tratar cancelamento, `runCatching` idem, `lateinit`, credencial em `SharedPreferences`, `addJavascriptInterface`, `when` sobre sealed com `else`, e no manifesto: **componente com intent-filter sem `exported` explícito**, `usesCleartextTraffic`, `allowBackup`.

### Corrigido durante a própria escrita (vale registro)
- A regra do `!!` **nunca casava**: o padrão `[A-Za-z_)\]]!!` usa `\]` **dentro de uma classe POSIX**, onde a barra invertida é **literal** — ou seja, ele exigia um `]` logo depois da classe. Gate cego não reprova nada **e parece verde**. Corrigido para `[]A-Za-z_)]` (o `]` primeiro, que é a forma correta) — e o mesmo defeito foi corrigido no gate da `schematize-swift`.

### Honestidade sobre o alcance
- A toolchain Android/Gradle **não roda na máquina de referência** do catálogo. O gate é **textual** e **diz isso na saída**; onde houver ktlint/detekt e o compilador, **são eles que mandam**.
