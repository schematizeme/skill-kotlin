---
name: schematize-kotlin
metadata:
  version: 0.3.1
description: >-
  Piso de Kotlin para Android e KMP, sob a schematize-mobile. Use ao tocar *.kt, build.gradle.kts ou
  libs.versions.toml: sem '!!', corrotinas estruturadas, segredo fora do APK, Gradle com wrapper verificado. IAM e
  lojas: mobile. Traz CI.
---
<!-- cross-skill: linguagens.md -> schematize-engineering -->

# O piso de Kotlin da casa (schematize-kotlin)

Recorte de **linguagem** para o cliente Android (e para KMP, quando ele for a decisão). A base
agnóstica é a **`schematize-engineering`**; o piso de **app** é da **`schematize-mobile`** — e, no
que é de app, **ela manda**.

**Versão:** skill `schematize-kotlin` v0.3.1. Changelog em `CHANGELOG.md`.

## Precedência e herança (leia antes de divergir)

<!-- herdado:engineering/precedencia:mobile intro="Esta skill é o recorte **Kotlin** das linguagens **sancionadas fora do rol de backend** (`schematize-engineering` → `references/linguagens.md` §2.2): cliente **Android/KMP**, **sob a `schematize-mobile`**." cmd="kotlin" -->Esta skill é o recorte **Kotlin** das linguagens **sancionadas fora do rol de backend** (`schematize-engineering` → `references/linguagens.md` §2.2): cliente **Android/KMP**, **sob a `schematize-mobile`**.

1. **Onde esta skill divergir da base, a BASE MANDA.** Aqui mora a especialização — a lib, o gate, a
   sintaxe da linguagem. Divergência de *piso* é defeito desta skill, não variante local.
2. **O que não está repetido aqui é HERDADO, não dispensado.** Valem integralmente, sem cópia local:
   - **§28 Archive** — `<projeto>/<projeto>_archive/` é **repositório git próprio, PRIVADO e
     obrigatório**, criticidade 0 (`schematize-archive`).
   - **§35 Definition of Done** e a lista de anti-padrões (citada por **título**, nunca por número).
   - **§39 Índice/MAPA** — enumeração exaustiva (uma entrada por unidade chamável, `M == N`) e grafo
     com arestas em ASCII (`A -> B`), nunca a seta unicode.
   - **IAM** (`schematize-engineering` → `references/iam.md`): identidade ≠ email, ≥2 fatores, ReBAC
     multi-tenant, argon2id-only para senha nova, sessão longa e logout irreversível.
   - **Efeito externo** nunca sai de não-produção (`schematize-engineering` →
     `references/efeitos-externos.md`).
   - **Orquestração** (`schematize-engineering` → `references/orquestracao.md` §9): o principal não
     desenvolve (é Claude Opus); executor mais barato que resolve — `haiku`/`sonnet` → Codex Terra → Cursor → `opus` só após falha; visual direto ao Codex; imagem nunca pelo Claude: detecta Codex/Gemini e pergunta ao usuário qual usar (Codex é a sugestão, não automática), nunca API paga.
3. **Delegado à `schematize-mobile`, por nome:** IAM mobile (public client OIDC/PKCE, passkeys,
   Keychain/Keystore), ops, offline/sync, push, testes no device e entrega nas lojas
   (`schematize-mobile` → `references/testes-mobile.md`, `schematize-mobile` →
   `references/entrega-lojas.md`; comandos `/mobile-auth`, `/mobile-offline`, `/mobile-test`,
   `/mobile-release`). **Dependência:** instale a `schematize-mobile` junto; sem ela esses
   arquivos não existem no seu ambiente e o piso de app fica sem dono.
4. **QA, ops, IAM e índice não têm comando próprio aqui:** vêm da base `/eng-*`. Para trabalho
   contínuo use `/eng-overdev`; para planejar `/eng-plan`; para varrer a base `/eng-scan`; para
   revisão geral `/eng-review` (e `/eng-ops`, `/eng-iam`, `/eng-index`). Os comandos
   `/kotlin-*` cobrem só o piso da linguagem.<!-- /herdado -->

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

Assets prontos para copiar: `assets/ci/github-actions-ci.yml` (ktlint, detekt, `./gradlew check`) · `assets/lint/detekt.yml`.

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
11. <!-- herdado:engineering/orquestracao:curto -->**Orquestrador não desenvolve; subagent barato executa.** O agent principal só planeja, despacha e revisa; ação onerosa vira micro-tasks para o executor mais barato que resolve: `haiku` (mecânico) / `sonnet` (código; falhou → mesmo subagent corrige, até 2 rodadas) → Codex `gpt-5.6-terra` → Cursor → subagent `opus` (motivo) → `park`; **visual vai direto ao Codex**; **imagem nunca pelo Claude: detectar Codex/Gemini e perguntar ao usuário qual usar (Codex é a sugestão), nunca API de imagem paga**; papéis em `agentes.toml`. No overdev, cada item do checklist vai a um subagent e o principal revisa antes do `- [x]`. **Sem frota ociosa:** idle com pendência volta ao trabalho; dependente de outro agent → mata e enfileira com gatilho; terminou → mata (§9.6). Detalhe: `schematize-engineering` → `references/orquestracao.md` §9.<!-- /herdado -->

## Relação com as outras skills

- **`schematize-mobile`** — o piso de app; **ela manda** no que é de produto/plataforma.
- **`schematize-engineering`** — a base e o rol. **Backend em Kotlin não é do rol**: entra por ADR
  de exceção.
- **`schematize-qa`** — a disciplina de teste; aqui muda o runner (`runTest` com relógio virtual,
  Turbine, MockK).
- **`schematize-pentest`** — o lado ofensivo (componente exportado, WebView, segredo no APK).
