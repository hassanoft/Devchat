import 'package:flutter_test/flutter_test.dart';
import 'package:devchat/main.dart';

void main() {
  testWidgets('missing Supabase config shows setup message', (tester) async {
    await tester.pumpWidget(const MissingConfigApp());
    expect(find.textContaining('Supabase n’est pas configuré'), findsOneWidget);
  });
}
