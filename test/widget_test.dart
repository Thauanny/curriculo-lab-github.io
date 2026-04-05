import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:revisor_curriculo/app/app.dart';

void main() {
  testWidgets('renderiza a home do produto', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ResumeReviewApp(),
      ),
    );

    await tester.pump();

    expect(find.textContaining('Transforme seu currículo'), findsOneWidget);
    expect(find.text('Configure a Análise'), findsOneWidget);
  });
}
