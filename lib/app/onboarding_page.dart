// First-launch introduction: three swipeable steps, then the home screen.
import 'package:flutter/material.dart';

import '../shared/tema.dart';
import 'home_page.dart';

const _passos = [
  (
    icone: Icons.explore_rounded,
    titulo: 'Explore a feira inteira',
    texto: 'Os melhores projetos do Amazon Hacking estão em todos os corredores, não só perto da entrada.',
  ),
  (
    icone: Icons.qr_code_scanner_rounded,
    titulo: 'Faça check-in nos estandes',
    texto: 'Em cada estande, leia o QR code com a câmera para registrar sua visita.',
  ),
  (
    icone: Icons.auto_awesome,
    titulo: 'Fique de olho na missão',
    texto: 'Durante o evento, uma missão surpresa pode destacar estandes especiais. Encontre todos!',
  ),
];

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _paginas = PageController();
  int _atual = 0;

  bool get _ultimo => _atual == _passos.length - 1;

  void _comecar() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const HomePage(),
        transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _paginas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: _comecar, child: const Text('Pular')),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _paginas,
                    itemCount: _passos.length,
                    onPageChanged: (i) => setState(() => _atual = i),
                    itemBuilder: (context, i) {
                      final p = _passos[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TweenAnimationBuilder(
                              key: ValueKey(i),
                              tween: Tween(begin: 0.6, end: 1.0),
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.elasticOut,
                              builder: (context, s, child) => Transform.scale(scale: s, child: child),
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: i == 2 ? gradienteMissao : gradienteMarca(cores),
                                ),
                                child: Icon(p.icone, size: 88, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Text(p.titulo,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 12),
                            Text(p.texto,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: cores.onSurfaceVariant)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _passos.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _atual ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _atual ? cores.primary : cores.outlineVariant,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _ultimo
                          ? _comecar
                          : () => _paginas.nextPage(
                              duration: const Duration(milliseconds: 400), curve: Curves.easeOutCubic),
                      child: Text(_ultimo ? 'Começar a explorar' : 'Próximo'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
