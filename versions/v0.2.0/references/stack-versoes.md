# Anexo volátil — versões e ferramental (Kotlin / Android)

> Parte da skill **schematize-kotlin**. **Fonte volátil:** prazo de validade, atualizado à parte do
> corpo normativo (que não crava número — regra `anexo-volatil` do lint).
>
> **Verificado em: 2026-08-21.** Cadência: trimestral e antes de cada release da skill.
> **Ressalva honesta:** a toolchain Android/Gradle **não roda na máquina de referência** do
> catálogo. Os números vêm da documentação oficial, não de execução local — e é por isso que eles
> moram aqui, no anexo datado, e não no corpo normativo.

## Linguagem e runtime

- **Piso normativo:** linha **em suporte** de Kotlin e do Android Gradle Plugin, com a **toolchain
  declarada** (`jvmToolchain`) e o **wrapper com checksum**.
- **`targetSdk`** acompanha a exigência corrente da Play Store — ela sobe **todo ano** e
  **bloqueia publicação** quando fica para trás. Confirme a janela vigente antes de cada release
  (não de memória).
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
