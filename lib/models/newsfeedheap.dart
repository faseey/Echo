class NewsFeedNode {
  String post;
  String date; // Format: "YYYY-MM-DD HH:MM:SS"
  String username;

  NewsFeedNode(this.post, this.date, this.username);
}

class NewsFeedHeap {
  List<NewsFeedNode> _heap = [];

  // Compare timestamps (newer date is greater)
  bool _isGreater(String a, String b) {
    return a.compareTo(b) > 0; // Lexicographical comparison works for ISO format
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

  void addPost(String post, String date, String username) {
    final node = NewsFeedNode(post, date, username);
    _heap.add(node);
    _heapifyUp(_heap.length - 1);
  }

  void displayAllPosts() {
    // Clone the heap so we don't destroy the original
    final tempHeap = List<NewsFeedNode>.from(_heap);
    while (tempHeap.isNotEmpty) {
      final top = tempHeap.first;
      print('${top.username} posted: "${top.post}" on ${top.date}');
      tempHeap[0] = tempHeap.removeLast();
      _restoreHeap(tempHeap);
    }
  }

  //cloned the tempHeap that why using this instead of heapifyDonw//
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
    return _heap.map((node) => {
      'post': node.post,
      'date': node.date,
      'username': node.username,
    }).toList();
  }

  void loadFromJsonList(List<dynamic> jsonList) {
    _heap.clear();
    for (var item in jsonList) {
      _heap.add(NewsFeedNode(
        item['post'] ?? '',
        item['date'] ?? '',
        item['username'] ?? '',
      ));
    }
  }

}
