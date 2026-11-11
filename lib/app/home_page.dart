// Visitor home: progress header, surprise mission card and responsive stand grid.
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../shared/estande.dart';
import '../shared/tema.dart';
import 'circuito.dart';
import 'componentes.dart';
import 'estande_page.dart';
import 'missao_page.dart';
import 'scanner_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => fazerCheckin(context),
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: const Text('Fazer check-in'),
        ),
        body: CircuitoBuilder(
          builder: (context, c) => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Cabecalho(circuito: c)),
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, anim) => SizeTransition(
                    sizeFactor: anim,
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: c.missao.ativa
                      ? Padding(
                          key: const ValueKey('missao'),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: CartaoMissao(
                            visitados: c.destaquesVisitados,
                            total: c.destaques.length,
                            onTap: () => abrirMissao(context),
                          ),
                        )
                      : const SizedBox(key: ValueKey('sem-missao'), width: double.infinity),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: Text('Estandes', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                ),
              ),
              if (c.estandes.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Aviso(
                    icone: Icons.storefront_rounded,
                    titulo: 'Nenhum estande ativo',
                    texto: 'Os estandes aparecem aqui assim que a organização abrir o circuito.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverGrid.builder(
                    // Column count adapts to width: 1 on phones, 2–3 on tablets.
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 520,
                      mainAxisExtent: 128,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: c.estandes.length,
                    itemBuilder: (context, i) {
                      final e = c.estandes[i];
                      return EstandeCard(
                        estande: e,
                        visitado: c.foiVisitado(e),
                        destaque: c.ehDestaque(e),
                        onTap: () => abrirEstande(context, e),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

void abrirMissao(BuildContext context) {
  FirebaseAnalytics.instance.logEvent(name: 'missao_aberta');
  Navigator.push(context, MaterialPageRoute(builder: (_) => const MissaoPage()));
}

void abrirEstande(BuildContext context, Estande e) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => EstandePage(estande: e)));
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.circuito});
  final Circuito circuito;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final total = circuito.estandes.length;
    final visitados = circuito.totalVisitados;
    return Container(
      decoration: BoxDecoration(
        gradient: gradienteMarca(cores),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.explore_rounded, color: Colors.white, size: 28),
                  SizedBox(width: 8),
                  Text('Amazon Hacking', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Circuito de\nDescobertas',
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, height: 1.1),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      total == 0
                          ? 'Aguardando os estandes abrirem'
                          : visitados == total
                              ? 'Você visitou todos os estandes! 🎉'
                              : 'Você visitou $visitados de $total estandes',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    TweenAnimationBuilder(
                      tween: Tween(begin: 0.0, end: total == 0 ? 0.0 : visitados / total),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, valor, _) => LinearProgressIndicator(
                        value: valor,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(99),
                        color: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
