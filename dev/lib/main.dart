import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import 'util.dart';
import 'theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:animations/animations.dart';
import 'package:should_rebuild/should_rebuild.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class AuthState {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleAuthProvider _googleProvider = GoogleAuthProvider();
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '133464509665-5nc30j1sjpo633cpcrft4k59f98u1p73.apps.googleusercontent.com',
  );
  static Future<UserCredential?> signInWithGoogle() async {
  try {
    if (kIsWeb) {
      // Web プラットフォーム用の認証
      final result = await _auth.signInWithPopup(_googleProvider);
      return result;
    } else {
      // モバイル用の認証
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign-In: ユーザーがキャンセルしました');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      return result;
    }
  } catch (e) {
    print('Google Sign-In Error: $e');
    if (e is FirebaseAuthException) {
      print('Firebase Auth Error Code: ${e.code}');
      print('Firebase Auth Error Message: ${e.message}');
    }
    return null;
  }
}

  static Future<void> signOut() async {
    try {
      // Firebaseサインアウト
      await _auth.signOut();
      
      // gugeサインアウト
      // check
      final googleSignIn = GoogleSignIn();
      // check2
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect();
        await googleSignIn.signOut();
      }
    } catch (e) {
      print('Sign Out Error: $e');
      // olyu cheoli
      rethrow;
    }
  }

  static User? get currentUser => _auth.currentUser;
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCCw9vbQuF9CJzyvhfy__UDIGq9SQO0KA8",
      authDomain: "thinking-sns.firebaseapp.com",
      projectId: "thinking-sns",
      storageBucket: "thinking-sns.firebasestorage.app",
      messagingSenderId: "133464509665",
      appId: "1:133464509665:web:c0b8769832c1d56ef9bba0",
      measurementId: "G-WZCMJ4R2TF",
      databaseURL: "https://thinking-sns-default-rtdb.firebaseio.com",
    ),
  );
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // check:dark or light
    final brightness = MediaQuery.of(context).platformBrightness;
    final TextTheme textTheme = createTextTheme(context, "Noto Sans JP", "Noto Sans JP");
    final MaterialTheme theme = MaterialTheme(textTheme);

    // tae ma de i tee man deul gi
    ThemeData themeData;
    if (brightness == Brightness.light) {
      themeData = theme.light();
    } else {
      themeData = theme.dark();
    }

    // pageTransitionsTheme
    themeData = themeData.copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
        },
      ),
    );

    // MaterialApp dark gwa light
    return MaterialApp(
      title: 'thinking SNS',
      theme: themeData, // light
      darkTheme: theme.dark().copyWith( // dark
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
            TargetPlatform.windows: ZoomPageTransitionsBuilder(),
            TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
          },
        ),
      ),
      themeMode: brightness == Brightness.light ? ThemeMode.light : ThemeMode.dark, // 動的に明暗モードを設定
      home: const PostListScreen(),
    );
  }
}

class CommentWidget extends StatefulWidget {
  final String commentText;
  final Function(String) onReply;

  const CommentWidget({
    Key? key,
    required this.commentText,
    required this.onReply,
  }) : super(key: key);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}


class MediaQueryObserver extends StatefulWidget {
  final Widget child;

  const MediaQueryObserver({Key? key, required this.child}) : super(key: key);

  @override
  _MediaQueryObserverState createState() => _MediaQueryObserverState();
}

