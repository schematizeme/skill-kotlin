---
description: schematize-kotlin — carrega à força TODO o corpo normativo do piso de Kotlin e passa a aplicá-lo nesta sessão.
---
Carregue **agora** o corpo normativo da skill `schematize-kotlin`
(`.claude/skills/schematize-kotlin/references/*.md`):

- `piso.md` — nulabilidade (**`!!` é um NPE que você escolheu**; a fronteira com Java **mente**,
  porque platform type não é checado; `lateinit` é promessa sem garantia); **corrotinas
  estruturadas** (`GlobalScope` sobrevive à tela que o criou; `Dispatchers` no repositório, não no
  chamador; cancelamento cooperativo e **`CancellationException` não é erro**; `runCatching` engole
  o cancelamento por default); `sealed` + **`when` sem `else`**; erro como valor; Android (Context
  estático, ciclo de vida, `SharedPreferences` em claro); segurança do cliente; teste.
- `plataforma.md` — Gradle com **version catalog**, dependency locking e **wrapper com checksum**;
  `minSdk`/`targetSdk` (que **bloqueia publicação** quando envelhece); **R8 com regras de `keep`
  testadas**; `android:exported` explícito; **KMP como decisão de arquitetura, com ADR**; interop
  Java.
- `stack-versoes.md` — anexo volátil, com data **e a ressalva de alcance**: a toolchain
  Android/Gradle **não roda na máquina de referência** do catálogo.

Depois, rode o gate: `bash .claude/skills/schematize-kotlin/scripts/check-kotlin.sh .`
E lembre: no que é de **app**, quem manda é a **`schematize-mobile`**.
