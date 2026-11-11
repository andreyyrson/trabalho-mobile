import 'package:circuito_descobertas/app/circuito.dart';
import 'package:circuito_descobertas/app/missao.dart';
import 'package:circuito_descobertas/shared/estande.dart';
import 'package:flutter_test/flutter_test.dart';

Estande _e(String id) => Estande(id: id, nome: id, descricao: '', localizacao: '', ativo: true);

void main() {
  final estandes = [_e('E01'), _e('E02'), _e('E03')];

  test('missão desligada não destaca nada, mesmo com ids configurados', () {
    final c = Circuito(
      estandes: estandes,
      visitados: const {},
      missao: const Missao(ativa: false, estandeIds: {'E01'}),
    );
    expect(c.destaques, isEmpty);
    expect(c.missaoCompleta, isFalse);
  });

  test('ids da missão que não estão ativos são ignorados', () {
    final c = Circuito(
      estandes: estandes,
      visitados: const {},
      missao: const Missao(ativa: true, estandeIds: {'E01', 'E99'}),
    );
    expect(c.destaques.map((e) => e.id), ['E01']);
  });

  test('progresso e conclusão da missão', () {
    var c = Circuito(
      estandes: estandes,
      visitados: const {'E01', 'E02'},
      missao: const Missao(ativa: true, estandeIds: {'E01', 'E03'}),
    );
    expect(c.totalVisitados, 2);
    expect(c.destaquesVisitados, 1);
    expect(c.missaoCompleta, isFalse);

    c = Circuito(estandes: estandes, visitados: const {'E01', 'E03'}, missao: c.missao);
    expect(c.missaoCompleta, isTrue);
  });
}
