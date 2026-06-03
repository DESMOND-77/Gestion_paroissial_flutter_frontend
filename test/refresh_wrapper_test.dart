import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paroisse_gest/presentation/widgets/refresh_wrapper.dart';

void main() {
  // Vérifie que le geste de pull-to-refresh fonctionne sur une liste normale.
  testWidgets('RefreshIndicator déclenche onRefresh sur une liste',
      (tester) async {
    var refreshed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              refreshed = true;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
            ),
          ),
        ),
      ),
    );

    // Tire vers le bas pour déclencher le rafraîchissement.
    await tester.fling(find.text('Item 0'), const Offset(0, 300), 1000);
    await tester.pump();

    // L'indicateur circulaire de rafraîchissement doit apparaître.
    expect(find.byType(RefreshProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(refreshed, isTrue);
  });

  // Vérifie que le pull-to-refresh fonctionne AUSSI sur un état vide,
  // c'est le rôle de RefreshableEmpty (un Center seul n'est pas défilable).
  testWidgets('RefreshableEmpty rend l\'état vide tirable', (tester) async {
    var refreshed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              refreshed = true;
            },
            child: const RefreshableEmpty(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 64),
                  SizedBox(height: 16),
                  Text('Aucune donnée'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Le message vide est bien affiché.
    expect(find.text('Aucune donnée'), findsOneWidget);

    // Tire vers le bas sur le contenu vide.
    await tester.fling(
        find.text('Aucune donnée'), const Offset(0, 300), 1000);
    await tester.pump();

    expect(find.byType(RefreshProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(refreshed, isTrue);
  });
}
