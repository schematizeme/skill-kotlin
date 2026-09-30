# Toolchain, build e alvos — Kotlin

> Parte da skill **schematize-kotlin**. O que é de **app** (lojas, rollout, push, IAM) é da
> **`schematize-mobile`**; aqui fica build, dependência e as decisões de alvo.

---

## 1. Build reprodutível

- **MUST: Gradle com version catalog** (`gradle/libs.versions.toml`) — uma fonte para as versões,
  em vez de string repetida em cinco `build.gradle.kts`.
- **MUST: `dependency locking` ligado** (ou catálogo + resolução verificada) e o
  **wrapper commitado** com **checksum verificado** (`gradle-wrapper.properties` +
  `distributionSha256Sum`). Wrapper sem checksum é execução de binário baixado sem verificação — a
  cadeia de suprimentos começa aí.
- **Kotlin DSL** (`.kts`) no build; **`buildSrc`/convention plugins** para não repetir configuração.
- **Warnings como erro** no CI (`allWarningsAsErrors`) — em Kotlin, warning costuma ser API
  deprecada ou cast inseguro.
- **Toolchain declarada** (`kotlin { jvmToolchain(N) }`): o JDK do build é o do projeto, não o que
  estiver no PATH do runner.

## 2. Android: o que trava o release

- **`minSdk`/`targetSdk` são decisão escrita.** `targetSdk` desatualizado **bloqueia publicação** na
  Play (a exigência sobe todo ano); `minSdk` alto exclui usuário. Os números vivem no anexo volátil.
- **R8 ligado em release**, com as regras de `keep` **testadas** — o crash clássico de release é
  reflexão/serialização que o R8 removeu, e ele **não** aparece em debug.
- **`android:exported` explícito** em todo componente com intent-filter (obrigatório desde a API 31)
  — e o default é o que menos expõe.
- **Assinatura em cofre**, nunca no repo; App Bundle assinado pelo CI (`schematize-mobile`).

## 3. Kotlin fora do Android

- **Backend em Kotlin não é do rol** desta casa: serviço novo nasce no rol sancionado
  (`schematize-engineering` → `references/linguagens.md`) e Kotlin entra por **ADR de exceção**.
  Esta skill existe para o **cliente Android** (e para o multiplatform quando ele for a decisão).
- **KMP (Kotlin Multiplatform):** é uma escolha de **arquitetura**, com ADR — compartilhar domínio e
  rede costuma pagar; compartilhar UI é outra decisão, com outro custo. O `expect/actual` é
  fronteira: o que é específico de plataforma **fica explícito**, não escondido.
- **Compose Multiplatform / iOS:** só com ADR e com o custo de ferramental medido (build, debug,
  tamanho). A `schematize-mobile` decide "nativo vs cross"; aqui só se registra que **as duas
  respostas têm skill**.

## 4. Interoperabilidade com Java

- **A fronteira é onde o tipo mente** (`piso.md` §1): platform type não é checado.
- **`@JvmStatic`/`@JvmOverloads`/`@JvmName`** só onde a API é consumida por Java — poluir a API
  Kotlin para agradar um chamador que não existe é dívida.
- **Coleções:** `List` do Kotlin é **read-only**, não imutável — o Java do outro lado pode alterar a
  instância. Copie na borda quando a garantia importa.
