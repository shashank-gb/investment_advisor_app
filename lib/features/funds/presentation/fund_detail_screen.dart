import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/async_state_widgets.dart';
import '../domain/funds_models.dart';
import 'fund_detail_providers.dart';

class FundDetailScreen extends ConsumerStatefulWidget {
  const FundDetailScreen({super.key, required this.fundId});

  final String fundId;

  @override
  ConsumerState<FundDetailScreen> createState() => _FundDetailScreenState();
}

class _FundDetailScreenState extends ConsumerState<FundDetailScreen> {
  String _selectedPeriod = '1M';

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(fundDetailProvider(widget.fundId));

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final isWide = width > 900;

      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black),
          title: const Row(
            children: [
              Icon(Icons.auto_graph, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text('FUND',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 16)),
            ],
          ),
        ),
        body: detailAsync.when(
          data: (detail) => _DetailContent(
            detail: detail,
            selectedPeriod: _selectedPeriod,
            isWide: isWide,
            screenWidth: width,
            onPeriodChanged: (p) => setState(() => _selectedPeriod = p),
          ),
          loading: () => const LoadingView(message: 'Loading fund details...'),
          error: (e, _) => ErrorView(
            message: 'Failed to load fund details',
            onRetry: () => ref.invalidate(fundDetailProvider(widget.fundId)),
          ),
        ),
        bottomNavigationBar: _BottomActionButtons(screenWidth: width),
      );
    });
  }
}

double _fluidValue(double width, double minVal, double maxVal,
    {double startWidth = 400, double endWidth = 1200}) {
  if (width <= startWidth) return minVal;
  if (width >= endWidth) return maxVal;
  return minVal + (maxVal - minVal) * ((width - startWidth) / (endWidth - startWidth));
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.detail,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.isWide,
    required this.screenWidth,
  });

  final FundDetail detail;
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;
  final bool isWide;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final headerSize = _fluidValue(screenWidth, 20, 32);
    final amcSize = _fluidValue(screenWidth, 13, 16);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail.fund.name,
                          style: TextStyle(
                              fontSize: headerSize,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5),
                        ),
                        Text(
                          detail.fund.amc,
                          style: TextStyle(
                              color: Colors.grey, fontSize: amcSize),
                        ),
                      ],
                    ),
                  ),
                  _RiskBadge(
                      risk: detail.fund.riskLevel ?? 'N/A', screenWidth: screenWidth),
                ],
              ),
              const SizedBox(height: 24),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('OVERVIEW',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 16),
                          _PerformanceChartCard(
                            points: detail.performanceChart,
                            selectedPeriod: selectedPeriod,
                            onPeriodChanged: onPeriodChanged,
                            screenWidth: screenWidth,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('KEY METRICS',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 16),
                          _MetricsGrid(detail: detail, screenWidth: screenWidth),
                          const SizedBox(height: 24),
                          _ExitLoadInfo(info: detail.exitLoad, screenWidth: screenWidth),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                const Text('OVERVIEW',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 16),
                _PerformanceChartCard(
                  points: detail.performanceChart,
                  selectedPeriod: selectedPeriod,
                  onPeriodChanged: onPeriodChanged,
                  screenWidth: screenWidth,
                ),
                const SizedBox(height: 24),
                const Text('KEY METRICS',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                _MetricsGrid(detail: detail, screenWidth: screenWidth),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('PORTFOLIO HOLDINGS',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: _fluidValue(screenWidth, 14, 20))),
                  const Icon(Icons.arrow_forward_ios,
                      size: 12, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              _HoldingsList(holdings: detail.holdings, screenWidth: screenWidth),
              if (!isWide) ...[
                const SizedBox(height: 24),
                _ExitLoadInfo(info: detail.exitLoad, screenWidth: screenWidth),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  const _RiskBadge({required this.risk, required this.screenWidth});
  final String risk;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final hPadding = _fluidValue(screenWidth, 8, 14);
    final vPadding = _fluidValue(screenWidth, 4, 8);
    final fontSize = _fluidValue(screenWidth, 10, 13);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        risk.toUpperCase(),
        style: TextStyle(
            color: Colors.red,
            fontSize: fontSize,
            fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _PerformanceChartCard extends StatelessWidget {
  const _PerformanceChartCard({
    required this.points,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.screenWidth,
  });

  final List<ChartPoint> points;
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final chartHeight = _fluidValue(screenWidth, 180, 320);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: chartHeight,
              width: double.infinity,
              child: CustomPaint(
                painter: _LineChartPainter(points: points),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['1M', '6M', '1Y', '3Y', '5Y', 'ALL'].map((p) {
                final isSelected = p == selectedPeriod;
                return InkWell(
                  onTap: () => onPeriodChanged(p),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      p,
                      style: TextStyle(
                        fontSize: _fluidValue(screenWidth, 10, 13),
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({required this.points});
  final List<ChartPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.black.withValues(alpha: 0.1), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final minVal = points.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final maxVal = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;

    final dx = size.width / (points.length - 1);

    for (var i = 0; i < points.length; i++) {
      final x = i * dx;
      final y = size.height -
          ((points[i].value - minVal) / range * size.height * 0.8) -
          (size.height * 0.1);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      if (i == points.length - 1) {
        fillPath.lineTo(x, size.height);
        fillPath.close();
      }
    }

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.detail, required this.screenWidth});
  final FundDetail detail;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final isWide = screenWidth > 900;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isWide ? 1 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: isWide ? 4.5 : 2.2,
      children: [
        _MetricItem(label: 'NAV', value: '₹${detail.fund.nav}', screenWidth: screenWidth),
        _MetricItem(
            label: 'AUM', value: '₹${detail.aum}', screenWidth: screenWidth),
        _MetricItem(
            label: 'EXPENSE RATIO',
            value: detail.expenseRatio,
            screenWidth: screenWidth),
        _MetricItem(
            label: 'MIN SIP', value: '₹${detail.minSip}', screenWidth: screenWidth),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem(
      {required this.label, required this.value, required this.screenWidth});
  final String label;
  final String value;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final labelSize = _fluidValue(screenWidth, 9, 14);
    final valueSize = _fluidValue(screenWidth, 16, 32);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: labelSize,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: valueSize, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _HoldingsList extends StatelessWidget {
  const _HoldingsList({required this.holdings, required this.screenWidth});
  final List<PortfolioHolding> holdings;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final iconSize = _fluidValue(screenWidth, 24, 34);
    final nameSize = _fluidValue(screenWidth, 13, 16);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('TOP ${holdings.length} NAME',
                        style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('WEIGHTAGE %',
                        style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...holdings.map((h) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle),
                          child: Center(
                              child: Icon(Icons.business,
                                  size: iconSize * 0.6, color: Colors.black)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(h.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: nameSize)),
                              Text(h.companyName,
                                  style: TextStyle(
                                      fontSize: nameSize - 2,
                                      color: Colors.grey)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Text('${h.weightage}%',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: nameSize),
                              textAlign: TextAlign.right),
                        ),
                      ],
                    ),
                  ),
                  if (h != holdings.last)
                    const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Divider(height: 1)),
                ],
              )),
        ],
      ),
    );
  }
}

