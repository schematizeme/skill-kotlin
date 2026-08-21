---
description: schematize-kotlin — revisa Kotlin contra o piso: roda o gate e depois lê o que a máquina não lê (corrotinas, vazamento, manifesto, fronteira com a mobile)
argument-hint: "[arquivo.kt, AndroidManifest.xml ou diretório]"
---

# /kotlin-review

## 1. A máquina

```bash
bash .claude/skills/schematize-kotlin/scripts/check-kotlin.sh .
# onde houver toolchain, SÃO ELES que mandam:
./gradlew lint test        # + o ktlint/detekt do projeto
./gradlew assembleRelease  # o R8 roda aqui — é onde o crash de `keep` aparece
```

`0` passa · `1` reprova · `2` **nada para verificar** (não é aprovação). O gate é **textual** e diz
isso na saída.

## 2. O que a máquina não lê

- **Corrotinas:** algum `GlobalScope`? o `Dispatchers` está no repositório ou vazou para o chamador?
  toda operação longa **checa cancelamento**? algum `catch`/`runCatching` engolindo
  `CancellationException` (e transformando "a tela fechou" em erro de negócio)?
- **Vazamento:** algum `Context`/`Activity` em campo estático? `collect` sem `repeatOnLifecycle`?
  `Handler`/`Timer` sem cancelamento? o LeakCanary rodou nos fluxos críticos em debug?
- **Nulabilidade:** cada `!!` restante tem invariante **real**? o que vem de **Java** está tratado
  como anulável na borda (platform type **não é checado**)? algum `lateinit` que é só conserto?
- **Estado:** os `when` sobre `sealed` estão **sem `else`** (senão o compilador cala no próximo
  caso)? há `value class` para os ids que hoje são `String`?
- **Manifesto:** todo componente com intent-filter tem `android:exported` **explícito**?
  `allowBackup` foi **decidido**? nada de `usesCleartextTraffic`?
- **Release:** as regras de `keep` do R8 foram **testadas** num build de release (o crash de
  reflexão/serialização **não aparece em debug**)?
- **Segredo:** nada no APK; credencial em `EncryptedSharedPreferences`/Keystore; log sem PII/token.
- **Fronteira:** o que é de app (offline, IAM, push, loja) segue a **`schematize-mobile`**, e não uma
  segunda versão da regra escrita aqui?

## 3. Feche

Achado vira correção no mesmo PR ou item de checklist com dono. Mexeu no gate? rode o vermelho:
`bash scripts/check-kotlin.test.sh` (11 casos).
