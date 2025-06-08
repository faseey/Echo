import 'echo.dart';

enum RequestStatus { pending, accepted, rejected }

String requestStatusToString(RequestStatus status) {
  switch (status) {
    case RequestStatus.pending:
      return 'pending';
    case RequestStatus.accepted:
      return 'accepted';
    case RequestStatus.rejected:
      return 'rejected';
  }
}

RequestStatus requestStatusFromString(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return RequestStatus.pending;
    case 'accepted':
      return RequestStatus.accepted;
    case 'rejected':
      return RequestStatus.rejected;
    default:
      return RequestStatus.pending;
  }
}

class Request {
  final String friendUsername;
  final int senderIndex;
  final int receiverIndex;
  RequestStatus status;

  Request({
    required this.friendUsername,
    required this.senderIndex,
    required this.receiverIndex,
    this.status = RequestStatus.pending,
  });

  Map<String, dynamic> toJson() => {
    'friendUsername': friendUsername,
    'senderIndex': senderIndex,
    'receiverIndex': receiverIndex,
    'status': requestStatusToString(status),
  };

  factory Request.fromJson(Map<String, dynamic> json) => Request(
    friendUsername: json['friendUsername'],
    senderIndex: json['senderIndex'],
    receiverIndex: json['receiverIndex'],
    status: requestStatusFromString(json['status']),
  );
}

class RequestNode {
  Request request;
  RequestNode? next;

  RequestNode({required this.request, this.next});
}

class AcceptedRequest {
  int senderIndex;
  bool isAccepted;

  AcceptedRequest({required this.senderIndex, required this.isAccepted});
}

class RequestQueue {
  RequestNode? front;
  RequestNode? rear;

  RequestQueue();

  void addRequest(Request request) {
    if (request.senderIndex < 0 || request.receiverIndex < 0 || Echo.connections == null) {
      return;
    }

    RequestNode newNode = RequestNode(request: request);

    if (rear == null) {
      front = rear = newNode;
    } else {
      rear!.next = newNode;
      rear = newNode;
    }

    Echo.connections![request.senderIndex][request.receiverIndex] = 1;
  }

  List<String> displayAllRequests() {
    List<String> requestsList = [];

    if (front == null) {
      return requestsList;
    }

    RequestNode? current = front;
    while (current != null) {
      final r = current.request;
      // Convert each request to a readable string format
      String statusStr = requestStatusToString(r.status);
      requestsList.add(
          'Request from ${r.friendUsername} (senderIndex: ${r.senderIndex}) '
              'to receiverIndex: ${r.receiverIndex} - Status: $statusStr'
      );
      current = current.next;
    }

    return requestsList;
  }


  /// Processes all pending requests:
  /// If acceptAll = true, accept all pending requests.
  /// If false, reject all pending requests.
  /// Returns list of AcceptedRequest for accepted ones.
  List<AcceptedRequest> showRequests(bool acceptAll) {
    List<AcceptedRequest> acceptedRequests = [];

    if (front == null) {
      return acceptedRequests;
    }

    RequestNode? current = front;
    while (current != null) {
      if (current.request.status == RequestStatus.pending) {
        if (acceptAll) {
          current.request.status = RequestStatus.accepted;
          Echo.connections![current.request.senderIndex][current.request.receiverIndex] = 1;
          Echo.connections![current.request.receiverIndex][current.request.senderIndex] = 1;
          acceptedRequests.add(
            AcceptedRequest(senderIndex: current.request.senderIndex, isAccepted: true),
          );
        } else {
          current.request.status = RequestStatus.rejected;
        }
      }
      current = current.next;
    }
    return acceptedRequests;
  }

  void clear() {
    front = rear = null;
  }
  List<Map<String, dynamic>> toJsonList() {
    List<Map<String, dynamic>> jsonList = [];
    RequestNode? current = front;
    while (current != null) {
      jsonList.add(current.request.toJson());
      current = current.next;
    }
    return jsonList;
  }
  void loadFromJsonList(List<dynamic> jsonList) {
    front = null;
    rear = null;
    for (var reqJson in jsonList) {
      Request req = Request.fromJson(reqJson);
      addRequest(req);
    }
  }

}