class _MediaQueryObserverState extends State<MediaQueryObserver> {
  late double _previousHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentHeight = MediaQuery.of(context).size.height;
    if (_previousHeight != currentHeight) {
      // 높이 확인
      _previousHeight = currentHeight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
class _CommentWidgetState extends State<CommentWidget> {
  final TextEditingController _commentController = TextEditingController();
  Timer? _timer;
  String _displayText = '';

  @override
  void initState() {
    super.initState();
    _displayText = widget.commentText;
  
  }

  @override
  void dispose() {
    _timer?.cancel();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
      ],
    );
  }
}

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  final List<Post> _posts = [];
  final List<MiniPost> _miniPosts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _errorMessage = '';
  firestore.DocumentSnapshot? _lastDocument;
  bool _hasMorePosts = true;
  int _currentIndex = 0;  // add: tab ye  index

  @override
  void initState() {
    super.initState();
    _fetchLatestPosts();
  }

  Future<void> _fetchLatestPosts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // main
      final firestore.CollectionReference postsRef = 
          firestore.FirebaseFirestore.instance.collection('post-1')
          .doc('wsbxPa2kQDaexLV9hiVC')
          .collection('maintext');
      
      // mini
      final firestore.CollectionReference miniPostsRef = 
          firestore.FirebaseFirestore.instance.collection('post-1')
          .doc('wsbxPa2kQDaexLV9hiVC')
          .collection('minitext');

      // add
      final results = await Future.wait([
        postsRef.orderBy('createdAt', descending: true).limit(7).get(),
        miniPostsRef.orderBy('createdAt', descending: true).limit(12).get(),
      ]);

      final mainQuerySnapshot = results[0];
      final miniQuerySnapshot = results[1];
      
      // main
      if (mainQuerySnapshot.docs.isNotEmpty) {
        final List<Post> posts = [];
        for (var doc in mainQuerySnapshot.docs) {
          try {
            posts.add(Post.fromDocument(doc));
          } catch (e) {
            print('メイン投稿の解析に失敗しました: ${e.toString()}');
          }
        }
        
        _lastDocument = mainQuerySnapshot.docs.last;
        _hasMorePosts = mainQuerySnapshot.docs.length == 7;
        
        // mini
        final List<MiniPost> miniPosts = [];
        for (var doc in miniQuerySnapshot.docs) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            miniPosts.add(MiniPost(
              text: data['text'] as String? ?? '',
              backgroundColor: Post._hexToColor(data['bg'] ?? '#FFFFFF'),
              textColor: Post._hexToColor(data['color'] ?? '#000000'),
              createdAt: (data['createdAt'] as firestore.Timestamp).toDate(),
              backgroundImage: data['bgimg'] as String?,
            ));
          } catch (e) {
            print('ミニ投稿の解析に失敗しました: ${e.toString()}');
          }
        }

        setState(() {
          _posts.clear();
          _posts.addAll(posts);
          _miniPosts.clear();
          _miniPosts.addAll(miniPosts);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasMorePosts = false;
          _errorMessage = '投稿が見つかりませんでした。右上の再読み込みボタンを押してみてください。';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'エラーが発生しました: ${e.toString()}';
      });
      print('エラー: ${e.toString()}');
    }
  }
  
  Future<void> _loadMorePosts() async {
    if (!_hasMorePosts || _isLoadingMore || _lastDocument == null) return;
    
    try {
      setState(() {
        _isLoadingMore = true;
      });
      
      final firestore.CollectionReference postsRef = 
          firestore.FirebaseFirestore.instance.collection('post-1')
          .doc('wsbxPa2kQDaexLV9hiVC')
          .collection('maintext');
          
      final query = postsRef
          .orderBy('createdAt', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(9);
          
      final querySnapshot = await query.get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final List<Post> newPosts = [];
        
        for (var doc in querySnapshot.docs) {
          try {
            newPosts.add(Post.fromDocument(doc));
          } catch (e) {
            print('データの解析に失敗しました: ${e.toString()}');
          }
        }
        
        _lastDocument = querySnapshot.docs.last;
        
        _hasMorePosts = querySnapshot.docs.length == 7;
        
        setState(() {
          _posts.addAll(newPosts);
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _hasMorePosts = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      print('追加データの読み込みエラー: ${e.toString()}');
    }
  }
  
  Future<void> _updateReaction(Post post, String reactionKey) async {
    try {
      int currentCount = post.reactions[reactionKey] ?? 0;
      
      final docRef = firestore.FirebaseFirestore.instance
          .collection('post-1')
          .doc('wsbxPa2kQDaexLV9hiVC')
          .collection('maintext')
          .doc(post.id);
          
      await docRef.update({
        'reactions.$reactionKey': firestore.FieldValue.increment(1)
      });
      
      setState(() {
        post.reactions[reactionKey] = currentCount + 1;
      });
      
    } catch (e) {
      print('リアクション更新エラー: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('リアクションの更新に失敗しました'))
      );
    }
  }

  Future<void> _showColorPickerDialog(
    BuildContext context,
    Color currentColor,
    Function(Color) onColorChanged,
    String title,
  ) async {
    Color selectedColor = currentColor;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                selectedColor = color;
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('決定'),
              onPressed: () {
                onColorChanged(selectedColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _deletePost(String postId) async {
  try {
    await firestore.FirebaseFirestore.instance
        .collection('post-1')
        .doc('wsbxPa2kQDaexLV9hiVC')
        .collection('maintext')
        .doc(postId)
        .delete();

    final prefs = await SharedPreferences.getInstance();
    List<String>? postHistory = prefs.getStringList('postHistory');
    postHistory!.removeWhere((post) => post.startsWith(postId));
    await prefs.setStringList('postHistory', postHistory);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('投稿を削除しました!')),
    );
    _fetchLatestPosts();
  } catch (e) {
    print('削除エラー: ${e.toString()}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('削除に失敗しました')),
    );
  }
}
  Future<void> _showPostDeleteConfirmationDialog(String postId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('投稿の削除'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('この投稿を削除しますか？'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('削除'),
              onPressed: () {
  _deletePost(postId); // 修正したの場所
  Navigator.of(context).pop();
},
            ),
          ],
        );
      },
    );
  }


Future<void> _createPost(
  String postText,
  bool isDelayed,
  Color backgroundColor,
  Color textColor,
  String? backgroundImage,
) async {
  try {
    // 空百やスペースののチェック
    if (postText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('白紙の投稿はできないんです...')),
      );
      return; // 投稿を経
    }

    // 500ja i sang
    if (postText.length > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ちょっと文字が多いですね。500文字以下でお願いします。')),
      );
      return; // jeong ji
    }

    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '不明なユーザー';

    const uuid = Uuid();
    final String postId = uuid.v4();

    final postData = {
      'id': postId,
      'text': postText,
      'delay': isDelayed,
      'bg': '#${backgroundColor.value.toRadixString(16).substring(2)}',
      'color': '#${textColor.value.toRadixString(16).substring(2)}',
      'createdAt': firestore.FieldValue.serverTimestamp(),
      'reactions': {},
      'username': username,
      'bgimg': backgroundImage,
    };

    await firestore.FirebaseFirestore.instance
        .collection('post-1')
        .doc('wsbxPa2kQDaexLV9hiVC')
        .collection('maintext')
        .doc(postId)
        .set(postData);

    // local save:ryoeg sa
    List<String>? postHistory = prefs.getStringList('postHistory');
    if (postHistory == null) {
      postHistory = [];
    }
    postHistory.add('$postId::$postText');
    await prefs.setStringList('postHistory', postHistory);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('投稿が完了しました!')),
    );
  } catch (e) {
    print('投稿エラー: ${e.toString()}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('投稿が完了しました')),
    );
  } finally {
    _fetchLatestPosts();
  }
}

  Future<void> _createMiniPost(
    String postText,
    Color backgroundColor,
    Color textColor,
    String? backgroundImage,
  ) async {
    try {
      // 3ja check
      if (postText.length != 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ミニ投稿は3文字でなければなりません')),
        );
        return;
      }

      // Firestore save
      final postData = {
        'text': postText,
        'bg': '#${backgroundColor.value.toRadixString(16).substring(2)}',
        'color': '#${textColor.value.toRadixString(16).substring(2)}',
        'createdAt': firestore.FieldValue.serverTimestamp(),
        'bgimg': backgroundImage,
      };

      // Firestore deitteo
      await firestore.FirebaseFirestore.instance
          .collection('post-1')
          .doc('wsbxPa2kQDaexLV9hiVC')
          .collection('minitext')
          .add(postData);

      // update riseuteu
      _fetchLatestPosts();

      // snack bar allim
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ミニ投稿が完了しました')),
      );
    } catch (e) {
      print('ミニ投稿エラー: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ミニ投稿に失敗しました: ${e.toString()}')),
      );
    }
  }

  Future<void> _showCreatePostDialog() async {
    final user = AuthState.currentUser;
  
  if (user == null) {
    // login dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ログインが必要です'),
          content: const Text('投稿するにはGoogleでのログインが必要です。\nアカウント情報はFirebase Authenticationで安全に保管しておりますのでご安心ください。\nあと，初めての方は"ご利用時の注意事項"を読んでください！'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2); // change tab
              },
              child: const Text('ログイン'),
            ),
          ],
        );
      },
    );
    return;
  }

    String postText = '';
    bool isDelayed = false;
    bool isMiniPost = false;  // add
    Color backgroundColor = Colors.white;
    Color textColor = Colors.black;
