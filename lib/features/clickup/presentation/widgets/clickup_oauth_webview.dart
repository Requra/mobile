import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:requra/features/clickup/presentation/cubit/clickup_cubit.dart';

class ClickUpOAuthWebView extends StatefulWidget {
  final String authUrl;
  final String projectId;

  const ClickUpOAuthWebView({
    Key? key,
    required this.authUrl,
    required this.projectId,
  }) : super(key: key);

  @override
  State<ClickUpOAuthWebView> createState() => _ClickUpOAuthWebViewState();
}

class _ClickUpOAuthWebViewState extends State<ClickUpOAuthWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.tryParse(request.url);
            if (uri != null &&
                uri.scheme == 'requra' &&
                uri.host == 'clickup') {
              // Intercept deep link callback
              final code = uri.queryParameters['code'];
              final state = uri.queryParameters['state'];
              if (code != null) {
                context
                    .read<ClickUpCubit>()
                    .completeOAuth(code, state ?? widget.projectId);
                if (mounted) {
                  Navigator.of(context).pop();
                }
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect ClickUp'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Cancel and fetch status again
            context.read<ClickUpCubit>().fetchStatus(widget.projectId);
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
