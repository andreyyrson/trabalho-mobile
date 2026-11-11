// Reusable visitor UI pieces: stand card, mission card, empty/error notice.
import 'package:flutter/material.dart';

import '../shared/estande.dart';
import '../shared/tema.dart';

class Aviso extends StatelessWidget {
  const Aviso({super.key, required this.icone, required this.titulo, required this.texto});
  final IconData icone;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: cores.surfaceContainerHighest,
              child: Icon(icone, size: 40, color: cores.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(titulo, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(texto, textAlign: TextAlign.center, style: TextStyle(color: cores.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

/// Round stand icon; a Hero so it flies into the detail page.
class IconeEstande extends StatelessWidget {
  const IconeEstande({super.key, required this.estande, required this.destaque, this.raio = 28});
  final Estande estande;
  final bool destaque;
  final double raio;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Hero(
      tag: 'estande-${estande.id}',
      child: Container(
        width: raio * 2,
        height: raio * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: destaque ? gradienteMissao : gradienteMarca(cores),
        ),
        child: Icon(
          destaque ? Icons.auto_awesome : Icons.storefront_rounded,
          color: Colors.white,
          size: raio,
        ),
      ),
    );
  }
}

class EstandeCard extends StatelessWidget {
  const EstandeCard({
    super.key,
    required this.estande,
    required this.visitado,
    required this.destaque,
    required this.onTap,
  });

  final Estande estande;
  final bool visitado;
  final bool destaque;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final texto = Theme.of(context).textTheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: destaque ? corMissao : Colors.transparent, width: 2),
        boxShadow: destaque
            ? [BoxShadow(color: corMissao.withValues(alpha: 0.35), blurRadius: 16)]
            : const [],
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconeEstande(estande: estande, destaque: destaque),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(estande.nome,
                          style: texto.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.place_rounded, size: 16, color: cores.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(estande.localizacao,
                                style: texto.bodySmall?.copyWith(color: cores.primary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(estande.descricao,
                          style: texto.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (visitado) Selo.visitado(context),
                    if (destaque && !visitado) Selo.missao(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Selo extends StatelessWidget {
  const Selo({super.key, required this.icone, required this.texto, required this.fundo, required this.cor});
  final IconData icone;
  final String texto;
  final Color fundo;
  final Color cor;

  factory Selo.visitado(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Selo(icone: Icons.check_circle_rounded, texto: 'Visitado', fundo: cores.primaryContainer, cor: cores.onPrimaryContainer);
  }

  factory Selo.missao() => const Selo(
      icone: Icons.star_rounded, texto: 'Missão', fundo: Color(0xFFFFECB3), cor: Color(0xFF7A4F00));

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(99)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 16, color: cor),
          const SizedBox(width: 4),
          Text(texto, style: TextStyle(color: cor, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}

class CartaoMissao extends StatelessWidget {
  const CartaoMissao({super.key, required this.visitados, required this.total, required this.onTap});
  final int visitados;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final completa = total > 0 && visitados == total;
    return Material(
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: const BoxDecoration(gradient: gradienteMissao),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const _EstrelaPulsante(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        completa ? 'Missão completa! 🏆' : 'Missão surpresa!',
                        style: const TextStyle(color: Color(0xFF3E2700), fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        completa
                            ? 'Você visitou todos os estandes em destaque.'
                            : 'Visite os $total estandes em destaque · $visitados de $total',
                        style: const TextStyle(color: Color(0xFF5A3A00)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded, color: Color(0xFF3E2700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EstrelaPulsante extends StatefulWidget {
  const _EstrelaPulsante();

  @override
  State<_EstrelaPulsante> createState() => _EstrelaPulsanteState();
}

class _EstrelaPulsanteState extends State<_EstrelaPulsante> with SingleTickerProviderStateMixin {
  late final _pulso = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _pulso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _pulso, curve: Curves.easeInOut)),
      child: const CircleAvatar(
        radius: 28,
        backgroundColor: Colors.white,
        child: Icon(Icons.star_rounded, color: Color(0xFFFF8F00), size: 36),
      ),
    );
  }
}
