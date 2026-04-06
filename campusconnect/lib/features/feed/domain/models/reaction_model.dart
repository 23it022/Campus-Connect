/// Reaction Types
/// Defines different types of reactions users can give to posts

enum ReactionType {
  like,
  love,
  wow,
  sad,
  angry;

  String get emoji {
    switch (this) {
      case ReactionType.like:
        return '👍';
      case ReactionType.love:
        return '❤️';
      case ReactionType.wow:
        return '😮';
      case ReactionType.sad:
        return '😢';
      case ReactionType.angry:
        return '😠';
    }
  }

  String get label {
    switch (this) {
      case ReactionType.like:
        return 'Like';
      case ReactionType.love:
        return 'Love';
      case ReactionType.wow:
        return 'Wow';
      case ReactionType.sad:
        return 'Sad';
      case ReactionType.angry:
        return 'Angry';
    }
  }

  static ReactionType fromString(String value) {
    return ReactionType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => ReactionType.like,
    );
  }
}
