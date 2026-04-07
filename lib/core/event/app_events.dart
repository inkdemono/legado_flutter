abstract class AppEvent {
  const AppEvent();
}

class BookCollectionChangedEvent extends AppEvent {
  const BookCollectionChangedEvent({
    required this.reason,
    this.bookUrl,
  });

  final String reason;
  final String? bookUrl;
}

class BookGroupChangedEvent extends AppEvent {
  const BookGroupChangedEvent({
    required this.reason,
    this.groupId,
  });

  final String reason;
  final int? groupId;
}

class BookSourceChangedEvent extends AppEvent {
  const BookSourceChangedEvent({
    required this.reason,
    this.sourceUrl,
  });

  final String reason;
  final String? sourceUrl;
}
