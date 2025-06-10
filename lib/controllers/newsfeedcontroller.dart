import 'package:get/get.dart';
 // Assuming this is where NewsFeedNode & NewsFeedHeap are defined
import '../models/echo.dart';
import '../models/newsfeedheap.dart';


class NewsFeedController extends GetxController {
  var newsFeed = <NewsFeedNode>[].obs;
  final Echo echo = Get.find<Echo>();
  void loadNewsFeed() {


    // Ensure user is logged in
    if (echo.activeUser == null) {
      print("No active user found.");
      newsFeed.clear();
      return;
    }

    // Rebuild the news feed using the Echo class logic
    echo.buildNewsFeed();

    // Fetch sorted posts from the heap
    final heap = echo.activeUser!.user.newsfeedheap.heap;
    print("prinitng heap");
    print(heap);

    // Sort by date (latest first) just in case
   // heap.sort((a, b) => b.date.compareTo(a.date));

    newsFeed.value = List.from(heap); // Update observable
  }

  void clearFeed() {
    newsFeed.clear();
  }

  void refreshFeed() {
    loadNewsFeed();
  }
}
