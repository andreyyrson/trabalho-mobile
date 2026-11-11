// Combines the three live sources the visitor screens depend on:
// active stands and own check-ins (Firestore) plus the mission (Remote Config).
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../shared/estande.dart';
import 'componentes.dart';
import 'missao.dart';

class Circuito {
  const Circuito({required this.estandes, required this.visitados, required this.missao});

  /// Active stands only, sorted by name.
  final List<Estande> estandes;
  final Set<String> visitados;
  final Missao missao;

  bool foiVisitado(Estande e) => visitados.contains(e.id);
  bool ehDestaque(Estande e) => missao.ativa && missao.estandeIds.contains(e.id);

  List<Estande> get destaques => estandes.where(ehDestaque).toList();
  int get totalVisitados => estandes.where(foiVisitado).length;
  int get destaquesVisitados => destaques.where(foiVisitado).length;
  bool get missaoCompleta => destaques.isNotEmpty && destaquesVisitados == destaques.length;
}

class CircuitoBuilder extends StatefulWidget {
  const CircuitoBuilder({super.key, required this.builder});
  final Widget Function(BuildContext context, Circuito circuito) builder;

  @override
  State<CircuitoBuilder> createState() => _CircuitoBuilderState();
}

class _CircuitoBuilderState extends State<CircuitoBuilder> {
  // Created once so rebuilds don't resubscribe.
  late final Stream<List<Estande>> _estandes = estandesRef
      .where('ativo', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map(Estande.fromDoc).toList()..sort((a, b) => a.nome.compareTo(b.nome)));

  late final Stream<Set<String>> _visitados = checkinsRef
      .where('visitanteId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .snapshots()
      .map((s) => {for (final d in s.docs) d.data()['estandeId'] as String});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _estandes,
      builder: (context, est) {
        if (est.hasError) {
          return const Aviso(
            icone: Icons.wifi_off_rounded,
            titulo: 'Sem conexão',
            texto: 'Não foi possível carregar os estandes. Verifique a internet.',
          );
        }
        if (!est.hasData) return const Center(child: CircularProgressIndicator());
        return StreamBuilder(
          stream: _visitados,
          builder: (context, vis) => ValueListenableBuilder(
            valueListenable: missao,
            builder: (context, m, _) => widget.builder(
              context,
              Circuito(estandes: est.data!, visitados: vis.data ?? const {}, missao: m),
            ),
          ),
        );
      },
    );
  }
}
