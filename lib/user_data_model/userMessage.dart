class userMessageNode<T> {
  T message;
  userMessageNode? next;

  userMessageNode(this.message);
}

class userMessageStack<T> {
  userMessageNode<T>? head;

  void Push(T msg) {
    final newNode = userMessageNode(msg);
    if (head == null) {
      head = newNode;
      return;
    } else {
      newNode.next = head;
      head = newNode;
    }
  }
  T? pop(){
    if (head == null){
      return null;

    }else{
      final value = head!.message;
      head = head!.next as userMessageNode<T>?;
      return value;
    }
  }

  List<T> toList() {
    final List<T> result = [];
    userMessageNode<dynamic>? current = head;
    while (current != null) {
      result.add(current.message);
      current = current.next;
    }
    return result;
  }
}
