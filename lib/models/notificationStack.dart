class NotificationNode {
  String _type;
  String _username;
  String _message;
  NotificationNode? _next;

  NotificationNode({
    required String type,
    required String username,
    required String message,
    NotificationNode? next,
  })  : _type = type,
        _username = username,
        _message = message,
        _next = next;

  // Getters
  String get type => _type;
  String get username => _username;
  String get message => _message;
  NotificationNode? get next => _next;

  // Setters
  set type(String value) => _type = value;
  set username(String value) => _username = value;
  set message(String value) => _message = value;
  set next(NotificationNode? value) => _next = value;
}

class NotificationStack {
  NotificationNode? _top;

  final Map<String, String> _messages = {
    'post': ' made a new post!',
    'request': ' sent you a follow request!',
    'accepted': ' accepted your follow request!',
    'message': ' sent you a message!',
  };

  // Getter and setter for top
  NotificationNode? get top => _top;
  set top(NotificationNode? node) => _top = node;

  // Public: add
  void addNotification(String type, String username) {
    _addNotification(type, username);
  }

  // Private: add logic
  void _addNotification(String type, String username) {
    if (!_messages.containsKey(type)) {    print("Skipped unknown type: $type");
      return;}

    final message = '$username${_messages[type]}';
    print("Adding notification: $message");
    final newNode = NotificationNode(
      type: type,
      username: username,
      message: message,
      next: _top,
    );
    _top = newNode;
  }

  // Public: show
  List<String> showNotifications() {
    return _showNotifications();
  }

  // Private: show logic
  List<String> _showNotifications() {
    List<String> notis = [];
    NotificationNode? current = _top;
    while (current != null) {
      print(current.message);
      notis.add(current.message);
      current = current.next;
    }
    return notis;
  }

  // Public: clear
  void clearNotifications() {
    _clearNotifications();
  }

  // Private: clear logic
  void _clearNotifications() {
    _top = null;
  }

  // Public alias for showNotifications
  List<String> toList() => showNotifications();

  // Load from raw messages
  void loadFromList(List<dynamic> data) {
    for (var item in data.reversed) {
      if (item is Map<String, dynamic>) {
        final type = item['type'];
        final username = item['username'];

        if (_messages.containsKey(type)) {
          _addNotification(type, username);
        } else {
          print("Unknown notification type: $type");
        }
      } else if (item is String) {
        // Fallback to legacy support if string messages were ever stored
        final parts = item.split(' ');
        if (parts.length >= 2) {
          final username = parts[0];
          if (item.contains('accepted')) {
            _addNotification('accepted', username);
          } else if (item.contains('follow request')) {
            _addNotification('request', username);
          } else if (item.contains('new post')) {
            _addNotification('post', username);
          } else if (item.contains('message')) {
            _addNotification('message', username);
          }
        }
      }
    }
  }

}
