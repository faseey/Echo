class Post {
  final String username;
  final String imageBase64;
  final String date;
  String content;

  Post({
    required this.username,
    required this.imageBase64,
    required this.date,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'imageBase64': imageBase64,
      'date': date,
      'content': content,
    };
  }

  static Post fromJson(Map<String, dynamic> json) {
    return Post(
      username: json['username'] ?? '',
      imageBase64: json['imageBase64'] ?? '',
      date: json['date'] ?? '',
      content: json['content'] ?? '',
    );
  }
}

class PostNode {
  final Post post;
  PostNode? next;

  PostNode({required this.post, this.next});
}

class PostStack {
  PostNode? _top;

  void push(Post post) {
    _top = PostNode(post: post, next: _top);
  }

  void remove(Post post) {
    PostNode? current = _top;
    PostNode? previous;

    while (current != null) {
      if (current.post.username == post.username) {
        if (previous == null) {
          _top = current.next;
        } else {
          previous.next = current.next;
        }
        break;
      }
      previous = current;
      current = current.next;
    }
  }

  void loadFromJsonList(List<dynamic> jsonList) {
    for (var postData in jsonList.reversed) {
      final post = Post.fromJson(postData);
      push(post);
    }
  }

  List<Map<String, dynamic>> toJsonList() {
    final posts = <Map<String, dynamic>>[];
    PostNode? current = _top;
    while (current != null) {
      posts.add(current.post.toJson());
      current = current.next;
    }
    return posts;
  }

  List<Post> toList() {
    final result = <Post>[];
    PostNode? current = _top;
    while (current != null) {
      result.add(current.post);
      current = current.next;
    }
    return result;
  }

  PostNode? peek() => _top;

  void clear() => _top = null;

  bool isNotEmpty() => _top != null;
}