bool useBackgroundImage = false;  // add
  String? selectedBgImage;  // add

    final List<String> backgroundImages = [  // 追加：利用可能の背景画像リスト
    'assets/bgimg/blue-sky.svg',
    'assets/bgimg/cold.svg',
    'assets/bgimg/happy.svg',
    'assets/bgimg/hot.svg',
    'assets/bgimg/leaves.svg',
    'assets/bgimg/new-year.svg',
    'assets/bgimg/spring.svg',
    'assets/bgimg/thinking.svg',
    'assets/bgimg/wansui.svg',
    'assets/bgimg/done.svg',
  ];

    await showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)), // 角丸を大きき
  ),
  builder: (BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 12), // margin-bottom
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('キャンセル'),
                      ),
                      TextButton(
                    onPressed: () {
                      if (isMiniPost) {
                        _createMiniPost(
                          postText,
                          backgroundColor,
                          textColor,
                          selectedBgImage,
                        );
                      } else {
                        _createPost(
                          postText,
                          isDelayed,
                          backgroundColor,
                          textColor,
                          selectedBgImage,
                        );
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('投稿'),
                  ),
                    ],
                  ),
                ),
                // geul type
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'normal',
                        label: Text('通常'),
                      ),
                      ButtonSegment<String>(
                        value: 'delayed',
                        label: Text('ディレイド'),
                      ),
                      ButtonSegment<String>(
                        value: 'mini',
                        label: Text('ミニ'),
                      ),
                    ],
                    selected: {isMiniPost ? 'mini' : (isDelayed ? 'delayed' : 'normal')},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        final selection = newSelection.first;
                        isDelayed = selection == 'delayed';
                        isMiniPost = selection == 'mini';
                      });
                    },
                  ),
                ),
                // color
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // baeg du
                        SwitchListTile(
                          title: const Text('背景画像を使用'),
                          value: useBackgroundImage,
                          onChanged: (value) {
                            setState(() {
                              useBackgroundImage = value;
                              if (!value) {
                                selectedBgImage = null;
                              }
                            });
                          },
                        ),
useBackgroundImage
  ? SizedBox(
      height: 120, // 高さちょすせい
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemCount = backgroundImages.length;
          final centerIndex = (itemCount / 2).floor();

          return ListView.builder(
  scrollDirection: Axis.horizontal,
  itemCount: backgroundImages.length,
  itemBuilder: (context, index) {
    final bgImage = backgroundImages[index];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          setState(() => selectedBgImage = bgImage);
        },
        child: Container(
          width: 80, // 各アイテム幅
          decoration: BoxDecoration(
            border: Border.all(
              color: selectedBgImage == bgImage
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16), // radius
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // baegdu
                Positioned.fill(
                  child: SvgPicture.asset(
                    bgImage,
                    fit: BoxFit.cover,
                    placeholderBuilder: (context) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.red),
                      ),
                    ),
                  ),
                ),
                if (selectedBgImage == bgImage)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  },
);
        },
      ),
    )
  : Column(
      children: [
        ListTile(
          title: const Text('背景色'),
          trailing: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onTap: () async {
            await _showColorPickerDialog(
              context,
              backgroundColor,
              (color) => setState(() => backgroundColor = color),
              '背景色を選択',
            );
          },
        ),
      ],
    ),
                        ListTile(
                          title: const Text('文字色'),
                          trailing: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: textColor,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onTap: () async {
                            await _showColorPickerDialog(
                              context,
                              textColor,
                              (color) => setState(() => textColor = color),
                              '文字色を選択',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                // text inputu
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    // isMiniPost→fix
                    height: isMiniPost ? 50 : 150,
                    alignment: Alignment.topCenter,
                    child: TextField(
                      onChanged: (value) => postText = value,
                      maxLines: isMiniPost ? 1 : null,
                      expands: isMiniPost ? false : true,
                      decoration: InputDecoration(
                        hintText: isMiniPost ? '3文字で入力...' : '投稿内容を入力...\n(投稿前にご利用時の注意事項を必ず読んでください。)',
                        border: InputBorder.none, // no border
                        filled: false,         // no bg#
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  },
);


  }

Future<void> _showInfoDialog() async {
  final PageController pageController = PageController();
  int currentPageIndex = 0;

  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: pageController,
                    onPageChanged: (index) {
                      setState(() {
                        currentPageIndex = index;
                      });
                    },
                    children: [
                      // Page 1
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ユーザー名は\n自由に設定できます',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
    fontWeight: FontWeight.bold,
  ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: 260,
                              height: 260,
                              child: Image.asset('assets/image/page1.png')
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'ユーザー名は、誰が誰かを表示上わかりやすくするための機能です。\n名前が実際の人物とは異なる場合があります。',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      // Page 2
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '安心して利用できる\n環境にしましょう',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
    fontWeight: FontWeight.bold,
  ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: 260,
                              height: 260,
                              child: Image.asset('assets/image/page2.png')
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              '個人情報や誰かが不快に思いそう内容は、絶対に書き込まないでください。\nすべての利用者が安心して利用できる環境づくりにご協力ください。',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      // Page 3
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'サービスの維持に\nご協力ください',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
    fontWeight: FontWeight.bold,
  ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: 260,
                              height: 260,
                              child: Image.asset('assets/image/page3.png')
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              '非営利での運営のため、容量の都合により、投稿やトークルームなどが予告なく削除される場合があります。\nまた、高頻度での読み書きや長時間のテキスト通話はご遠慮ください。',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).colorScheme.inverseSurface,
                          ),
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 24.0, horizontal: 48.0),
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (currentPageIndex < 2) {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(
                          currentPageIndex < 2 ? '次へ' : '完了',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onInverseSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}


  Future<void> _openLink() async {
    const url = 'https://thinking-grp.github.io/project/thinkingsns';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

Widget _buildMainScreen() {
  return NestedScrollView(
    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
      return <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                TextButton(
                  onPressed: _showInfoDialog,
                  child: const Text('ご利用時の注意事項'),
                ),
                TextButton(
                  onPressed: _openLink,
                  child: const Text('thinking SNSについて'),
                ),
              ],
            ),
          ),
        ),
        if (_miniPosts.isNotEmpty)
          SliverToBoxAdapter(
            child: SizedBox(
  height: 88,
  child: LayoutBuilder(
    builder: (context, constraints) {
      final weights = constraints.maxWidth > 800 
          ? const <int>[1, 5, 8, 9, 9, 9, 9, 9, 8, 5, 1]  // big display
          : const <int>[1, 4, 8, 9, 9, 8, 4, 1];       // touch phone display

      return CarouselView.weighted(
        flexWeights: weights,
        children: _miniPosts.map((miniPost) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Container(
              // PostListScreen의 mini 표시 부분
decoration: BoxDecoration(
  color: miniPost.backgroundColor,
  borderRadius: SmoothBorderRadius(
    cornerRadius: 16,
    cornerSmoothing: 0.7,
  ),
),
child: Stack(
  children: [
    if (miniPost.backgroundImage != null)
      Positioned.fill(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SvgPicture.asset(
            miniPost.backgroundImage!,
            fit: BoxFit.cover,
          ),
        ),
      ),
    Positioned.fill(
      child: Center(
        child: Text(
          miniPost.text,
          style: TextStyle(
            color: miniPost.textColor,
            fontSize: 16.0,
          ),
          softWrap: false,
          overflow: TextOverflow.visible,
        ),
      ),
    ),
  ],
),
            ),
          );
        }).toList(),
      );
    },
  ),
),
          ),
      ];
    },
    body: _buildPostList(),
  );
}

