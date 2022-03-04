import 'package:flutter_puzzle/app/app.dart';
import 'package:flutter_puzzle/puzzle/puzzle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App', () {
    testWidgets('render PuzzlePage ', (tester) async {
      await tester.pumpWidget(
        const App(),
      );

      await tester.pump(const Duration(milliseconds: 20));

      expect(find.byType(PuzzlePage), findsOneWidget);
    });
  });
}
