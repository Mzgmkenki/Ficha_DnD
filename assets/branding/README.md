# Logo do DragonSheet

Esta pasta guarda a identidade visual. O app e o PDF funcionam sem os arquivos:
cada ponto que usa a logo some ou cai num texto quando ela não está aqui. Assim
nada quebra enquanto os arquivos não chegam.

## Arquivos esperados

| Arquivo | Onde aparece | Obrigatório |
|---|---|---|
| `logo.png` | Tela vazia da lista, cabeçalho de exportar, marca d'água do PDF | Sim |
| `logo_icon.png` | Barra do app e ícone da plataforma | Não, mas recomendado |

Sem o `logo_icon.png` a barra do app usa o `logo.png`, e o resultado fica pior:
o conjunto tem o wordmark embaixo do dragão, e reduzido para 30 px de altura o
nome vira um borrão.

## `logo.png` — o conjunto completo

O dragão com o d20 e o wordmark "DragonSheet" embaixo, como na arte aprovada.

- **Fundo transparente.** É o requisito mais importante e o mais fácil de
  errar. A marca d'água é desenhada por baixo do texto do PDF: com fundo preto,
  em vez de uma silhueta discreta sai um retângulo cinza no meio da página, que
  parece defeito de impressão. Na tela o fundo preto passa quase despercebido,
  porque o app já é escuro; no PDF, que é branco, não passa.
- Lado maior de **1024 px ou mais**. A marca d'água ocupa cerca de 60% da
  largura de uma página A4.
- A proporção original é respeitada em todos os lugares.

## `logo_icon.png` — só a marca

O dragão com o d20, **sem o wordmark**.

- PNG **quadrado**, **1024 × 1024 px**.
- Pode ter fundo transparente. O gerador preenche com o preto do app
  (`#0A0A0C`) onde a plataforma exige opacidade, porque o iOS não aceita
  transparência em ícone.
- Deixe cerca de **10% de margem** nas bordas: o Android recorta o ícone em
  círculo, quadrado arredondado ou losango conforme o launcher, e o que estiver
  colado na borda é cortado. O d20 encostando na moldura perderia as pontas.

## Como aplicar depois de copiar

O `logo.png` e o `logo_icon.png` são lidos em tempo de execução: basta rodar o
app de novo.

O ícone da plataforma é gerado em tempo de build e precisa de um comando:

```
.flutter-sdk\bin\flutter.bat pub run flutter_launcher_icons
```

Isso reescreve os `mipmap-*` do Android, o `AppIcon.appiconset` do iOS e os
ícones do web a partir do `logo_icon.png`. A configuração está no
`pubspec.yaml`, na seção `flutter_launcher_icons`.
