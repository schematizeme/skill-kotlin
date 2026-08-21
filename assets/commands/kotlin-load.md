---
description: schematize-kotlin — carrega à força TODO o corpo normativo do piso de Kotlin e passa a aplicá-lo nesta sessão.
---
Carregue **agora** o corpo normativo da skill `schematize-kotlin` (`.claude/skills/schematize-kotlin/references/*.md`):

- `piso.md` — opcional como tipo (**force-unwrap é `fatalError` adiado**), concorrência estruturada
  (Kotlin 6 strict, `@MainActor` só na UI, `Sendable`, cancelamento cooperativo, **reentrância do
  actor**), ARC e ciclo de retenção, erro tipado, segurança do cliente, teste.
- `plataforma.md` — KotlinPM e `Package.resolved`, CI com simulador fixado, assinatura em cofre,
  `@available`, server-side Kotlin fora do rol, interop Obj-C/C.
- `stack-versoes.md` — anexo volátil, com data **e a ressalva de alcance** (a toolchain Android/Gradle não roda na
  máquina de referência do catálogo).

Depois, rode o gate: `bash .claude/skills/schematize-kotlin/scripts/check-kotlin.sh .`
E lembre: no que é de **app**, quem manda é a **`schematize-mobile`**.
