class NewsFeedNode {
  String post;
  String date;
  String username;
  String imageBase64;
  String profileimg; // <-- New field

  NewsFeedNode(this.post, this.date, this.username, this.imageBase64, this.profileimg);

  Map<String, dynamic> toJson() {
    return {
      'post': post,
      'date': date,
      'username': username,
      'imageBase64': imageBase64,
      'profileimg': profileimg, // <-- Add here
    };
  }

  factory NewsFeedNode.fromJson(Map<String, dynamic> json) {
    return NewsFeedNode(
      json['post'] ?? '',
      json['date'] ?? '',
      json['username'] ?? '',
      json['imageBase64'] ?? '',
      json['profileimg'] ?? '', // <-- Add here
    );
  }
}



class NewsFeedHeap {
  List<NewsFeedNode> _heap = [];

  bool _isGreater(String a, String b) {
    return a.compareTo(b) > 0;
  }

  void _heapifyUp(int index) {
    while (index > 0) {
      int parent = (index - 1) ~/ 2;
      if (_isGreater(_heap[index].date, _heap[parent].date)) {
        _swap(index, parent);
        index = parent;
      } else break;
    }
  }

  void _heapifyDown(int index) {
    int size = _heap.length;
    while (index < size) {
      int largest = index;
      int left = 2 * index + 1;
      int right = 2 * index + 2;

      if (left < size && _isGreater(_heap[left].date, _heap[largest].date)) {
        largest = left;
      }
      if (right < size && _isGreater(_heap[right].date, _heap[largest].date)) {
        largest = right;
      }

      if (largest != index) {
        _swap(index, largest);
        index = largest;
      } else {
        break;
      }
    }
  }

  void _swap(int i, int j) {
    final temp = _heap[i];
    _heap[i] = _heap[j];
    _heap[j] = temp;
  }


  void addPost(String post, String date, String username, String imageBase64,String profileimg){
    _addPost(post, date, username, imageBase64, profileimg);
  }
  void _addPost(String post, String date, String username, String imageBase64,String profileimg) {
    final node = NewsFeedNode(post, date, username, imageBase64,profileimg);
    _heap.add(node);
    _heapifyUp(_heap.length - 1);
  }

  void _restoreHeap(List<NewsFeedNode> heapList) {
    int index = 0;
    int size = heapList.length;

    while (index < size) {
      int largest = index;
      int left = 2 * index + 1;
      int right = 2 * index + 2;

      if (left < size && _isGreater(heapList[left].date, heapList[largest].date)) {
        largest = left;
      }
      if (right < size && _isGreater(heapList[right].date, heapList[largest].date)) {
        largest = right;
      }

      if (largest != index) {
        final temp = heapList[index];
        heapList[index] = heapList[largest];
        heapList[largest] = temp;
        index = largest;
      } else {
        break;
      }
    }
  }

  void clearNewsFeed() {
    _heap.clear();
  }

  List<Map<String, dynamic>> toJsonList() {
    return _heap.map((node) => node.toJson()).toList();
  }

  void loadFromJsonList(List<dynamic> jsonList) {
    _heap.clear();
    for (var item in jsonList) {
      _heap.add(NewsFeedNode.fromJson(item));
    }
  }

  List<NewsFeedNode> get heap => _heap;
}
