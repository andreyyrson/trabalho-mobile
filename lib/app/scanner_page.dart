// Check-in flow: camera with an aiming frame, then a full-screen result.
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'resultado_page.dart';

/// Scan → result, looping while the visitor taps "try again".
Future<void> fazerCheckin(BuildContext context) async {
  while (true) {
    if (!context.mounted) return;
    final qr = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ScannerPage()),
    );
    if (qr == null || !context.mounted) return;
    final denovo = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ResultadoPage(qr: qr)),
    );
    if (denovo != true) return;
  }
}

const _janela = 260.0;

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> with SingleTickerProviderStateMixin {
  final _camera = MobileScannerController();
  late final _linha = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
    ..repeat(reverse: true);
  // The camera fires several detections per second; only pop once.
  bool _lido = false;

  @override
  void dispose() {
    _camera.dispose();
    _linha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.primaryContainer;
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Check-in'),
        actions: [
          IconButton(
            tooltip: 'Lanterna',
            icon: const Icon(Icons.flashlight_on_rounded),
            onPressed: _camera.toggleTorch,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _camera,
            onDetect: (capture) {
              final valor = capture.barcodes.firstOrNull?.rawValue;
              if (_lido || valor == null) return;
              _lido = true;
              Navigator.pop(context, valor);
            },
          ),
          CustomPaint(painter: _Moldura(cor)),
          Center(
            child: SizedBox.square(
              dimension: _janela,
              child: AnimatedBuilder(
                animation: _linha,
                builder: (context, _) => Align(
                  alignment: Alignment(0, _linha.value * 1.8 - 0.9),
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: cor,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [BoxShadow(color: cor, blurRadius: 12, spreadRadius: 2)],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Align(
            alignment: Alignment(0, 0.75),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Aponte a câmera para o QR code do estande',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dims everything except a rounded window in the middle.
class _Moldura extends CustomPainter {
  const _Moldura(this.cor);
  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    final janela = RRect.fromRectAndRadius(
      Rect.fromCenter(center: size.center(Offset.zero), width: _janela, height: _janela),
      const Radius.circular(28),
    );
    canvas.drawPath(
      Path.combine(PathOperation.difference, Path()..addRect(Offset.zero & size), Path()..addRRect(janela)),
      Paint()..color = Colors.black.withValues(alpha: 0.6),
    );
    canvas.drawRRect(
      janela,
      Paint()
        ..color = cor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(_Moldura old) => old.cor != cor;
}