Widget _buildPostList() {
  if (_isLoading) {
    return const Center(child: CircularProgressIndicator());
  }
  if (_errorMessage.isNotEmpty) {
    return Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)));
  }
  if (_posts.isEmpty) {
    return const Center(child: Text('投稿がありません'));
  }

  return ListView.builder(
    itemCount: _posts.length + 1,
    itemBuilder: (context, index) {
      if (index == _posts.length) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 0), // padding縦16，横8整
          child: Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 0), // fit-contentよに調整る
              child: FilledButton.tonal(
                onPressed: _loadMorePosts,
                child: const Text('もっと読み込む'),
              ),
            ),
          ),
        );
      }
      final post = _posts[index];
      return PostCard(
        post: post,
        onReactionUpdated: (emoji) => _updateReaction(post, emoji),
        onDeletePost: (postId) => _showPostDeleteConfirmationDialog(postId),
      );
    },
  );
}
  
  Widget _buildPostHistory() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        final prefs = snapshot.data!;
        final postHistory = prefs.getStringList('postHistory') ?? [];
  
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: postHistory.length,
          itemBuilder: (context, index) {
            final post = postHistory[index].split('::');
            final postId = post[0];
            final postText = post[1];
  
            return ListTile(
              title: Text(postText),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                   _deletePost(postId);
                  // 削除後画面更新ために setState 呼び出す処理必要なる場合あります
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextCallScreen() {
  final TextEditingController createIdController = TextEditingController();
  final TextEditingController joinIdController = TextEditingController();
  final ValueNotifier<double> participantsCount = ValueNotifier(2.0);

  return NestedScrollView(
    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
      return <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                TextButton(
                  onPressed: _showInfoDialog,
                  child: const Text('ご利用時の注意事項'),
                ),
                TextButton(
                  onPressed: _openLink,
                  child: const Text('thinking SNSについて'),
                ),
              ],
            ),
          ),
        ),
      ];
    },
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ShouldRebuild(
        shouldRebuild: (oldWidget, newWidget) => false, // rebuild yebang
        child: Column(
          children: [
            // talk room saession
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
      const Text('ルームを作成', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      TextField(
        controller: createIdController,
        decoration: InputDecoration(
          labelText: 'トピックやグループの名前など...',
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest, // ダークモード対応
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline, // ダークモード対応
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
        ),
      ),
      const SizedBox(height: 16),
      ValueListenableBuilder<double>(
        valueListenable: participantsCount,
        builder: (context, value, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("最大の話す人数(${value.toInt()}人)"), // 통일
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Slider(
                  year2023: false,
                  value: value,
                  min: 2,
                  max: 5,
                  divisions: 3,
                  label: value.toInt().toString(),
                  onChanged: (newValue) {
                    participantsCount.value = newValue;
                  },
                ),
              ),
            ],
          );
        },
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.inverseSurface,
            ),
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(vertical: 24.0),
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          onPressed: () => _handleCreateSession(
            createIdController.text,
            participantsCount.value.toInt(),
          ),
          child: Text(
            '開始',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),
        ),
      ),
    ],

              ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            MediaQuery.removeViewInsets(
              context: context,
              removeBottom: true, // rebuiild yebang
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
        const Text(
          'ルームに参加',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: joinIdController,
          decoration: InputDecoration(
            labelText: '完全に一致させてください',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline, 
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Theme.of(context).colorScheme.inverseSurface, // ダークモード対応
              ),
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(vertical: 24.0),
              ),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            onPressed: () => _handleJoinSession(joinIdController.text),
            child: Text(
              '参加',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface, // テキストい色
              ),
            ),
          ),
        ),
      ],

                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  Future<void> _handleCreateSession(String roomId, int participantCount) async {
    try {
      final sessionRef = FirebaseDatabase.instance.ref().child('sessions/$roomId');
      final snapshot = await sessionRef.get();

      if (snapshot.exists) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('偶然ですね!'),
            content: const Text('指定されたIDのセッションは既に存在します'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // ッションを作成
    final Map<String, dynamic> initialData = {
      'colors': {},  // node add
    };
    
    // textdata reset
    for (var i = 0; i < participantCount; i++) {
      initialData['text$i'] = '';
    }

    // reset
    for (var i = 0; i < participantCount; i++) {
      initialData['colors']['bg$i'] = '#FFFFFF';  // d bg clr
      initialData['colors']['color$i'] = '#000000';  // d txt clr
    }

    await sessionRef.set(initialData);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TextCallSessionScreen(sessionId: roomId),
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('エラー'),
          content: Text('セッションの作成に失敗しました: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _handleJoinSession(String roomId) async {
    try {
      final sessionRef = FirebaseDatabase.instance.ref().child('sessions/$roomId');
      final snapshot = await sessionRef.get();

      if (!snapshot.exists) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('何か違うようです'),
            content: const Text('指定されたIDのセッションが見つかりません'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TextCallSessionScreen(sessionId: roomId),
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('エラー'),
          content: Text('セッションへの参加に失敗しました: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
  
@override
Widget build(BuildContext context) {
final List<Widget> screens = [
  _buildMainScreen(),
  _buildTextCallScreen(),
  _buildProfileScreen(),
  _buildBlankScreen(), // empty screen
];


  final screenWidth = MediaQuery.of(context).size.width;

  return Scaffold(
    
  resizeToAvoidBottomInset: false,
  extendBody: true,
  appBar: AppBar(
    
  title: const Text(''),
  centerTitle: false,
  scrolledUnderElevation: 0,
  toolbarHeight: 64,
  actions: [
    if (_currentIndex == 0)
      IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: _fetchLatestPosts,
      ),
  ],
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(36),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16, 
          bottom: 16
        ),
        child: Text(
          _getScreenTitle(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
        ),
      ),
    ),
  ),
  ),
  body: screens[_currentIndex], // ←シムぷるに
  bottomNavigationBar: Padding(
    padding: EdgeInsets.zero,
    child: BottomAppBar(
      color: Colors.transparent,
      elevation: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IntrinsicWidth(
            child: ClipSmoothRect(
              radius: SmoothBorderRadius(
                cornerRadius: 28,
                cornerSmoothing: 1.0,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: ShapeDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow.withOpacity(0.5),
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 28,
                        cornerSmoothing: 1.0,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNavItem(Icons.assignment, 0),
                      const SizedBox(width: 8),
                      _buildNavItem(Icons.forum, 1),
                      const SizedBox(width: 8),
                      _buildNavItem(Icons.person, 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_currentIndex == 0) const SizedBox(width: 16),
          if (_currentIndex == 0) _buildFABButton(context)

        ],
      ),
    ),
  ),
)
;
}


Widget _buildFABButton(BuildContext context) {
  return GestureDetector(
    onTap: _showCreatePostDialog,
    child: Container(
      width: 56,
      height: 56,
      decoration: ShapeDecoration(
        color: Theme.of(context).colorScheme.inverseSurface,
        shadows: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 20,
            cornerSmoothing: 1.0,
          ),
        ),
      ),
      child: Icon(
        Icons.edit,
        size: 28,
        color: Theme.of(context).colorScheme.onInverseSurface,
      ),
    ),
  );
}

Widget _buildNavItem(IconData icon, int index) {
  final bool isSelected = _currentIndex == index;
  return GestureDetector(
    onTap: () {
      setState(() {
        _currentIndex = 3;
      });
      Future.delayed(Duration(milliseconds: 2), () {
        setState(() {
          _currentIndex = index;
        });
      });
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 56,
      height: 56,
      decoration: ShapeDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
            : Colors.transparent,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 20,
            cornerSmoothing: 1.0,
          ),
        ),
      ),
      child: Icon(
        icon,
        size: 28, 
        color: Theme.of(context).colorScheme.inverseSurface,
      ),
    ),
  );
}


