import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // 🔥 HELPER: nunggu widget muncul
  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final end = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 300));
      if (finder.evaluate().isNotEmpty) return;
    }

    throw Exception("Widget tidak ditemukan: $finder");
  }

  testWidgets('FULL FLOW TEST (FINAL FIX)', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    // ================= LOGIN =================
    await tester.enterText(find.byKey(Key('usernameField')), 'admin');
    await tester.enterText(find.byKey(Key('passwordField')), '123');
    await tester.tap(find.byKey(Key('loginButton')));
    await tester.pumpAndSettle();

    expect(find.text('Apotek App'), findsOneWidget);

    // ================= CREATE =================
    await tester.tap(find.byKey(Key('addObatButton')));
    await tester.pumpAndSettle();

    // isi form
    await tester.enterText(find.byKey(Key('namaObatField')), 'Test Obat');
    await tester.enterText(find.byKey(Key('hargaField')), '1000');
    await tester.enterText(find.byKey(Key('stokField')), '5');

    // kategori
    await tester.tap(find.byKey(Key('kategoriDropdown')));
    await tester.pumpAndSettle();

    await pumpUntilFound(tester, find.text('Obat Maag'));
    await tester.tap(find.text('Obat Maag').first);
    await tester.pumpAndSettle();

    // supplier
    await tester.tap(find.byKey(Key('supplierDropdown')));
    await tester.pumpAndSettle();

    await pumpUntilFound(tester, find.text('Sido Muncul'));
    await tester.tap(find.text('Sido Muncul').first);
    await tester.pumpAndSettle();

    // simpan
    await tester.tap(find.byKey(Key('saveObatButton')));
    await tester.pumpAndSettle();

    // kasih waktu UI update
    await tester.pump(const Duration(seconds: 2));

    // 🔥 FIX SCROLL (WAJIB .first)
    await tester.scrollUntilVisible(
      find.text('Test Obat'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Test Obat'), findsWidgets);

    // ================= UPDATE =================
    await tester.tap(find.byIcon(Icons.edit).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(Key('namaObatField')), 'Obat Edit');
    await tester.tap(find.byKey(Key('saveObatButton')));
    await tester.pumpAndSettle();

    await pumpUntilFound(
      tester,
      find.text('Obat Edit'),
      timeout: Duration(seconds: 15),
    );

    expect(find.text('Obat Edit'), findsWidgets);

    // ================= DELETE =================
    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    // tunggu hilang
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Obat Edit'), findsNothing);

    // ================= LOGOUT =================
    await tester.tap(find.byKey(Key('logoutButton')));
    await tester.pumpAndSettle();

    expect(find.text('Admin Login'), findsOneWidget);
  });
}
