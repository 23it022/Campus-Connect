import 'package:flutter_test/flutter_test.dart';
import 'package:campusconnect/features/feed/domain/models/post_model.dart';

/// Unit Tests for PostModel
/// Tests post logic: likes, bookmarks, reactions, hashtag extraction

void main() {
  group('PostModel', () {
    late PostModel testPost;

    setUp(() {
      testPost = PostModel(
        postId: 'post-001',
        userId: 'user-001',
        username: 'TestUser',
        text: 'Hello #flutter #campus! Check this out.',
        likesCount: 2,
        likes: ['user-002', 'user-003'],
        commentsCount: 5,
        bookmarkedBy: ['user-002'],
        reactions: {'like': 2, 'love': 1},
        userReactions: {'user-002': 'like', 'user-003': 'love'},
      );
    });

    // ─── Test 1: isLikedBy ───
    test('isLikedBy should return true for users who liked the post', () {
      expect(testPost.isLikedBy('user-002'), isTrue);
      expect(testPost.isLikedBy('user-003'), isTrue);
      expect(testPost.isLikedBy('user-999'), isFalse);
    });

    // ─── Test 2: isBookmarkedBy ───
    test('isBookmarkedBy should return true for users who bookmarked', () {
      expect(testPost.isBookmarkedBy('user-002'), isTrue);
      expect(testPost.isBookmarkedBy('user-003'), isFalse);
    });

    // ─── Test 3: getUserReaction ───
    test('getUserReaction should return reaction type or null', () {
      expect(testPost.getUserReaction('user-002'), 'like');
      expect(testPost.getUserReaction('user-003'), 'love');
      expect(testPost.getUserReaction('user-999'), isNull);
    });

    // ─── Test 4: totalReactions ───
    test('totalReactions should return sum of all reaction counts', () {
      expect(testPost.totalReactions, 3); // 2 likes + 1 love
    });

    // ─── Test 5: totalReactions with empty reactions ───
    test('totalReactions should return 0 for empty reactions', () {
      final emptyPost = PostModel(
        postId: 'p1',
        userId: 'u1',
        username: 'Test',
        text: 'No reactions',
      );
      expect(emptyPost.totalReactions, 0);
    });

    // ─── Test 6: extractHashtags ───
    test('extractHashtags should extract all hashtags from text', () {
      final hashtags =
          PostModel.extractHashtags('Hello #flutter #campus! Check #dart');

      expect(hashtags, ['#flutter', '#campus', '#dart']);
    });

    // ─── Test 7: extractHashtags with no hashtags ───
    test('extractHashtags should return empty list when no hashtags', () {
      final hashtags = PostModel.extractHashtags('Hello world!');
      expect(hashtags, isEmpty);
    });

    // ─── Test 8: extractHashtags with special characters ───
    test('extractHashtags should handle underscores and numbers', () {
      final hashtags = PostModel.extractHashtags('#hello_world #test123');
      expect(hashtags, ['#hello_world', '#test123']);
    });

    // ─── Test 9: copyWith ───
    test('copyWith should create new instance with modified fields', () {
      final modified = testPost.copyWith(
        text: 'Updated text',
        likesCount: 10,
        isEdited: true,
      );

      expect(modified.text, 'Updated text');
      expect(modified.likesCount, 10);
      expect(modified.isEdited, isTrue);
      // Unchanged fields should remain the same
      expect(modified.postId, 'post-001');
      expect(modified.userId, 'user-001');
      expect(modified.username, 'TestUser');
    });

    // ─── Test 10: Default values ───
    test('should have correct default values', () {
      final defaultPost = PostModel(
        postId: 'p1',
        userId: 'u1',
        username: 'Test',
        text: 'Default test',
      );

      expect(defaultPost.imageUrl, '');
      expect(defaultPost.likesCount, 0);
      expect(defaultPost.likes, isEmpty);
      expect(defaultPost.commentsCount, 0);
      expect(defaultPost.bookmarkedBy, isEmpty);
      expect(defaultPost.reactions, isEmpty);
      expect(defaultPost.userReactions, isEmpty);
      expect(defaultPost.hashtags, isEmpty);
      expect(defaultPost.isEdited, isFalse);
      expect(defaultPost.editedAt, isNull);
    });

    // ─── Test 11: toString ───
    test('toString should include key fields', () {
      final str = testPost.toString();
      expect(str, contains('post-001'));
      expect(str, contains('user-001'));
    });
  });
}
