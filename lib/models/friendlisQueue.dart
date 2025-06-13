import 'dart:collection';
import 'package:get/get.dart';
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

class RequestQueue extends GetxController {
  RequestNode? _front;
  RequestNode? _rear;

  RequestQueue();

  RequestNode? get front => _front;

  Future<void> addRequest(Request request) async {
    final Echo echo = Get.find<Echo>();
    if (request.senderIndex < 0 || request.receiverIndex < 0 || echo.connections == null) return;

    RequestNode newNode = RequestNode(request: request);

    if (_rear == null) {
      _front = _rear = newNode;
    } else {
      _rear!.next = newNode;
      _rear = newNode;
    }
  }

  List<String> displayAllRequests({bool fullMessage = true}) {
    List<String> requestsList = [];
    RequestNode? current = _front;

    while (current != null) {
      final username = current.request.friendUsername;
      requestsList.add(fullMessage ? '$username sent you a friend request' : username);
      current = current.next;
    }

    return requestsList;
  }

  Future<List<AcceptedRequest>> showRequests(bool acceptAll) async {
    final Echo echo = Get.find<Echo>();
    List<AcceptedRequest> acceptedRequests = [];

    RequestNode? current = _front;
    while (current != null) {
      if (current.request.status == RequestStatus.pending) {
        if (acceptAll) {
          current.request.status = RequestStatus.accepted;
          echo.connections![current.request.senderIndex][current.request.receiverIndex] = 1;
          echo.connections![current.request.receiverIndex][current.request.senderIndex] = 1;

          acceptedRequests.add(
            AcceptedRequest(senderIndex: current.request.senderIndex, isAccepted: true),
          );
        } else {
          current.request.status = RequestStatus.rejected;
        }
      }
      current = current.next;
    }

    await echo.saveConnectionsToFirebase();
    return acceptedRequests;
  }

  void clear() {
    _front = _rear = null;
  }

  List<Map<String, dynamic>> toJsonList() {
    List<Map<String, dynamic>> jsonList = [];
    RequestNode? current = _front;

    while (current != null) {
      jsonList.add(current.request.toJson());
      current = current.next;
    }

    return jsonList;
  }

  void deleteRequestBySender(String senderUsername) {
    RequestNode? current = _front;
    RequestNode? prev;

    while (current != null) {
      if (current.request.friendUsername.toLowerCase().trim() == senderUsername.toLowerCase().trim()) {
        if (prev == null) {
          _front = current.next;
        } else {
          prev.next = current.next;
        }

        if (current == _rear) {
          _rear = prev;
        }
        break;
      }

      prev = current;
      current = current.next;
    }
  }

  RequestNode? getNodeOfSender(String senderUsername) {
    RequestNode? current = _front;
    while (current != null) {
      if (current.request.friendUsername == senderUsername) {
        return current;
      }
      current = current.next;
    }
    return null;
  }

  void loadFromJsonList(List<dynamic> jsonList) {
    _front = _rear = null;

    for (var reqJson in jsonList) {
      Request req = Request.fromJson(reqJson);
      RequestNode newNode = RequestNode(request: req);

      if (_rear == null) {
        _front = _rear = newNode;
      } else {
        _rear!.next = newNode;
        _rear = newNode;
      }
    }
  }
}
