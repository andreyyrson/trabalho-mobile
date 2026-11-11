// Stand detail with live visit status.
import 'package:flutter/material.dart';

import '../shared/estande.dart';
import 'circuito.dart';
import 'componentes.dart';
import 'scanner_page.dart';

class EstandePage extends StatelessWidget {
  const EstandePage({super.key, required this.estande});
  final Estande estande;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final texto = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: CircuitoBuilder(
        builder: (context, c) {
          final visitado = c.foiVisitado(estande);
          final destaque = c.ehDestaque(estande);
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                children: [
                  Center(child: IconeEstande(estande: estande, destaque: destaque, raio: 56)),
                  const SizedBox(height: 20),
                  Text(estande.nome,
                      textAlign: TextAlign.center,
                      style: texto.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.place_rounded, size: 18, color: cores.primary),
                      const SizedBox(width: 4),
                      Flexible(child: Text(estande.localizacao, style: TextStyle(color: cores.primary))),
                    ],
                  ),
                  if (destaque) ...[
                    const SizedBox(height: 12),
                    Center(child: Selo.missao()),
                  ],
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(estande.descricao, style: texto.bodyLarge),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: visitado ? cores.primaryContainer : null,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: Icon(
                        visitado ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        color: visitado ? cores.primary : cores.outline,
                        size: 32,
                      ),
                      title: Text(visitado ? 'Visita registrada' : 'Ainda não visitado'),
                      subtitle: Text(visitado
                          ? 'Seu check-in aqui já está confirmado.'
                          : 'Vá até o estande e leia o QR code para registrar.'),
                    ),
                  ),
                  if (!visitado) ...[
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => fazerCheckin(context),
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: const Text('Fazer check-in'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
