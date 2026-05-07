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

  // 🔥 HELPER: nunggu widget hilang
  Future<void> pumpUntilGone(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final end = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 300));

      if (finder.evaluate().isEmpty) {
        return;
      }
    }

    throw Exception("Widget masih ada: $finder");
  }

  testWidgets('FULL FLOW TEST (FINAL FIX)', (WidgetTester tester) async {
    final kategoriName =
        'Kategori Test ${DateTime.now().millisecondsSinceEpoch}';

    final supplierName =
        'Supplier Test ${DateTime.now().millisecondsSinceEpoch}';

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

    await pumpUntilFound(
      tester,
      find.text('Test Obat'),
      timeout: Duration(seconds: 15),
    );

    expect(find.text('Test Obat'), findsWidgets);

    // ================= UPDATE =================
    await tester.tap(find.byIcon(Icons.edit).last);
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
    await tester.tap(find.byIcon(Icons.delete).last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    // tunggu hilang
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Obat Edit'), findsNothing);

    // ================= KATEGORI =================

    // buka drawer
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    // klik kategori
    await tester.tap(find.text('Kategori'));
    await tester.pumpAndSettle();

    // tambah kategori
    await tester.tap(find.byKey(Key('addKategoriButton')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(Key('namaKategoriField')), kategoriName);

    await tester.tap(find.byKey(Key('saveKategoriButton')));
    await tester.pumpAndSettle();

    expect(find.text(kategoriName), findsWidgets);

    // delete kategori
    await tester.tap(find.byKey(Key('deleteKategori_$kategoriName')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    await pumpUntilGone(
      tester,
      find.text(kategoriName),
      timeout: Duration(seconds: 15),
    );

    expect(find.text(kategoriName), findsNothing);

    // kembali dari kategori
    await tester.pageBack();
    await tester.pumpAndSettle();

    // tunggu halaman obat muncul lagi
    await pumpUntilFound(
      tester,
      find.byKey(Key('addObatButton')),
      timeout: Duration(seconds: 10),
    );

    // buka drawer
    final drawerButton = find.byTooltip('Open navigation menu');

    await pumpUntilFound(tester, drawerButton, timeout: Duration(seconds: 10));

    await tester.tap(drawerButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    // klik supplier
    await tester.tap(find.text('Supplier'));
    await tester.pumpAndSettle();

    // tambah supplier
    await tester.tap(find.byKey(Key('addSupplierButton')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(Key('namaSupplierField')), supplierName);

    await tester.enterText(find.byKey(Key('alamatSupplierField')), 'Jakarta');

    await tester.enterText(find.byKey(Key('hpSupplierField')), '08123456789');

    await tester.tap(find.byKey(Key('saveSupplierButton')));
    await tester.pumpAndSettle();

    await pumpUntilFound(
      tester,
      find.text(supplierName),
      timeout: Duration(seconds: 15),
    );

    expect(find.text(supplierName), findsWidgets);

    // delete supplier
    await tester.tap(find.byKey(Key('deleteSupplier_${supplierName}')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    await tester.pump(const Duration(seconds: 2));

    expect(find.text(supplierName), findsNothing);

    // kembali ke halaman utama
    await tester.pageBack();
    await tester.pumpAndSettle();

    // ================= LOGOUT =================

    // pastikan balik ke halaman utama
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // tunggu tombol logout muncul
    await pumpUntilFound(tester, find.byKey(const Key('logoutButton')));

    // klik logout
    await tester.tap(
      find.byKey(const Key('logoutButton')),
      warnIfMissed: false,
    );

    await tester.pumpAndSettle();

    // tunggu halaman login muncul
    // ================= LOGOUT =================

    await tester.pump(const Duration(seconds: 2));

    await tester.tap(
      find.byKey(const Key('logoutButton')),
      warnIfMissed: false,
    );

    // kasih waktu navigation
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // cek login field muncul lagi
    expect(find.byKey(const Key('usernameField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);
    expect(find.byKey(const Key('loginButton')), findsOneWidget);
  });
}
