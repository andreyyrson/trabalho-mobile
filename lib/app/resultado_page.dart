// Full-screen check-in outcome: celebration on success, clear guidance on errors.
// Pops with true when the visitor wants to scan again.
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'checkin.dart';

class ResultadoPage extends StatefulWidget {
  const ResultadoPage({super.key, required this.qr});
  final String qr;

  @override
  State<ResultadoPage> createState() => _ResultadoPageState();
}

class _ResultadoPageState extends State<ResultadoPage> {
  late final Future<Checkin> _checkin = registrarCheckin(widget.qr).then((r) {
    r.resultado == CheckinResultado.sucesso ? HapticFeedback.heavyImpact() : HapticFeedback.vibrate();
    return r;
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _checkin,
          builder: (context, snap) {
            if (snap.hasError) {
              return _Conteudo(
                icone: Icons.wifi_off_rounded,
                cor: cores.error,
                titulo: 'Sem conexão',
                texto: 'Não foi possível registrar o check-in. Verifique a internet e tente de novo.',
                acaoPrincipal: 'Tentar de novo',
                denovoPrincipal: true,
              );
            }
            if (!snap.hasData) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Registrando sua visita…')],
                ),
              );
            }
            final nome = snap.data!.estande;
            return switch (snap.data!.resultado) {
              CheckinResultado.sucesso => _Conteudo(
                  icone: Icons.check_rounded,
                  cor: cores.primary,
                  titulo: 'Check-in confirmado!',
                  texto: 'Você visitou\n$nome',
                  celebrar: true,
                  acaoPrincipal: 'Voltar ao circuito',
                ),
              CheckinResultado.jaRegistrado => _Conteudo(
                  icone: Icons.history_rounded,
                  cor: cores.tertiary,
                  titulo: 'Visita já registrada',
                  texto: 'Você já fez check-in em $nome. Que tal descobrir outro estande?',
                  acaoPrincipal: 'Voltar ao circuito',
                ),
              CheckinResultado.estandeInativo => _Conteudo(
                  icone: Icons.block_rounded,
                  cor: cores.error,
                  titulo: 'Estande inativo',
                  texto: 'Este estande não está participando do circuito no momento.',
                  acaoPrincipal: 'Voltar ao circuito',
                ),
              CheckinResultado.qrInvalido => _Conteudo(
                  icone: Icons.qr_code_2_rounded,
                  cor: cores.error,
                  titulo: 'QR code inválido',
                  texto: 'Este QR não é de um estande do Circuito de Descobertas.',
                  acaoPrincipal: 'Ler outro QR',
                  denovoPrincipal: true,
                ),
            };
          },
        ),
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({
    required this.icone,
    required this.cor,
    required this.titulo,
    required this.texto,
    required this.acaoPrincipal,
    this.denovoPrincipal = false,
    this.celebrar = false,
  });

  final IconData icone;
  final Color cor;
  final String titulo;
  final String texto;
  final String acaoPrincipal;
  final bool denovoPrincipal;
  final bool celebrar;

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            children: [
              SizedBox.square(
                dimension: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (celebrar) const _Explosao(),
                    TweenAnimationBuilder(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.elasticOut,
                      builder: (context, escala, child) => Transform.scale(scale: escala, child: child),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: cor,
                        child: Icon(icone, size: 64, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Text(titulo, style: estilo.headlineMedium?.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(texto, style: estilo.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, denovoPrincipal),
                  child: Text(acaoPrincipal),
                ),
              ),
              if (!denovoPrincipal) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    label: const Text('Fazer outro check-in'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Dependency-free confetti: colored dots bursting out of the center.
class _Explosao extends StatelessWidget {
  const _Explosao();

  static const _cores = [Color(0xFF0E7C5A), Color(0xFFFFB300), Color(0xFF7C4DFF), Color(0xFFFF5252), Color(0xFF29B6F6)];

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < 18; i++)
            Transform.translate(
              offset: Offset.fromDirection(i * 2 * pi / 18, 40 + 70 * t),
              child: Opacity(
                opacity: (1 - t).clamp(0.0, 1.0),
                child: Container(
                  width: i.isEven ? 12 : 8,
                  height: i.isEven ? 12 : 8,
                  decoration: BoxDecoration(color: _cores[i % _cores.length], shape: BoxShape.circle),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
