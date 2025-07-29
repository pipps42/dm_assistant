import 'package:flutter_test/flutter_test.dart';
import 'package:dm_assistant/features/campaign/models/campaign.dart';

void main() {
  group('Campaign model', () {
    test('factory create uses DateTime.now() when not provided', () {
      final now = DateTime.now();
      final c = Campaign.create(name: 'Test');
      expect(c.name, 'Test');
      expect(c.createdAt.difference(now).inSeconds, lessThan(1));
    });

    test('copyWith creates a new instance with updated fields', () {
      final original = Campaign.create(name: 'A', description: 'Old');
      final updated = original.copyWith(name: 'B', description: 'New');
      expect(updated.name, 'B');
      expect(updated.description, 'New');
      expect(updated.id, original.id);
    });
  });
}