Widget _buildSideNavigation() {
  return Container(
    width: 80,
    color: Theme.of(context).colorScheme.surface,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildNavItem(Icons.assignment, 0),
        const SizedBox(height: 16),
        _buildNavItem(Icons.forum, 1),
        const SizedBox(height: 16),
        _buildNavItem(Icons.person, 2),
      ],
    ),
  );
}

  String _getScreenTitle() {
    switch (_currentIndex) {
      case 0:
        return '最新の投稿';
      case 1:
        return 'テキスト通話';
      case 2:
        return 'プロフィール';
      case 3:
        return ' ';
      default:
        return 'thinking SNS';
    }
  }

Widget _buildBlankScreen() {
  return Center(
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
    ),
  );
}

Widget _buildProfileScreen() {
  final TextEditingController usernameController = TextEditingController();
  final user = AuthState.currentUser;
  return NestedScrollView(
    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
      return <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                TextButton(
                  onPressed: _showInfoDialog,
                  child: const Text('ご利用時の注意事項'),
                ),
                TextButton(
                  onPressed: _openLink,
                  child: const Text('thinking SNSについて'),
                ),
              ],
            ),
          ),
        ),
      ];
    },
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ShouldRebuild(
        shouldRebuild: (oldWidget, newWidget) => false, // rebuild yebang
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

MediaQuery.removeViewInsets(
  context: context,
  removeBottom: true, // rebuild yebang
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Googleアカウント',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 4),
      if (user == null)
  FilledButton(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(
        Theme.of(context).colorScheme.inverseSurface,
      ),
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
    onPressed: () async {
      try {
        final credential = await AuthState.signInWithGoogle();
        if (credential != null && mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ログインしました: ${credential.user?.email}')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ログインに失敗しました')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    },
    child: const Text('Googleでログイン'),
  )
          else
            FilledButton(
              style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(
        Theme.of(context).colorScheme.inverseSurface,
      ),
      padding: MaterialStateProperty.all(
        const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
  onPressed: () async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ログアウト中...'))
      );
      
      await AuthState.signOut();
      
      if (mounted) {
        setState(() {}); // UI xin
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ログアウトしました！'))
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ログアウトしました'))
        );
      }
    }
  },
  child: const Text('ログアウト'),
),
    ],
  ),
),
            
          MediaQuery.removeViewInsets(
  context: context,
  removeBottom: true, // rebuild yebang
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '現在のユーザー名',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 4),
      FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final username = snapshot.data?.getString('username') ?? '未設定';
            usernameController.text = username;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 28, // yuser name font size
                  ),
                ),
                const SizedBox(height: 16), // bottom
              ],
            );
          }
          return const CircularProgressIndicator();
        },
      ),
    ],
  ),
),

          // user form
          Text('ユーザー名を変更', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
  controller: usernameController,
  decoration: InputDecoration(
    filled: true,
    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.outline,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.outline,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
  ),
),
const SizedBox(height: 16),
SizedBox(
  width: double.infinity,
  child: ShouldRebuild(
    shouldRebuild: (oldWidget, newWidget) => false, // raebuild yebang
    child: FilledButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          Theme.of(context).colorScheme.inverseSurface, // dark:white
        ),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(vertical: 24.0),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      onPressed: () async {
  final prefs = await SharedPreferences.getInstance();
  final newUsername = usernameController.text.trim();

  if (newUsername.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ユーザー名を入力してください')),
    );
    return;
  }

  await prefs.setString('username', newUsername);

  if (mounted) {
    setState(() {
      _currentIndex = 3; 
    });

    Future.delayed(Duration(milliseconds: 2), () {
      setState(() {
        _currentIndex = 2; //xin index
        });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ユーザー名を保存しました！')),
    );
  }

  // バブっグエオグ
  print('ユーザー名が保存されました: $newUsername');
},

      child: Text(
        '保存',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onInverseSurface, // ボたんテクスト色
        ),
      ),
    ),
  ),
),

          const SizedBox(height: 24),
          Text('投稿履歴', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
    _buildPostHistory(),

        ],

        ),
      ),
    ),
  );
}

}

