import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pitopartner/configs.dart';
import 'package:pitopartner/services/shared_preferences.service.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'firebase_options.dart';
import 'package:pitopartner/services/firebase_messaging.service.dart';
import 'package:pitopartner/services/logger.service.dart';
import 'package:pitopartner/services/notification.service.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/foundation.dart';

class AppColors {
  static const secondary = Color(0xff292929);
  static const secondaryLight = Color(0xff4c4c4c);
}

class TextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 30.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle h5 = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle h6 = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyText1 = TextStyle(
    fontSize: 16.0,
  );

  static const TextStyle bodyText2 = TextStyle(
    fontSize: 14.0,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10.0,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle link = TextStyle(
    fontSize: 16.0,
    color: Colors.blue,
  );

  static const TextStyle error = TextStyle(
    fontSize: 16.0,
    color: Colors.red,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const PITOPartnerApp());

  FirebaseMessagingService.init();
  SendbirdChat.init(appId: AppConfigs.sendbridAppId);
  await NotificationService().init();
}

class PITOPartnerApp extends StatelessWidget {
  const PITOPartnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PITO Partner',
      theme: ThemeData(
        textTheme: GoogleFonts.manropeTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xffef3d2a)),
        useMaterial3: true,
      ),
      home: const AppWithNavigationBar(),
    );
  }
}

class AppWithNavigationBar extends StatefulWidget {
  const AppWithNavigationBar({super.key});

  @override
  State<AppWithNavigationBar> createState() => _AppWithNavigationBarState();
}

class _AppWithNavigationBarState extends State<AppWithNavigationBar>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int selectedIndex = 0;
  bool isLoading = false;
  final webViewCookieManager = WebviewCookieManager();
  InAppWebViewController? iawvController;
  late PullToRefreshController pullToRefreshController;
  final iawvKey = GlobalKey();

  final InAppWebViewGroupOptions iawvGroupOptions = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
          incognito: false,
          cacheEnabled: true,
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false,
          supportZoom: false,
          userAgent: Platform.isIOS
              ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_1_2 like Mac OS X) AppleWebKit/605.1.15'
                  ' (KHTML, like Gecko) Version/13.0.1 Mobile/15E148 Safari/604.1'
              : 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) '
                  'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36',
          javaScriptEnabled: true),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
        domStorageEnabled: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
        sharedCookiesEnabled: true,
      ));

  void loadUrl(String url) {
    if (iawvController != null) {
      iawvController!.loadUrl(
          urlRequest: URLRequest(
              url: Uri.parse(
        url,
      )));
    }
  }

  void setUpPullToRefreshController() {
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.red,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          iawvController?.reload();
        } else if (Platform.isIOS) {
          iawvController?.loadUrl(
              urlRequest: URLRequest(url: await iawvController?.getUrl()));
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();

    setUpPullToRefreshController();

    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> saveLocalStorageIntoSharePreference() async {
    String jsonString = await iawvController!.evaluateJavascript(
      source: """
(function() {
  var allKeys = Object.keys(localStorage);
  var allValues = allKeys.map(function(key) {
    return localStorage.getItem(key);
  });
  return JSON.stringify({keys: allKeys, values: allValues});
})()
""",
    );

    Map<String, dynamic> localStorageData = jsonDecode(jsonString);
    SharedPreferencesService.saveLocalStorage(localStorageData);
  }

  Future<void> saveCookiesIntoSharePreference() async {
    CookieManager cookieManager = CookieManager.instance();
    List<Cookie> cookies = await cookieManager.getCookies(
        url: Uri.parse(AppConfigs.appUrl),
        iosBelow11WebViewController: iawvController);
    SharedPreferencesService.saveCookies(cookies);
    printTokenInCookies(cookies);
  }

  void callbackOnWebviewDestroy() async {
    await saveCookiesIntoSharePreference();
    await saveLocalStorageIntoSharePreference();
  }

  void printTokenInCookies(List<Cookie> cookies) {
    try {
      var token = cookies.firstWhere((element) => element.name == 'token');
      LoggerService.log('TELE: $token');
    } catch (e) {
      LoggerService.log('Token is not found in cookies');
    }
  }

  void viewSavedCookies() async {
    List<Cookie> cookies = await SharedPreferencesService.getCookies();
    printTokenInCookies(cookies);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive:
        callbackOnWebviewDestroy();
        break;
      case AppLifecycleState.resumed:
        viewSavedCookies();
        break;
    }
  }

  Future<void> launchExternalURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      try {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } catch (e) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  Future<void> viewCookies() async {
    var iavwCookies = await iawvController!.evaluateJavascript(source: """
(function() {
  var allCookies = document.cookie;
  return JSON.stringify({cookies: allCookies});
})()
""");
    LoggerService.log('Check client token onWebViewCreated : $iavwCookies');
  }

  Future<void> initLocalStorage() async {
    Map<String, dynamic>? localStorageData =
        await SharedPreferencesService.getLocalStorage();

    if (localStorageData != null && localStorageData.isNotEmpty) {
      await iawvController!.evaluateJavascript(
        source: """
                      (function() {
                        var localStorageData = ${jsonEncode(localStorageData)};
          Object.keys(localStorageData).forEach(function(key) {
            localStorage.setItem(key, localStorageData[key]);
          });
        })()
        """,
      );
    }
  }

  Future<void> removeAllRemainingCookies() async {
    CookieManager cookieManager = CookieManager.instance();
    await cookieManager.deleteAllCookies();
  }

  void initCookieToInAppWebview() async {
    List<Cookie> cookies = await SharedPreferencesService.getCookies();
    printTokenInCookies(cookies);

    if (cookies.isNotEmpty) {
      CookieManager cookieManager = CookieManager.instance();
      for (var cookie in cookies) {
        cookieManager.setCookie(
          url: Uri.parse(AppConfigs.appUrl),
          name: cookie.name,
          value: cookie.value,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (await iawvController!.canGoBack()) {
          iawvController!.goBack();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                key: iawvKey,
                initialUrlRequest: URLRequest(
                    url: Uri.parse(
                  AppConfigs.appUrl,
                )),
                initialOptions: iawvGroupOptions,
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (controller) async {
                  iawvController = controller;

                  await initLocalStorage();
                  await removeAllRemainingCookies();
                  initCookieToInAppWebview();
                  await viewCookies();
                },
                onLoadStart: (controller, url) async {
                  setState(() {
                    isLoading = true;
                  });
                },
                androidOnPermissionRequest:
                    (controller, origin, resources) async {
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  return NavigationActionPolicy.ALLOW;
                },
                onLoadStop: (controller, url) async {
                  pullToRefreshController.endRefreshing();
                },
                onLoadError: (controller, url, code, message) {
                  pullToRefreshController.endRefreshing();
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    pullToRefreshController.endRefreshing();
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                onUpdateVisitedHistory: (controller, url, androidIsReload) {},
                onConsoleMessage: (controller, consoleMessage) {},
              ),
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : const Stack(),
            ],
          ),
        ),
      ),
    );
  }
}
