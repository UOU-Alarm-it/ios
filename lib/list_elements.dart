import 'package:flutter_svg/svg.dart';
import 'package:notification_it/webView.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class ElementWidget extends StatefulWidget {
  final int id;
  final String title;
  final String date;
  final String link;
  final String type;
  final String major;


  ElementWidget({
    required this.title,
    required this.date,
    required this.link,
    required this.type,
    required this.major,
    required this.id
  });

  @override
  _ElementWidgetState createState() => _ElementWidgetState();
}

class _ElementWidgetState extends State<ElementWidget> {
  BookmarkManager bookmarkManager = BookmarkManager();
  bool _isBookmarked = false;
  late Future<bool> _isBookmarkedFuture;

  @override
  void initState() {
    super.initState();
    _loadBookmarkStatus();
    _isBookmarkedFuture = BookmarkManager.isBookmarked(widget.id.toString());
  }

  //북마크
  Future<void> _loadBookmarkStatus() async {
    bool bookmarked = await BookmarkManager.isBookmarked(widget.id.toString());
    setState(() {
      _isBookmarked = bookmarked;
    });
  }
  void _toggleBookmark() async {
    await BookmarkManager.toggleBookmark(widget.id.toString());
    setState(() {
      _isBookmarked = !_isBookmarked; // 즉시 상태 업데이트
      final mainPageState = MainPage.of(context); // MainPage.of() 호출
      if (mainPageState != null) {
        mainPageState.updateElements(); // MainPage의 상태를 업데이트
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewPage(url: widget.link),
          ),
        );
      },
      child: SizedBox(
        width: 315,
        height: 79,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 15.0),
                      Row(
                        children: [
                          if (widget.type == 'NOTICE')
                            SizedBox(
                              height: 15,
                              width: 45,
                              child: Container(
                                margin: EdgeInsets.only(left:2.0, right: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: Color(0xff009D72),
                                ),
                                child: Center(
                                  child: Text(
                                    '중요',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if(widget.type =='NECESSARY')
                            SizedBox(
                              height: 15,
                              width: 45,
                              child: Container(
                                margin: EdgeInsets.only(left:2.0, right: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: Color(0xffF2BC1B),
                                ),
                                child: Center(
                                  child: Text(
                                    '필독',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(
                            width: 70,
                            height: 15,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xffEEEEEE),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Center(
                                child: Text(
                                  widget.date,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xff666666),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.42,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 15.0),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _toggleBookmark,
                  icon: FutureBuilder<bool>(
                    future: BookmarkManager.isBookmarked(widget.id.toString()),
                    builder: (context, snapshot) {
                      bool isBookmarked = snapshot.data ?? false;
                      return SvgPicture.asset(
                        isBookmarked
                            ? 'assets/icons/알림it_북마크_O.svg'
                            : 'assets/icons/알림it_북마크_X.svg',
                      );
                    },
                  ),
                ),
              ],
            ),
            Container(
              height: 1,
              width: double.infinity,
              color: Color(0xffE0E0E0),
            ),
          ],
        ),
      ),
    );
  }
}

//북마크 관리 클래스
class BookmarkManager {
  static const String bookmarkKey = 'bookmarks';

  static Future<void> toggleBookmark(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$id';
    final bookmarks = prefs.getStringList(bookmarkKey) ?? [];

    if (bookmarks.contains(key)) {
      bookmarks.remove(key);
    } else {
      bookmarks.add(key);
    }
    await prefs.setStringList(bookmarkKey, bookmarks);
  }

  static Future<bool> isBookmarked(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList(bookmarkKey) ?? [];
    return bookmarks.contains('$id');
  }

   Future<List<String>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getStringList(bookmarkKey));
    return prefs.getStringList(bookmarkKey) ?? [];
  }

  static Future<void> clearBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(bookmarkKey);  // 저장된 모든 북마크 데이터 삭제
  }
}