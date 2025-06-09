

class ImagePost {
  final String username;
  final String content;
  final String imageBase64;
  final String date;

  ImagePost({
    required this.username,
    required this.content,
    required this.imageBase64,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'content': content,
    'imageBase64': imageBase64,
    'date': date,
  };

  factory ImagePost.fromJson(Map<String, dynamic> json) => ImagePost(
    username: json['username'],
    content: json['content'],
    imageBase64: json['imageBase64'] ?? '',
    date: json['date'],
  );
}

// Import your ImagePost model

class ImagePostNode {
  final ImagePost post;
  ImagePostNode? next;

  ImagePostNode({required this.post, this.next});
}

class ImagePostStack {
  ImagePostNode? top;

  void push(ImagePost post) {
    top = ImagePostNode(post: post, next: top);
  }

  List<Map<String, dynamic>> toJsonList() {
    final posts = <Map<String, dynamic>>[];
    ImagePostNode? current = top;
    while (current != null) {
      posts.add(current.post.toJson());
      current = current.next;
    }
    return posts;
  }

  void loadFromJsonList(List<dynamic> jsonList) {
    for (var postData in jsonList.reversed) {
      final post = ImagePost.fromJson(postData);
      push(post);
    }
  }

  List<ImagePost> toList() {
    final result = <ImagePost>[];
    ImagePostNode? current = top;
    while (current != null) {
      result.add(current.post);
      current = current.next;
    }
    return result;
  }

  ImagePostNode? peek() => top;

  void clear() => top = null;
}

