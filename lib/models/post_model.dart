

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

// Import your ImagePost model

class PostNode {
  final Post post;
  PostNode? next;

  PostNode({required this.post, this.next});
}

class PostStack {
  PostNode? top;

  void push(Post post) {
    top = PostNode(post: post, next: top);
  }

  List<Map<String, dynamic>> toJsonList() {
    final posts = <Map<String, dynamic>>[];
    PostNode? current = top;
    while (current != null) {
      posts.add(current.post.toJson());
      current = current.next;
    }
    return posts;
  }

  void remove(Post post) {
    PostNode? current = top;
    PostNode? previous;

    while (current != null) {
      if (current.post.username == post.username) {
        if (previous == null) {
          // Removing top node
          top = current.next;
        } else {
          // Bypass the current node
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

  List<Post> toList() {
    final result = <Post>[];
    PostNode? current = top;
    while (current != null) {
      result.add(current.post);
      current = current.next;
    }
    return result;
  }

  PostNode? peek() => top;

  void clear() => top = null;

  bool isNotEmpty(){
    return top !=null;
  }
}
