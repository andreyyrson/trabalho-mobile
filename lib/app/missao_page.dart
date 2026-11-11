// Surprise mission: highlighted stands, progress and completion trophy.
// Live: closes gracefully if the organization turns the mission off.
import 'package:flutter/material.dart';

import '../shared/tema.dart';
import 'circuito.dart';
import 'componentes.dart';
import 'home_page.dart';
import 'scanner_page.dart';

class MissaoPage extends StatelessWidget {
  const MissaoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Missão surpresa')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => fazerCheckin(context),
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: const Text('Fazer check-in'),
      ),
      body: CircuitoBuilder(
        builder: (context, c) {
          if (!c.missao.ativa) {
            return const Aviso(
              icone: Icons.flag_rounded,
              titulo: 'Missão encerrada',
              texto: 'A organização encerrou esta missão. Continue explorando os estandes!',
            );
          }
          final destaques = c.destaques;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              _Progresso(visitados: c.destaquesVisitados, total: destaques.length),
              const SizedBox(height: 20),
              if (destaques.isEmpty)
                const Aviso(
                  icone: Icons.hourglass_top_rounded,
                  titulo: 'Em preparação',
                  texto: 'Os estandes desta missão serão revelados em instantes.',
                )
              else
                for (final e in destaques)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: EstandeCard(
                      estande: e,
                      visitado: c.foiVisitado(e),
                      destaque: true,
                      onTap: () => abrirEstande(context, e),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _Progresso extends StatelessWidget {
  const _Progresso({required this.visitados, required this.total});
  final int visitados;
  final int total;

  @override
  Widget build(BuildContext context) {
    final completa = total > 0 && visitados == total;
    const corTexto = Color(0xFF3E2700);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(gradient: gradienteMissao, borderRadius: BorderRadius.circular(28)),
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Icon(
              completa ? Icons.emoji_events_rounded : Icons.auto_awesome,
              key: ValueKey(completa),
              size: 64,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            completa ? 'Missão completa!' : 'Encontre os estandes em destaque',
            textAlign: TextAlign.center,
            style: const TextStyle(color: corTexto, fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            completa
                ? 'Você descobriu todos os projetos da missão. Parabéns! 🏆'
                : 'Eles estão fora do caminho mais movimentado. Faça check-in em cada um.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF5A3A00)),
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder(
            tween: Tween(begin: 0.0, end: total == 0 ? 0.0 : visitados / total),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, valor, _) => LinearProgressIndicator(
              value: valor,
              minHeight: 12,
              borderRadius: BorderRadius.circular(99),
              color: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(height: 8),
          Text('$visitados de $total visitados', style: const TextStyle(color: corTexto, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