Widget _buildPostHistory() {
  return FutureBuilder<SharedPreferences>(
    future: SharedPreferences.getInstance(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return CircularProgressIndicator();
      }
      final prefs = snapshot.data!;
      final postHistory = prefs.getStringList('postHistory') ?? [];

      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: postHistory.length,
        itemBuilder: (context, index) {
          final post = postHistory[index].split('::');
          final postId = post[0];
          final postText = post[1];

          return ListTile(
            title: Text(postText),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                  // fix errrrrrrrrrrror
                  _deletePost(index); 
                  Navigator.of(context).pop();
                },
            ),
          );
        },
      );
    },
  );
}

void _deletePost(int index) async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? postHistory = prefs.getStringList('postHistory');
  if (postHistory != null && index >= 0 && index < postHistory.length) {
    postHistory.removeAt(index);
    await prefs.setStringList('postHistory', postHistory);
    // 削除後画面更新ために setState 呼び出す処理必要なる場合あります
  }
}

  class TextCallSessionScreen extends StatefulWidget {
    final String sessionId;

    const TextCallSessionScreen({
      super.key,
      required this.sessionId,
    });

    @override
    State<TextCallSessionScreen> createState() => _TextCallSessionScreenState();
  }


  class _TextCallSessionScreenState extends State<TextCallSessionScreen> {
    final DatabaseReference _database = FirebaseDatabase.instance.ref();
    StreamSubscription? _subscription;
    Map<String, String> _texts = {};
    final Map<int, TextEditingController> _controllers = {};
    final Map<int, String> _pendingWrites = {};
    Timer? _writeTimer;

    // database color
Map<int, Color> _backgroundColors = {};
Map<int, Color> _textColors = {};

void _showDeleteConfirmationDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('削除しますか?'),
        content: const Text('このセッションを削除しますか？\n参加者全員が退出されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // close
              _deleteSession(); // ddelete
            },
            child: const Text('削除'),
          ),
        ],
      );
    },
  );
}

Future<void> _deleteSession() async {
  try {
    await _database
        .child('sessions/${widget.sessionId}')
        .remove();
    
    if (!mounted) return;
    // 2back
    Navigator.of(context)
      ..pop() // close
      ..pop(); // close
    
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('セッションの削除に失敗しました')),
    );
  }
}

    // show colorpicker
