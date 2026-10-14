# Anexo volátil — versões e ferramental (Kotlin / Android)

> Parte da skill **schematize-kotlin**. **Fonte volátil:** prazo de validade, atualizado à parte do
> corpo normativo (que não crava número — regra `anexo-volatil` do lint).
>
> **Verificado em: 2026-10-14.** Cadência: trimestral e antes de cada release da skill.
> **Ressalva honesta:** esta é uma das três (Swift, Kotlin, Dart) cuja toolchain Android/Gradle **não roda na
> máquina de referência** do catálogo. Os números vêm da documentação oficial, não de execução local — e é por isso que eles
> moram aqui, no anexo datado, e não no corpo normativo.

## Linguagem e runtime

- **Piso normativo:** linha **em suporte** de Kotlin e do Android Gradle Plugin, com a **toolchain
  declarada** (`jvmToolchain`) e o **wrapper com checksum**.
- **`targetSdk`** acompanha a exigência corrente da Play Store — ela sobe **todo ano** e
  **bloqueia publicação** quando fica para trás. Confirme a janela vigente antes de cada release
  (não de memória).
- **Prazo anual da Play (31/ago):** em 31/08/2026, apps novos e atualizações precisam mirar
  **Android 16 (API 36)** ou superior; app existente precisa de API 35+ para continuar disponível a
  usuários novos em aparelhos recentes; extensão possível até 01/11/2026 (pedida no Play Console).
  A API 37 será a exigência de 2027 — planeje a migração no primeiro semestre.
- **Kotlin 2.x / compilador K2** é a baseline (K1 é legado); `@Composable`/**Jetpack Compose** é a
  UI padrão do cliente novo, com o plugin de compilador do Compose alinhado à versão do Kotlin.
- **`minSdk`** é decisão de produto, escrita: cada versão a menos exclui usuário; cada versão a mais
  custa em API e teste.

## Ferramental

| Ferramenta | Papel | Nota |
|---|---|---|
| **Gradle + version catalog** | build e dependência | `libs.versions.toml`; wrapper com `distributionSha256Sum` |
| **ktlint** ou **detekt** | formatação e lint | um só, escolhido, **travando o CI** |
| **kotlinx-coroutines-test** | teste de corrotina com relógio virtual | `runTest`; nada de `Thread.sleep` |
| **Turbine** | asserção sobre `Flow` | |
| **MockK** | dublê idiomático | dublê é para fronteira, não para tudo |
| **R8** | shrink/ofuscação em release | regras de `keep` **testadas** — o crash de release mora aqui |
| **LeakCanary** | vazamento de `Activity`/`Fragment` em debug | |

## Regra que NÃO é volátil

`!!` em produção, `GlobalScope`, segredo no APK e `catch (e: Exception) {}` são VETADOS **em
qualquer versão**.
