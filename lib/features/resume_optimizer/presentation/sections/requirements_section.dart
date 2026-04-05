import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class RequirementsSection extends StatefulWidget {
  const RequirementsSection({super.key});

  @override
  State<RequirementsSection> createState() => _RequirementsSectionState();
}

class _RequirementsSectionState extends State<RequirementsSection>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _controller;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // ── Clickable header pill ────────────────────────────────────────
        GestureDetector(
          onTap: _toggle,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Requisitos e desempenho',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Navegadores suportados, RAM, GPU e expectativas de velocidade',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.slate400),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.slate400,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        // ── Expandable content ───────────────────────────────────────────
        SizeTransition(
          sizeFactor: _expandAnim,
          child: Column(
            children: [
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 820;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _BrowserCard()),
                        const SizedBox(width: 16),
                        const Expanded(flex: 2, child: _PerformanceTable()),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _BrowserCard(),
                      const SizedBox(height: 16),
                      const _PerformanceTable(),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              const _LimitationsNotice(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Browser / Hardware card ───────────────────────────────────────────────────

class _BrowserCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const items = [
      _ReqItem(Icons.web_rounded, 'Navegador', 'Chrome 113+  ·  Edge 113+\nSafari 18+  ·  Firefox (flag)'),
      _ReqItem(Icons.memory_rounded, 'RAM mínima', '4 GB (8 GB recomendado)'),
      _ReqItem(Icons.storage_rounded, 'Espaço livre', '~2 GB (cache do modelo)'),
      _ReqItem(Icons.wifi_rounded, 'Internet', 'Só no 1º uso para baixar\no modelo (~2 GB)'),
      _ReqItem(Icons.videogame_asset_rounded, 'GPU', 'Qualquer GPU com\nsuporte a WebGPU'),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.checklist_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Requisitos mínimos',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 20),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(item.icon, size: 14, color: AppColors.slate500),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.label,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: AppColors.slate400, fontSize: 11)),
                        Text(item.value,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600, height: 1.5)),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _ReqItem {
  const _ReqItem(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
}

// ── Performance table ─────────────────────────────────────────────────────────

class _PerformanceTable extends StatelessWidget {
  const _PerformanceTable();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const rows = [
      _PerfRow(
        tier: 'Alto desempenho',
        examples: 'Apple M-series · GPU dedicada (RTX, RX)',
        speed: '20–50 tokens/s',
        time: '~30–60 s',
        color: Color(0xFF10B981),
        bgColor: Color(0xFFECFDF5),
        badgeColor: Color(0xFFD1FAE5),
      ),
      _PerfRow(
        tier: 'Desempenho médio',
        examples: 'Intel Iris · AMD Radeon integrado · 8 GB RAM',
        speed: '5–15 tokens/s',
        time: '~1–3 min',
        color: Color(0xFFF59E0B),
        bgColor: Color(0xFFFFFBEB),
        badgeColor: Color(0xFFFEF3C7),
      ),
      _PerfRow(
        tier: 'Desempenho limitado',
        examples: '4 GB RAM · GPU sem WebGPU · Navegadores antigos',
        speed: '1–3 tokens/s\n(fallback CPU)',
        time: '5 min+\nou erro',
        color: Color(0xFFEF4444),
        bgColor: Color(0xFFFEF2F2),
        badgeColor: Color(0xFFFEE2E2),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.speed_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Expectativa de desempenho',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Tempo estimado por análise completa',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate400),
          ),
          const SizedBox(height: 20),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PerfRowWidget(row: r),
              )),
        ],
      ),
    );
  }
}

class _PerfRow {
  const _PerfRow({
    required this.tier,
    required this.examples,
    required this.speed,
    required this.time,
    required this.color,
    required this.bgColor,
    required this.badgeColor,
  });
  final String tier;
  final String examples;
  final String speed;
  final String time;
  final Color color;
  final Color bgColor;
  final Color badgeColor;
}

class _PerfRowWidget extends StatelessWidget {
  const _PerfRowWidget({required this.row});
  final _PerfRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: row.bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: row.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: row.badgeColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    row.tier,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: row.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  row.examples,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.slate500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                row.speed,
                textAlign: TextAlign.end,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: row.color,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                row.time,
                textAlign: TextAlign.end,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.slate400,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Limitations notice ────────────────────────────────────────────────────────

class _LimitationsNotice extends StatelessWidget {
  const _LimitationsNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFF59E0B)),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.slate500,
                  height: 1.6,
                ),
                children: const [
                  TextSpan(
                    text: 'Computadores com menos de 4 GB de RAM ou sem suporte a WebGPU ',
                  ),
                  TextSpan(
                    text: 'podem não conseguir carregar o modelo',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: '. Nesses casos, o navegador pode exibir um erro de memória ou '
                        'a inicialização pode demorar muito. '
                        'O Chrome e o Edge têm o melhor suporte a WebGPU atualmente. '
                        'O download do modelo (~2 GB) ocorre apenas uma vez e fica '
                        'armazenado no navegador.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