void _showColorPickerDialog(BuildContext context, Color initialColor, Function(Color) onColorSelected, String title) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      Color selectedColor = initialColor;
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (Color color) {
              selectedColor = color;
            },
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('キャンセル'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('決定'),
            onPressed: () {
              onColorSelected(selectedColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

// save
void _updateColors(int index, {Color? backgroundColor, Color? textColor}) {
  if (backgroundColor != null) {
    _backgroundColors[index] = backgroundColor;
    _database
      .child('sessions/${widget.sessionId}/colors/bg$index')
      .set('#${backgroundColor.value.toRadixString(16).substring(2)}');
  }
  if (textColor != null) {
    _textColors[index] = textColor;
    _database
      .child('sessions/${widget.sessionId}/colors/color$index')
      .set('#${textColor.value.toRadixString(16).substring(2)}');
  }
}

// color update
void _updateColorsFromDatabase() {
  _database
    .child('sessions/${widget.sessionId}/colors')
    .get()
    .then((snapshot) {
      if (snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          for (var i = 0; i < _texts.length; i++) {
            if (data['bg$i'] != null) {
              _backgroundColors[i] = _hexToColor(data['bg$i']);
            }
            if (data['color$i'] != null) {
              _textColors[i] = _hexToColor(data['color$i']);
            }
          }
        });
      }
    });
}


// color update(?)
Color _hexToColor(String hexCode) {
  try {
    final hexString = hexCode.replaceAll('#', '');
    return Color(int.parse('0xFF$hexString'));
  } catch (e) {
    return Colors.white;
  }
}


@override
void initState() {
  super.initState();
  _subscribeToSession();
  // color update
  Timer.periodic(const Duration(seconds: 2), (timer) {
    if (!mounted) {
      timer.cancel();
      return;
    }
    _updateColorsFromDatabase();
  });
}

    @override
    void dispose() {
      _subscription?.cancel();
      for (var controller in _controllers.values) {
        controller.dispose();
      }
      _writeTimer?.cancel();
      super.dispose();
    }

void _subscribeToSession() {
  _subscription = _database
      .child('sessions/${widget.sessionId}')
      .onValue
      .listen((event) {
    if (!mounted) return;

    if (event.snapshot.value == null) {
      // ih delete
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('残念ですが...'),
            content: const Text('このセッションは削除されました。'),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(); // closeu
                  Navigator.of(context).pop(); // close
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    final data = Map<String, dynamic>.from(event.snapshot.value as Map);
    setState(() {
      _texts.clear();
      data.forEach((key, value) {
        if (key.startsWith('text')) {
          _texts[key] = value.toString();
        }
      });
      _updateControllers();
    });
  });
}

  TextEditingController _getController(int index) {
    return _controllers.putIfAbsent(
      index,
      () => TextEditingController(text: _texts['text$index'] ?? ''),
    );
  }

  void _scheduleDatabaseWrite(int index, String value) {
    _pendingWrites[index] = value;
    
    _writeTimer?.cancel();
    _writeTimer = Timer(const Duration(milliseconds: 100), () {
      _pendingWrites.forEach((index, value) {
        _database
          .child('sessions/${widget.sessionId}/text$index')
          .set(value)
          .catchError((error) {
            print('書き込みエラー: $error');
          });
      });
      _pendingWrites.clear();
    });
  }

  void _updateControllers() {
    _texts.forEach((key, value) {
      if (key.startsWith('text')) {
        final index = int.parse(key.substring(4));
        final controller = _getController(index);
        if (controller.text != value) {
          controller.text = value;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        widget.sessionId,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        // delete
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: _showDeleteConfirmationDialog,
          tooltip: 'セッションを削除',
        ),
      ],
    ),
        body: Padding(
  padding: const EdgeInsets.all(16.0),
  child: ListView.builder(
  itemCount: _texts.length,
  itemBuilder: (context, index) {
    return Column(
      children: [
        // btn
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: Icon(Icons.format_color_fill, 
                color: _backgroundColors[index] ?? Theme.of(context).colorScheme.surface),
              label: const Text('背景色'),
              onPressed: () => _showColorPickerDialog(
                context,
                _backgroundColors[index] ?? Theme.of(context).colorScheme.surface,
                (color) => _updateColors(index, backgroundColor: color),
                '背景色を選択',
              ),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              icon: Icon(Icons.format_color_text,
                color: _textColors[index] ?? Theme.of(context).colorScheme.onSurface),
              label: const Text('文字色'),
              onPressed: () => _showColorPickerDialog(
                context,
                _textColors[index] ?? Theme.of(context).colorScheme.onSurface,
                (color) => _updateColors(index, textColor: color),
                '文字色を選択',
              ),
            ),
          ],
        ),
        // textbox
        Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          color: _backgroundColors[index] ?? Theme.of(context).colorScheme.surfaceContainerHigh,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: SizedBox(
            height: 80,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _getController(index),
                  style: TextStyle(
                    fontSize: 18,
                    color: _textColors[index] ?? Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '${index + 1}番目のメッセージ',
                    hintStyle: TextStyle(
                      color: (_textColors[index] ?? Theme.of(context).colorScheme.onSurface).withOpacity(0.5),
                    ),
                  ),
                  onChanged: (value) => _scheduleDatabaseWrite(index, value),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  },
)
),

      );
    }
 }

class Post {
  final String id;
  final String username;
  final Color backgroundColor;
  final Color textColor;
  final DateTime createdAt;
  final bool delay;
  final Map<String, int> reactions;
  final String text;
  final String? backgroundImage; // filename

  Post({
    required this.id,
    required this.username,
    required this.backgroundColor,
    required this.textColor,
    required this.createdAt,
    required this.delay,
    required this.reactions,
    required this.text,
    this.backgroundImage,
  });

  factory Post.fromDocument(firestore.DocumentSnapshot doc) {
    final id = doc.id;
    final data = doc.data() as Map<String, dynamic>;
    final username = data['username'] as String? ?? '不明なユーザー';
    final bgColor = _hexToColor(data['bg'] ?? '#FFFFFF');
    final textColor = _hexToColor(data['color'] ?? '#000000');
    final backgroundImage = data['bgimg'] as String?;
    
    // createdAt stamp
    final firestore.Timestamp timestamp = data['createdAt'] is firestore.Timestamp 
        ? data['createdAt'] 
        : firestore.Timestamp.now();
    final createdAt = timestamp.toDate();
    
    // if delay
    final delay = data['delay'] == true;
    final reactionsData = data['reactions'] as Map<String, dynamic>? ?? {};
    final reactions = <String, int>{};
    reactionsData.forEach((key, value) {
      reactions[key] = (value is int) ? value : 0;
    });
    
    final text = data['text'] as String? ?? '';
    
    return Post(
      id: id,
      username: username,
      backgroundColor: bgColor,
      textColor: textColor,
      createdAt: createdAt,
      delay: delay,
      reactions: reactions,
      text: text,
      backgroundImage: data['bgimg'] as String?, //bgimg er
    );
  }
  
  static Color _hexToColor(String hexCode) {
    try {
      final hexString = hexCode.replaceAll('#', '');
      return Color(int.parse('0xFF$hexString'));
    } catch (e) {
      return Colors.white;
    }
  }
  Color getLighterBackgroundColor(BuildContext context) {
  // dark
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return isDarkMode
      ? Color.lerp(backgroundColor, Colors.black, 0.9) ?? backgroundColor
      : Color.lerp(backgroundColor, Colors.white, 0.9) ?? backgroundColor;
}

Color getDarkerTextColor(BuildContext context) {
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  return isDarkMode
      ? Color.lerp(textColor, Colors.white, 0.8) ?? textColor
      : Color.lerp(textColor, Colors.black, 0.8) ?? textColor;
}

}

// 3gul post
class MiniPost {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final DateTime createdAt;
final String? backgroundImage;
  MiniPost({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.createdAt,
    this.backgroundImage,
  });
}

class PostCard extends StatefulWidget {
  final Post post;
  final Function(String) onReactionUpdated;
  final Function(String) onDeletePost;

  const PostCard({
    super.key, 
    required this.post,
    required this.onDeletePost,
    required this.onReactionUpdated,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String _displayText = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.post.delay) {
      _startDelayedText();
    } else {
      _displayText = widget.post.text;
    }
  }

  void _startDelayedText() {
    void updateText() {
      final now = DateTime.now();
      final elapsedSeconds = now.difference(widget.post.createdAt).inSeconds;
      final charactersToShow = (elapsedSeconds / 20).floor();
      
      if (charactersToShow < widget.post.text.length) {
        setState(() {
          _displayText = widget.post.text.substring(0, charactersToShow);
        });
      } else {
        setState(() {
          _displayText = widget.post.text;
        });
        _timer?.cancel();
      }
    }

    updateText();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateText();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  final formattedDate = DateFormat('yyyy年MM月dd日 HH:mm:ss').format(widget.post.createdAt);
final Map<String, String> reactionSvgs = {
    '❤️': 'assets/icons/reaction_like.svg',
    '👏': 'assets/icons/reaction_clap.svg',
    '🤔': 'assets/icons/reaction_thinking.svg',
    '🤝': 'assets/icons/reaction_handshake.svg',
    '✅': 'assets/icons/reaction_check.svg',
  };

const double iconSize = 20.0;
return Hero(
  tag: 'post-${widget.post.id}',
  child: Material(
    color: const Color.fromARGB(0, 0, 0, 0),
    child: Card(
      color: const Color.fromARGB(0, 0, 0, 0),
      elevation: 0, // no shadow
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12), // padding
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: widget.post.backgroundColor,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (widget.post.backgroundImage != null)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SvgPicture.asset(
                    widget.post.backgroundImage!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            // InkWellをMaterialでラップして手前に表示
            Material(
              color: Colors.transparent, // Materialの背景を透明に設定
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => PostDetailScreen(
                        post: widget.post,
                        onReactionUpdated: widget.onReactionUpdated,
                      ),
                      transitionDuration: const Duration(milliseconds: 500),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return SharedAxisTransition(
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          transitionType: SharedAxisTransitionType.scaled,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(24), // ここでborderRadiusを指定
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.username,
                        style: TextStyle(
                          color: widget.post.textColor.withOpacity(1),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // fix Text を SelectableText 変更
                      SelectableText(
                        widget.post.delay ? _displayText : widget.post.text,
                        style: TextStyle(
                          color: widget.post.textColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: widget.post.textColor.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: reactionSvgs.entries.map((entry) {
                          final emoji = entry.key;
                          final svgPath = entry.value;
                          final count = widget.post.reactions[emoji] ?? 0;
                          return Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: widget.post.textColor,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                widget.onReactionUpdated(emoji);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    svgPath,
                                    width: iconSize,
                                    height: iconSize,
                                  ),
                                  const SizedBox(width: 4),
                                  Text('$count'),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);

}
}

class PostDetailScreen extends StatefulWidget {
  final Post post;
  final Function(String) onReactionUpdated;

  const PostDetailScreen({
    super.key, 
    required this.post,
    required this.onReactionUpdated,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> { 
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isLoadingReplies = true;
  String _displayText = '';
  Timer? _timer;
  Map<String, Map<String, dynamic>> _replies = {};

  @override
  void initState() {
    super.initState();
    if (widget.post.delay) {
      _startDelayedText();
    } else {
      _displayText = widget.post.text;
    }
    _loadReplies();
  }

  Future<void> _fetchLatestPosts() async {
    setState(() {});
  }

  Future<void> _loadReplies() async {
  try {
    final docRef = firestore.FirebaseFirestore.instance
        .collection('post-1')
        .doc('wsbxPa2kQDaexLV9hiVC')
        .collection('maintext')
        .doc(widget.post.id);

    final docSnapshot = await docRef.get();
    final data = docSnapshot.data();
    
    if (data != null && data['replies'] != null) {
      final repliesMap = Map<String, dynamic>.from(data['replies']);
      final Map<String, Map<String, dynamic>> formattedReplies = {};

      for (var entry in repliesMap.entries) {
        final replyId = entry.key;
        final replyData = entry.value as Map<String, dynamic>;

        formattedReplies[replyId] = {
          'text': replyData['text'] ?? '',
          'createdAt': replyData['createdAt'] is firestore.Timestamp
              ? (replyData['createdAt'] as firestore.Timestamp).toDate()
              : DateTime.now(),
        };
      }

      setState(() {
        _replies = formattedReplies;
        _isLoadingReplies = false;
      });
    } else {
      setState(() {
        _replies = {};
        _isLoadingReplies = false;
      });
    }
  } catch (error) {
    print('返信の読み込みエラー: ${error.toString()}');
    setState(() {
      _isLoadingReplies = false;
    });
  }
 }

    
  void _startDelayedText() {
    void updateText() {
      final now = DateTime.now();
      final elapsedSeconds = now.difference(widget.post.createdAt).inSeconds;
      final charactersToShow = (elapsedSeconds / 20).floor();
      
      if (charactersToShow < widget.post.text.length) {
        setState(() {
          _displayText = widget.post.text.substring(0, charactersToShow);
        });
      } else {
        setState(() {
          _displayText = widget.post.text;
        });
        _timer?.cancel();
      }
    }
    updateText();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateText();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _commentController.dispose();
    super.dispose();
  }
  
  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // xon comment
      final String replyId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // comment
      final Map<String, dynamic> replyData = {
        'text': _commentController.text.trim(),
        'createdAt': firestore.FieldValue.serverTimestamp(),
      };
      
      // Firestore update
      final docRef = firestore.FirebaseFirestore.instance
          .collection('post-1')
          .doc('wsbxPa2kQDaexLV9hiVC')
          .collection('maintext')
          .doc(widget.post.id);
          
      await docRef.update({
        'replies.$replyId': replyData,
      });
      
      // local data update
      setState(() {
        _replies[replyId] = {
          'text': _commentController.text.trim(),
          'createdAt': firestore.Timestamp.now(),
        };
        _commentController.clear();
        _isSubmitting = false;
      });
      
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      print('コメント投稿エラー: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('コメントの投稿に失敗しました'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // clr
    
    final backgroundColor = widget.post.getLighterBackgroundColor(context);
  final textColor = widget.post.getDarkerTextColor(context);
    // format
    final formattedDate = DateFormat('yyyy年MM月dd日 HH:mm:ss').format(widget.post.createdAt);
    

    // reaction
  final Map<String, String> reactionSvgs = {
      '❤️': 'assets/icons/reaction_like.svg',
      '👏': 'assets/icons/reaction_clap.svg',
      '🤔': 'assets/icons/reaction_thinking.svg',
      '🤝': 'assets/icons/reaction_handshake.svg',
      '✅': 'assets/icons/reaction_check.svg',
    };

    // size(px????)
  const double iconSize = 20.0;
    
    // xin
    final sortedReplies = _replies.entries.toList()
      ..sort((a, b) {
        final aTimestamp = a.value['createdAt'] is firestore.Timestamp 
            ? (a.value['createdAt'] as firestore.Timestamp).toDate() 
            : DateTime.now();
        final bTimestamp = b.value['createdAt'] is firestore.Timestamp 
            ? (b.value['createdAt'] as firestore.Timestamp).toDate() 
            : DateTime.now();
        return bTimestamp.compareTo(aTimestamp);
      });

// PostDetailScreen ye build mesot
return Hero(
  tag: 'post-${widget.post.id}',
  child: Material(
    color: Colors.transparent,
    child: Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('返信'),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 投稿内容
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // メインの投稿テキスト
                SelectableText(
                  widget.post.delay ? _displayText : widget.post.text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: textColor.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                // btns
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: reactionSvgs.entries.map((entry) {
                    final emoji = entry.key;
                    final svgPath = entry.value;
                    final count = widget.post.reactions[emoji] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: textColor,
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          widget.onReactionUpdated(emoji);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              svgPath,
                              width: iconSize,
                              height: iconSize,
                            ),
                            const SizedBox(width: 4),
                            Text('$count'),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'コメント (${_replies.length})',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!_isLoadingReplies) ...sortedReplies.map((reply) {
                  String replyDate = '';
                  if (reply.value['createdAt'] is firestore.Timestamp) {
                    final timestamp = reply.value['createdAt'] as firestore.Timestamp;
                    replyDate = DateFormat('MM/dd HH:mm').format(timestamp.toDate());
                  }
                  return Card(
                    color: Colors.transparent,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          SelectableText(
                            reply.value['text'] ?? '(空のコメント)',
                            style: TextStyle(
                              color: widget.post.getDarkerTextColor(context),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          // text box
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'コメントを入力...',
                        hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: textColor.withOpacity(0.2)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: textColor.withOpacity(0.2)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: textColor.withOpacity(0.4)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        fillColor: textColor.withOpacity(0.05),
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSubmitting ? null : _submitComment,
                    icon: _isSubmitting
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: textColor,
                            ),
                          )
                        : Icon(Icons.send, color: textColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);

  }
  
}

