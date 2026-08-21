# schematize-kotlin

> **O piso de Kotlin da casa** — cliente Android e KMP. `!!` é um NPE que você escolheu;
> `GlobalScope` sobrevive à tela que o criou; `CancellationException` não é erro; `SharedPreferences`
> é XML em claro. E a fronteira é explícita: **no que é de app, a `schematize-mobile` manda**.

Pacote de **skill normativa para [Claude Code](https://claude.com/claude-code)**.
Parte do catálogo **schematize skills**.

## Instalar

```bash
schematize install kotlin
# ou
git clone https://github.com/schematizeme/skill-kotlin.git /tmp/skill-kotlin
bash /tmp/skill-kotlin/install.sh .
```

## O que tem dentro

- **SKILL.md** — o contrato: 10 pisos inegociáveis + mapa de references.
- **references/** — `piso` (nulabilidade, corrotinas, sealed, Android, segurança, teste),
  `plataforma` (Gradle/lock/wrapper, SDK, R8, KMP, interop), `stack-versoes` (anexo volátil, datado).
- **scripts/** — `check-kotlin.sh` (gate textual, honesto sobre o alcance, cobre também o
  `AndroidManifest.xml`) e `check-kotlin.test.sh` (11 casos, 9 vermelhos).
- **assets/commands/** — `/kotlin-help`, `/kotlin-load`, `/kotlin-review`, `/kotlin-claude`,
  `/kotlin-cc`, `/kotlin-handoff`.
- **assets/CLAUDE.md** — regra sempre-on.

## Comandos

| Comando | O que faz |
|---|---|
| `/kotlin-help` | lista os comandos |
| `/kotlin-load` | carrega o corpo normativo |
| `/kotlin-review` | roda o gate e revisa o que a máquina não lê |
| `/kotlin-claude` | cria/mescla o `CLAUDE.md` sempre-on |
| `/kotlin-cc` · `/kotlin-handoff` | context compact / handoff no archive |

## Versão

**v0.1.0** — changelog em `CHANGELOG.md`.

## Regra de ouro

**O compilador do Kotlin só ajuda quem deixa.** Todo `!!` e todo platform type não tratado é uma
ajuda recusada.

MIT.
