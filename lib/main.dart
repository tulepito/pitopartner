import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pitopartner/configs.dart';
import 'firebase_options.dart';
import 'package:pitopartner/screens/home.screen.dart';
import 'package:pitopartner/services/firebase_messaging.service.dart';
import 'package:pitopartner/services/in_app_chat_channel.dart';
import 'package:pitopartner/services/logger.service.dart';
import 'package:pitopartner/services/notification.service.dart';
import 'package:pitopartner/services/sendbird.service.dart';
import 'package:sendbird_chat_sdk/sendbird_chat_sdk.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  bool isLoading = false;

  void processInAppChatChannelMessage(String message) {
    LoggerService.log(message);
    InAppChatChannelMessage inAppChatChannelMessage =
        InAppChatChannelMessage.fromJson(jsonDecode(message));
    String type = inAppChatChannelMessage.type;

    if ((type == 'login' || type == 'logout')) {
      String? userId = inAppChatChannelMessage.data?.userId;

      switch (type) {
        case 'login':
          SendbirdService.setPushTokenForUser(userId!);
          break;
        case 'logout':
          SendbirdService.removePushTokenForUser();
          break;

        default:
      }
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      try {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } catch (e) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  late WebViewController controller = WebViewController()
    ..setUserAgent(
      Platform.isIOS
          ? 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_1_2 like Mac OS X) AppleWebKit/605.1.15' +
              ' (KHTML, like Gecko) Version/13.0.1 Mobile/15E148 Safari/604.1'
          : 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) ' +
              'AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36',
    )
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..enableZoom(false)
    ..addJavaScriptChannel('inAppChat',
        onMessageReceived: (JavaScriptMessage message) {
      processInAppChatChannelMessage(message.message);
    })
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {},
        onPageStarted: (String url) {
          setState(() {
            isLoading = true;
          });
        },
        onPageFinished: (String url) {
          setState(() {
            isLoading = false;
          });
        },
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://pito.vn')) {
            _launchURL(request.url);
            return NavigationDecision.prevent;
          }

          return NavigationDecision.navigate;
        },
      ),
    );

  @override
  void initState() {
    super.initState();
    controller.loadRequest(Uri.parse(AppConfigs.appUrl));
  }

  Future<bool> _pop() {
    return controller.canGoBack().then((value) {
      if (value) {
        controller.goBack();
        return Future.value(false);
      }

      return Future.value(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _pop(),
      child: Scaffold(
        body: Center(
            child: HomeScreen(
          controller: controller,
          isLoading: isLoading,
        )),
      ),
    );
  }
}
