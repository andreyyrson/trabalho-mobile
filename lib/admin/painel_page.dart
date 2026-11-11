// Admin panel: KPIs, stand CRUD, QR per stand and live check-in totals.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../shared/estande.dart';
import '../shared/tema.dart';

class PainelPage extends StatelessWidget {
  const PainelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cores.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: cores.surfaceContainerLowest,
        titleSpacing: 24,
        title: Row(
          children: [
            Icon(Icons.explore_rounded, color: cores.primary),
            const SizedBox(width: 8),
            const Text('Circuito de Descobertas', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: FirebaseAuth.instance.signOut,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sair'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editar(context, null),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo estande'),
      ),
      body: StreamBuilder(
        stream: estandesRef.orderBy('nome').snapshots(),
        builder: (context, estSnap) => StreamBuilder(
          stream: checkinsRef.snapshots(),
          builder: (context, chkSnap) {
            if (estSnap.hasError || chkSnap.hasError) {
              return const _Mensagem(
                icone: Icons.lock_outline,
                texto: 'Sem permissão. Este usuário precisa estar na coleção "admins".',
              );
            }
            if (!estSnap.hasData || !chkSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final totais = <String, int>{};
            for (final c in chkSnap.data!.docs) {
              final id = c.data()['estandeId'] as String?;
              if (id != null) totais[id] = (totais[id] ?? 0) + 1;
            }
            final estandes = estSnap.data!.docs.map(Estande.fromDoc).toList();
            final ativos = estandes.where((e) => e.ativo).length;
            final maximo = totais.values.fold(0, (a, b) => a > b ? a : b);
            final campeao = estandes.where((e) => (totais[e.id] ?? 0) == maximo && maximo > 0).firstOrNull;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _Kpi(icone: Icons.storefront_rounded, rotulo: 'Estandes ativos', valor: '$ativos de ${estandes.length}'),
                          _Kpi(icone: Icons.how_to_reg_rounded, rotulo: 'Check-ins confirmados', valor: '${chkSnap.data!.size}'),
                          _Kpi(icone: Icons.emoji_events_rounded, rotulo: 'Mais visitado', valor: campeao?.nome ?? '—'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text('Estandes', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      if (estandes.isEmpty)
                        const _Mensagem(icone: Icons.storefront_outlined, texto: 'Nenhum estande cadastrado ainda.')
                      else
                        LayoutBuilder(
                          builder: (context, box) {
                            // 1–3 columns depending on the window width.
                            final colunas = (box.maxWidth / 380).floor().clamp(1, 3);
                            final largura = (box.maxWidth - 16 * (colunas - 1)) / colunas;
                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                for (final e in estandes)
                                  SizedBox(
                                    width: largura,
                                    child: _EstandeAdmin(
                                      estande: e,
                                      checkins: totais[e.id] ?? 0,
                                      maximo: maximo,
                                      onEditar: () => _editar(context, e),
                                      onQr: () => _mostrarQr(context, e),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _editar(BuildContext context, Estande? atual) async {
    final dados = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _EstandeForm(atual: atual),
    );
    if (dados == null) return;
    if (atual == null) {
      await estandesRef.add(dados);
    } else {
      await estandesRef.doc(atual.id).update(dados);
    }
  }

  void _mostrarQr(BuildContext context, Estande e) {
    showDialog<void>(
      context: context,
      builder: (dialogo) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e.nome, style: Theme.of(dialogo).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              Text(e.localizacao),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                // White background keeps it readable by cameras in dark mode too.
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: SizedBox.square(dimension: 340, child: QrImageView(data: qrPayload(e.id))),
              ),
              const SizedBox(height: 16),
              Text('Faça check-in no app Circuito de Descobertas', style: Theme.of(dialogo).textTheme.titleMedium),
              Text('id: ${e.id} · Ctrl+P para imprimir', style: TextStyle(color: Theme.of(dialogo).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              TextButton(onPressed: () => Navigator.pop(dialogo), child: const Text('Fechar')),
            ],
          ),
        ),
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.icone, required this.rotulo, required this.valor});
  final IconData icone;
  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return SizedBox(
      width: 280,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(gradient: gradienteMarca(cores), borderRadius: BorderRadius.circular(16)),
                child: Icon(icone, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rotulo, style: TextStyle(color: cores.onSurfaceVariant)),
                    Text(valor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
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

class _EstandeAdmin extends StatelessWidget {
  const _EstandeAdmin({
    required this.estande,
    required this.checkins,
    required this.maximo,
    required this.onEditar,
    required this.onQr,
  });

  final Estande estande;
  final int checkins;
  final int maximo;
  final VoidCallback onEditar;
  final VoidCallback onQr;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final e = estande;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(e.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ),
                Tooltip(
                  message: e.ativo ? 'Ativo — visível no app' : 'Inativo — oculto no app',
                  child: Switch(
                    value: e.ativo,
                    onChanged: (v) => estandesRef.doc(e.id).update({'ativo': v}),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.place_rounded, size: 16, color: cores.primary),
                const SizedBox(width: 4),
                Expanded(child: Text(e.localizacao, style: TextStyle(color: cores.primary))),
              ],
            ),
            const SizedBox(height: 8),
            Text(e.descricao, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: cores.onSurfaceVariant)),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('$checkins', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(width: 6),
                Text(checkins == 1 ? 'check-in' : 'check-ins', style: TextStyle(color: cores.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 6),
            TweenAnimationBuilder(
              tween: Tween(begin: 0.0, end: maximo == 0 ? 0.0 : checkins / maximo),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 8,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ActionChip(
                  avatar: const Icon(Icons.copy_rounded, size: 16),
                  label: Text(e.id),
                  tooltip: 'Copiar id (para o Remote Config)',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: e.id));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('id ${e.id} copiado')));
                  },
                ),
                const Spacer(),
                IconButton(tooltip: 'QR code', icon: const Icon(Icons.qr_code_2_rounded), onPressed: onQr),
                IconButton(tooltip: 'Editar', icon: const Icon(Icons.edit_rounded), onPressed: onEditar),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Mensagem extends StatelessWidget {
  const _Mensagem({required this.icone, required this.texto});
  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(texto, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _EstandeForm extends StatefulWidget {
  const _EstandeForm({this.atual});
  final Estande? atual;

  @override
  State<_EstandeForm> createState() => _EstandeFormState();
}

class _EstandeFormState extends State<_EstandeForm> {
  final _form = GlobalKey<FormState>();
  late final _nome = TextEditingController(text: widget.atual?.nome);
  late final _descricao = TextEditingController(text: widget.atual?.descricao);
  late final _localizacao = TextEditingController(text: widget.atual?.localizacao);
  late bool _ativo = widget.atual?.ativo ?? true;

  @override
  void dispose() {
    _nome.dispose();
    _descricao.dispose();
    _localizacao.dispose();
    super.dispose();
  }

  String? _obrigatorio(String? v) => (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.atual == null ? 'Novo estande' : 'Editar estande'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nome,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: _obrigatorio,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricao,
                decoration: const InputDecoration(labelText: 'Descrição breve'),
                maxLength: 140,
                maxLines: 2,
                validator: _obrigatorio,
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _localizacao,
                decoration: const InputDecoration(labelText: 'Localização', hintText: 'Corredor B, estande 12'),
                validator: _obrigatorio,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ativo'),
                subtitle: const Text('Aparece no app dos visitantes'),
                value: _ativo,
                onChanged: (v) => setState(() => _ativo = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            Navigator.pop(
              context,
              Estande(
                id: widget.atual?.id ?? '',
                nome: _nome.text.trim(),
                descricao: _descricao.text.trim(),
                localizacao: _localizacao.text.trim(),
                ativo: _ativo,
              ).toMap(),
            );
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
