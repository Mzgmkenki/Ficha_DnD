import 'package:dnd_ficha_app/features/character/domain/entities/currency.dart';
import 'package:dnd_ficha_app/features/character/domain/value_objects/grant_source.dart';

/// Registro de moedas concedidas por uma fonte automática.
///
/// A carteira do personagem continua sendo um total só (`Character.currency`),
/// porque é assim que a mesa consulta. Este registro existe ao lado dela para
/// responder "quanto deste total veio do antecedente" — sem isso, trocar de
/// antecedente só poderia subtrair às cegas ou zerar a carteira, e nos dois
/// casos o dinheiro ganho em outra fonte ou adicionado à mão iria embora.
class CurrencyGrant {
  const CurrencyGrant({
    required this.source,
    required this.currency,
    this.sourceId,
    this.sourceLabel,
    this.grantedAtCreation = false,
  });

  final GrantSource source;

  /// Quanto esta fonte concedeu, moeda por moeda.
  final Currency currency;

  /// Id da fonte (`criminal` para o antecedente Criminoso).
  final String? sourceId;

  /// Rótulo pronto para exibir ("Antecedente: Criminoso").
  final String? sourceLabel;

  /// `true` quando entrou durante a criação do personagem.
  final bool grantedAtCreation;

  /// Chave estável da concessão.
  ///
  /// Uma fonte concede dinheiro uma vez só: se já existe registro com esta
  /// chave, reaplicar é ignorado. É o que impede a tela de somar 15 po a cada
  /// reconstrução.
  String get grantKey => '${source.id}|${sourceId ?? ''}';

  String get originLabel {
    final label = sourceLabel?.trim();
    if (label != null && label.isNotEmpty) return label;
    return source.label;
  }

  CurrencyGrant copyWith({
    GrantSource? source,
    Currency? currency,
    String? sourceId,
    String? sourceLabel,
    bool? grantedAtCreation,
  }) {
    return CurrencyGrant(
      source: source ?? this.source,
      currency: currency ?? this.currency,
      sourceId: sourceId ?? this.sourceId,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      grantedAtCreation: grantedAtCreation ?? this.grantedAtCreation,
    );
  }

  @override
  String toString() => 'CurrencyGrant($grantKey)';
}

/// Resultado de mexer na carteira: o novo total e os registros atualizados.
class CurrencyLedgerResult {
  const CurrencyLedgerResult({required this.wallet, required this.grants});

  final Currency wallet;
  final List<CurrencyGrant> grants;
}

/// Operações de carteira que preservam a origem do dinheiro.
///
/// Tudo aqui é puro: recebe o estado e devolve o próximo, sem tocar em banco
/// nem em tela. É o que torna a regra de "não duplicar e não apagar o que é de
/// outra fonte" testável sem subir a interface.
class CurrencyLedger {
  const CurrencyLedger._();

  /// Aplica a concessão, ignorando se a mesma fonte já concedeu.
  ///
  /// A idempotência é por [CurrencyGrant.grantKey], não por valor: duas fontes
  /// diferentes podem conceder 15 po cada e as duas devem entrar.
  static CurrencyLedgerResult apply({
    required Currency wallet,
    required List<CurrencyGrant> grants,
    required CurrencyGrant grant,
  }) {
    final alreadyApplied = grants.any((e) => e.grantKey == grant.grantKey);
    if (alreadyApplied || grant.currency.isEmpty) {
      return CurrencyLedgerResult(wallet: wallet, grants: grants);
    }

    return CurrencyLedgerResult(
      wallet: wallet.plus(grant.currency),
      grants: List<CurrencyGrant>.unmodifiable([...grants, grant]),
    );
  }

  /// Remove o que uma fonte específica concedeu.
  ///
  /// Subtrai exatamente o que aquele registro dizia ter somado, e não um valor
  /// recalculado do compêndio: se o antecedente mudou de valor entre as duas
  /// execuções, o que precisa sair é o que entrou.
  static CurrencyLedgerResult removeSource({
    required Currency wallet,
    required List<CurrencyGrant> grants,
    required GrantSource source,
    String? sourceId,
  }) {
    final key = '${source.id}|${sourceId ?? ''}';
    final matching = grants.where((e) => e.grantKey == key).toList();
    if (matching.isEmpty) {
      return CurrencyLedgerResult(wallet: wallet, grants: grants);
    }

    var next = wallet;
    for (final grant in matching) {
      next = next.minus(grant.currency);
    }

    return CurrencyLedgerResult(
      wallet: next,
      grants: List<CurrencyGrant>.unmodifiable(
        grants.where((e) => e.grantKey != key),
      ),
    );
  }

  /// Remove todo registro de uma origem, independente do id.
  ///
  /// Usado na troca de antecedente, em que o id antigo pode não ser mais
  /// conhecido por quem está aplicando o novo.
  static CurrencyLedgerResult removeAllFrom({
    required Currency wallet,
    required List<CurrencyGrant> grants,
    required GrantSource source,
  }) {
    final matching = grants.where((e) => e.source == source).toList();
    if (matching.isEmpty) {
      return CurrencyLedgerResult(wallet: wallet, grants: grants);
    }

    var next = wallet;
    for (final grant in matching) {
      next = next.minus(grant.currency);
    }

    return CurrencyLedgerResult(
      wallet: next,
      grants: List<CurrencyGrant>.unmodifiable(
        grants.where((e) => e.source != source),
      ),
    );
  }

  /// Troca a concessão de uma origem por outra, numa operação só.
  ///
  /// Remover e aplicar em sequência daria o mesmo resultado, mas este atalho
  /// existe para a troca de antecedente não depender de quem chama lembrar da
  /// ordem — aplicar antes de remover somaria duas vezes.
  static CurrencyLedgerResult replaceSource({
    required Currency wallet,
    required List<CurrencyGrant> grants,
    required GrantSource source,
    CurrencyGrant? grant,
  }) {
    final cleared = removeAllFrom(
      wallet: wallet,
      grants: grants,
      source: source,
    );

    if (grant == null) return cleared;

    return apply(
      wallet: cleared.wallet,
      grants: cleared.grants,
      grant: grant,
    );
  }

  /// Soma de tudo o que uma origem concedeu.
  static Currency totalFrom(List<CurrencyGrant> grants, GrantSource source) {
    var total = const Currency();
    for (final grant in grants) {
      if (grant.source == source) total = total.plus(grant.currency);
    }
    return total;
  }
}
