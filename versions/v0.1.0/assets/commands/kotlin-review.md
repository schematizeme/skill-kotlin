---
description: schematize-kotlin — revisa Kotlin contra o piso: roda o gate e depois lê o que a máquina não lê (corrotinas, vazamento, manifesto, fronteira com a mobile)
argument-hint: "[arquivo.kt, AndroidManifest.xml ou diretório]"
---

# /kotlin-review

## 1. A máquina

```bash
bash .claude/skills/schematize-kotlin/scripts/check-kotlin.sh .
# onde houver toolchain, SÃO ELES que mandam:
kotlin build -Xkotlinc -warnings-as-errors && kotlin test
kotlinlint --strict   # ou kotlin-format lint --strict
```

`0` passa · `1` reprova · `2` **nada para verificar** (não é aprovação). O gate é **textual** e diz
isso na saída.

## 2. O que a máquina não lê

- **Concorrência:** o módulo está em **Kotlin 6 mode**? Há `@MainActor` no que **não** toca UI (que
  serializa o app)? Toda operação longa **checa cancelamento**? Depois de cada `await` dentro de um
  `actor`, a invariante foi **relida** (reentrância)?
- **Vazamento:** algum `Context`/`Activity` guardado em campo estático? `collect` sem
  `repeatOnLifecycle`? o LeakCanary rodou nos fluxos críticos em debug?
- **Nulabilidade:** cada `!!` restante tem invariante **real**? o que vem de Java está tratado como
  anulável na borda?
- **Erro:** o `catch` trata, propaga ou registra **com contexto**? algum `when` sobre `sealed` com
  `else` (que cala o compilador no próximo caso)?
- **Fronteira:** o que é de app (offline, IAM, push, loja) está seguindo a **`schematize-mobile`**,
  não uma segunda versão da regra escrita aqui?
- **Segredo:** nada no APK; credencial em `EncryptedSharedPreferences`/Keystore; `exported`
  explícito no manifesto; log sem PII/token.

## 3. Feche

Achado vira correção no mesmo PR ou item de checklist com dono. Mexeu no gate? rode o vermelho:
`bash scripts/check-kotlin.test.sh` (11 casos).
