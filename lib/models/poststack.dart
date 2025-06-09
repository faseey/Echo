// class Post {
//   final String username;
//   final String content;
//   final String date;
//
//   Post({
//     required this.username,
//     required this.content,
//     required this.date,
//   });
//
//   Map<String, dynamic> toJson() => {
//     'username': username,
//     'content': content,
//     'date': date,
//   };
//
//   factory Post.fromJson(Map<String, dynamic> json) => Post(
//     username: json['username'],
//     content: json['content'],
//     date: json['date'],
//   );
// }
//
// class PostNode {
//   final Post post;
//   PostNode? next;
//
//   PostNode({required this.post, this.next});
// }
//
// class PostStack {
//   PostNode? top;
//
//   void push(Post post) {
//     top = PostNode(post: post, next: top);
//   }
//
//   List<Map<String, dynamic>> toJsonList() {
//     final posts = <Map<String, dynamic>>[];
//     PostNode? current = top;
//     while (current != null) {
//       posts.add(current.post.toJson());
//       current = current.next;
//     }
//     return posts;
//   }
//
//   void loadFromJsonList(List<dynamic> jsonList) {
//     for (var postData in jsonList.reversed) {
//       final post = Post.fromJson(postData);
//       push(post);
//     }
//   }
//
//   List<Post> toList() {
//     final result = <Post>[];
//     PostNode? current = top;
//     while (current != null) {
//       result.add(current.post);
//       current = current.next;
//     }
//     return result;
//   }
//
//   PostNode? peek() => top;
//
//   void clear() => top = null;
// }
