# DragonSheet

Aplicativo Flutter para criar, acompanhar e exportar fichas de personagens de
D&D 5e em português.

O DragonSheet funciona de forma local: personagens, recursos e progresso ficam
armazenados no dispositivo. O compêndio de regras é distribuído junto com o
aplicativo, sem depender de servidor, conta ou conexão com a internet.

## Recursos

- criação e edição de personagens;
- raças, sub-raças, antecedentes, classes, subclasses e multiclasse;
- atributos, perícias, salvaguardas, proficiência e valores passivos;
- pontos de vida com controles rápidos de dano e cura, classe de armadura,
  iniciativa e deslocamento;
- armas, ataques e ações de combate;
- magias, espaços de magia e compêndio com busca e filtros;
- itens mágicos, sintonia, cargas e bônus;
- condições, exaustão, inspiração e salvaguardas contra a morte;
- descansos curtos e longos, dados de vida e recuperação de recursos;
- características raciais, características de classe e talentos;
- retrato do personagem com recorte, zoom, reposicionamento e pré-visualização;
- importação e exportação da ficha em JSON;
- geração e compartilhamento da ficha em PDF.

## Tecnologias

- Flutter e Dart;
- Riverpod para estado e injeção de dependências;
- Drift/SQLite para persistência local;
- arquivos JSON empacotados para o compêndio;
- `pdf` e `printing` para geração e compartilhamento da ficha;
- `file_picker`, `crop_your_image`, `image` e `path_provider` para seleção,
  recorte, otimização e armazenamento dos retratos.

## Arquitetura

O código é organizado por funcionalidade e separado em camadas:

```text
lib/
|-- app/                         # configuração do aplicativo
|-- core/                        # banco, rotas, tema, DI e utilitários
`-- features/
    |-- character/
    |   |-- application/         # providers e casos de uso
    |   |-- data/                # repositórios, mapeadores e PDF
    |   |-- domain/              # entidades, regras e serviços
    |   `-- presentation/        # páginas e widgets da ficha
    `-- compendium/
        |-- application/
        |-- data/
        |-- domain/
        `-- presentation/
```

Fluxo principal dos personagens:

```text
Tela -> provider/caso de uso -> repositório -> Drift/SQLite
                                              |
                                              `-> StreamProvider -> tela
```

O compêndio segue um fluxo somente de leitura:

```text
assets JSON -> SrdAssetSource -> CompendiumRepository -> FutureProvider -> UI
```

### Criação de personagens

- Os seis atributos usam o conjunto padrão `15, 14, 13, 12, 10, 8`, com
  cada valor atribuído exatamente uma vez.
- A ficha guarda separadamente o valor-base e os bônus de origem. O total
  exibido continua incluindo outros bônus permanentes, como talentos.
- As perícias escolhidas por classe, raça, antecedente e escolhas adicionais
  passam por uma validação central. Uma perícia já adquirida fica indisponível
  nas demais origens e a interface informa de onde ela veio.
- Quando uma perícia automática de antecedente conflita com outra origem, a
  criação exige uma substituição explícita em vez de remover a duplicata em
  silêncio.
- Personagens antigos continuam compatíveis: os novos metadados de criação
  são opcionais e a migração não tenta adivinhar a distribuição original.

### Pontos de vida e retratos

- Os botões rápidos de dano e cura atualizam e persistem os PV diretamente na
  ficha. O dano consome primeiro os PV temporários; a cura altera somente os
  PV atuais e nunca ultrapassa o máximo.
- Ao escolher um retrato, o aplicativo corrige a orientação da imagem e abre
  um editor com proporção fixa, movimento, zoom, redefinição, cancelamento e
  confirmação por pré-visualização.
- O arquivo confirmado é convertido para JPEG e redimensionado antes de ser
  salvo no diretório privado do aplicativo. Cancelar ou encontrar um erro
  mantém o retrato anterior.
- Na ficha em PDF, o retrato usa uma área de `168 x 126` pontos, com recorte
  central proporcional e moldura visível mesmo quando não há imagem.

## Requisitos

- Flutter estável com Dart compatível com `>=3.7.0 <4.0.0`;
- Android Studio/SDK para executar no Android;
- Xcode para executar no iOS ou macOS;
- ferramentas da plataforma correspondente para Windows, Linux ou Web.

Nesta máquina de desenvolvimento há também um Flutter local em `.flutter-sdk/`,
ignorado pelo Git. Ele existe por causa das restrições de execução do ambiente e
não é necessário em uma instalação comum.

## Preparação do projeto

Instale as dependências:

```bash
flutter pub get
```

Gere novamente o código do Drift quando tabelas ou banco forem alterados:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Execute o aplicativo:

```bash
flutter run
```

Para escolher uma plataforma ou dispositivo:

```bash
flutter devices
flutter run -d <device-id>
```

## Qualidade e testes

Análise estática:

```bash
flutter analyze
```

Suíte completa:

```bash
flutter test
```

Um arquivo específico:

```bash
flutter test test/domain/hit_points_test.dart
```

Os testes cobrem regras de domínio, migrações do banco, assets do compêndio,
rotas, widgets, importação/exportação, controles de PV, processamento e recorte
de retratos e geração/layout do PDF.

## Dados e persistência

- O banco local usa Drift/SQLite e possui migrações incrementais.
- Os dados de referência ficam em `assets/data/srd/` e `assets/data/spells/`.
- Retratos são copiados para o diretório privado do aplicativo.
- A exportação JSON é versionada para permitir evolução do formato.
- O aplicativo não envia personagens ou outros dados para o GitHub.

## Identidade visual

Logos, ícones e instruções para regenerar os ícones das plataformas ficam em
[`assets/branding/`](assets/branding/README.md).

## Build Android

Para gerar um APK de teste:

```bash
flutter build apk
```

Antes de uma distribuição pública, configure um `applicationId` definitivo e
uma assinatura de release própria em `android/app/build.gradle.kts`.

## Repositório

Código-fonte: <https://github.com/Mzgmkenki/Ficha_DnD>