class _ExitLoadInfo extends StatelessWidget {
  const _ExitLoadInfo({required this.info, required this.screenWidth});
  final String info;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final titleSize = _fluidValue(screenWidth, 14, 18);
    final bodySize = _fluidValue(screenWidth, 13, 16);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('EXIT LOAD',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: titleSize)),
        const SizedBox(height: 8),
        Text(info,
            style: TextStyle(
                fontSize: bodySize, color: Colors.grey, height: 1.4)),
      ],
    );
  }
}

class _BottomActionButtons extends StatelessWidget {
  const _BottomActionButtons({required this.screenWidth});
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final isMobile = screenWidth < 600;
    final double horizontalPadding = isMobile ? 12.0 : 20.0;
    
    // Always respect available screen width
    final containerMaxWidth = screenWidth > 900 ? 1100.0 : screenWidth - (horizontalPadding * 2);

    String label = 'Connect with Advisor';
    if (screenWidth < 500) {
      label = 'Advisor';
    }
    if (screenWidth < 350) {
      label = ''; 
    }

    return Container(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: containerMaxWidth),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.support_agent, size: 20),
                    label: label.isEmpty 
                      ? const SizedBox.shrink() 
                      : Text(label,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _SideAction(
                  icon: Icons.analytics_outlined,
                  onTap: () {},
                  isMobile: isMobile,
                ),
                const SizedBox(width: 8),
                _SideAction(
                  icon: Icons.favorite_border,
                  onTap: () {},
                  isMobile: isMobile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideAction extends StatelessWidget {
  const _SideAction({
    required this.icon,
    required this.onTap,
    required this.isMobile,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A237E).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1A237E).withValues(alpha: 0.1)),
        ),
        child: Icon(icon, size: 22, color: const Color(0xFF1A237E)),
      ),
    );
  }
}
