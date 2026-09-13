import 'package:flutter_test/flutter_test.dart';

import 'package:devchat/core/app.dart';

void main() {
  testWidgets('shows configuration help when Supabase is missing', (tester) async {
    await tester.pumpWidget(const DevChatApp(configurationError: true));

    expect(find.text('Supabase n’est pas configuré.'), findsOneWidget);
    expect(find.text('DevChat'), findsOneWidget);
  });
}
