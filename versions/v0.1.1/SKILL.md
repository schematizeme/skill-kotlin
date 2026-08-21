---
name: schematize-kotlin
metadata:
  version: 0.1.1
description: O piso de KOTLIN da casa (cliente Android e KMP). Rege nulabilidade (**`!!` é um NullPointerException que você escolheu**; platform type vindo de Java não é checado pelo compilador; `lateinit` é promessa sem garantia); corrotinas estruturadas (**`GlobalScope` sobrevive à tela que a criou** — o vazamento clássico do Android; `Dispatchers` no repositório, não no chamador; cancelamento cooperativo e **`CancellationException` não é erro**; `runCatching` engole o cancelamento); `sealed` + `when` sem `else` para o estado impossível não compilar; Android (Context estático vaza, ciclo de vida, `SharedPreferences` é XML em claro); segurança do cliente (nada de segredo no APK, `addJavascriptInterface`, `exported` explícito); Gradle com version catalog, lock e wrapper com checksum. Traz gate executável.
---
<!-- cross-skill: linguagens.md -> schematize-engineering -->

# O piso de Kotlin da casa (schematize-kotlin)

Recorte de **linguagem** para o cliente Android (e para KMP, quando ele for a decisão). A base
agnóstica é a **`schematize-engineering`**; o piso de **app** é da **`schematize-mobile`** — e, no
que é de app, **ela manda**.

**Versão:** skill `schematize-kotlin` v0.1.1. Changelog em `CHANGELOG.md`.

## Por que ela nasceu

A `schematize-mobile` promete escolha *"nativo vs cross por fit + ADR"* e **não havia skill por trás
de nenhuma opção** — promessa publicada e não sustentada (vistoria de 2026-08-21). Esta é uma das
quatro peças que fecham isso, com `schematize-swift`, `schematize-dart` e o conserto da própria
`schematize-mobile`.

## Comandos (Claude Code)

| Comando | O que faz |
|---|---|
| `/kotlin-help` | lista os comandos |
| `/kotlin-load` | carrega à força o corpo normativo (piso, plataforma) |
| `/kotlin-review` | revisa `.kt`/`.kts` e o manifesto contra o piso: roda o gate e lê o que a máquina não lê |
| `/kotlin-claude` | cria/mescla o `CLAUDE.md` sempre-on na raiz do repo |
| `/kotlin-cc` · `/kotlin-handoff` | context compact / handoff arquivado |

## Como usar

1. **O que é de app é da `schematize-mobile`** — offline, IAM, push, loja, teste no device.
2. **Rode o gate:** `bash scripts/check-kotlin.sh .` — `0` passa · `1` reprova · `2` **nada para
   verificar** (não é aprovação). Ele é **textual**: onde houver ktlint/detekt e o compilador, **são
   eles que mandam**.
3. **Piso de linguagem** em `references/piso.md`; **build e alvos** em `references/plataforma.md`.

Mapa de references:

| Tarefa | Reference |
|---|---|
| Nulabilidade e a fronteira com Java, corrotinas (escopo, dispatcher, cancelamento, Flow, propagação de exceção), `sealed`/`when`, erro como valor, Android (ciclo de vida, Context, prefs), segurança do cliente, teste | `references/piso.md` |
| Gradle com version catalog e lock, wrapper com checksum, `minSdk`/`targetSdk`, R8 com `keep` testado, `exported`, KMP como decisão de arquitetura, interop Java | `references/plataforma.md` |
| Versões e ferramental, com data **e a ressalva de que a toolchain não roda na máquina de referência** | `references/stack-versoes.md` |

## Pisos inegociáveis (vetam o atalho)

1. **`!!` é VETADO** em produção — é um NPE que você escolheu. Use `?.`, `?:`,
   `requireNotNull(x) { "por quê" }`.
2. **A fronteira com Java mente:** platform type (`String!`) **não é checado**. Trate como anulável
   na borda.
3. **`GlobalScope` é VETADO:** não é cancelado por nada e sobrevive à tela que o criou.
4. **Cancelamento é cooperativo, e `CancellationException` NÃO é erro.** Engoli-lo transforma "a
   tela fechou" em erro de negócio; `runCatching` engole por default.
5. **`Dispatchers` no repositório**, não no chamador — quem chama não deveria saber onde a função
   roda. **`runBlocking` é VETADO** em app.
6. **`sealed` + `when` sem `else`:** com `else`, o dia em que alguém acrescenta um caso, o
   compilador **cala**.
7. **`catch (e: Exception) { }` é VETADO**; `catch (Throwable)` engole `Error` da JVM e o
   cancelamento.
8. **Android:** `Context`/`Activity` em campo estático é vazamento; nada de I/O na main thread;
   `collect` sem `repeatOnLifecycle` roda com a tela em background.
9. **Segurança do cliente:** segredo nunca no APK; `SharedPreferences` é **XML em claro**;
   `addJavascriptInterface` com conteúdo remoto é VETADO; `android:exported` **explícito**.
10. **Build reprodutível:** version catalog, dependency locking, **wrapper com checksum**,
    `allWarningsAsErrors`, toolchain declarada.

## Relação com as outras skills

- **`schematize-mobile`** — o piso de app; **ela manda** no que é de produto/plataforma.
- **`schematize-engineering`** — a base e o rol. **Backend em Kotlin não é do rol**: entra por ADR
  de exceção.
- **`schematize-qa`** — a disciplina de teste; aqui muda o runner (`runTest` com relógio virtual,
  Turbine, MockK).
- **`schematize-pentest`** — o lado ofensivo (componente exportado, WebView, segredo no APK).
