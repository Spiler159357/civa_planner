import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage()
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super (key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

JavascriptChannel snackbarJavascriptChannel(BuildContext context) {
  return JavascriptChannel(
    name: 'SnackbarJSChannel',
    onMessageReceived: (JavascriptMessage message) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(message.message),
      ));
    }
  );
}

class _MyHomePageState extends State<MyHomePage> {

  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  GlobalKey key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CIVA"),
        actions: <Widget>[
          NavigationControls(_controller.future)
        ],
      ),
      body: Builder(
        builder: (BuildContext context) {
          Navigator.of(context).push(MaterialPageRoute(builder: () => MyHomePage(key: _key,)),);
          return WebView(
            initialUrl: 'https://cyivacom.firebaseapp.com/',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            javascriptChannels: <JavascriptChannel>[
              snackbarJavascriptChannel(context)].toSet(),
            );
          },
        ),
      );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture);
  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(

      future: _webViewControllerFuture,
      builder: (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady = snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady ? null: () async {
                if(await controller.canGoBack()) {
                  controller.goBack();
                }
                else {
                  Scaffold.of(context).showSnackBar(const SnackBar(content: Text("더이상 뒤로 갈 수 없습니다"),));
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady ? null: () async {
                if(await controller.canGoForward()) {
                  controller.goForward();
                }
                else {
                  Scaffold.of(context).showSnackBar(const SnackBar(content: Text("더이상 앞으로 갈 수 없습니다"),));
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: !webViewReady ? null: () async {
                controller.reload();
              },
            ),
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: !webViewReady ? null: () async {
                showUserAgent(controller, context);
              },
            ),
          ],
        );
    }
    );
  }

  showUserAgent(WebViewController controller, BuildContext context) {
    controller.evaluateJavascript('SnackbarJsChannel.postMessage("User Agent: " + navigator.userAgent);');
  }

}

/*

1.휴대전화에서 '뒤로가기' 실행시 어플리케이션 꺼지는 문제 해결
2.메인화면으로 돌아오는 버튼 추가
3.새로고침 버튼 추가
4.옆으로 스크롤되는 문제 해결
5.줌앤아웃기능 추가
6.컴퓨터쪽이랑 계속 병행하면서 진행할것

 */