import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:tamdansers_lv2/app/themes/app_colors.dart';

class InAppPdfViewer extends StatefulWidget {
  final String url;
  final String title;

  const InAppPdfViewer({super.key, required this.url, required this.title});

  @override
  State<InAppPdfViewer> createState() => _InAppPdfViewerState();
}

class _InAppPdfViewerState extends State<InAppPdfViewer> {
  late final WebViewController _controller;
  late final String _viewerUrl;
  int _loadingProgress = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    // Google Docs Viewer converts remote PDF to HTML so any WebView can render it
    _viewerUrl =
        'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(widget.url)}';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xff1A1A2E))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() => _loadingProgress = progress);
          },
          onPageStarted: (_) {
            setState(() {
              _hasError = false;
              _loadingProgress = 0;
            });
          },
          onPageFinished: (_) {
            setState(() => _loadingProgress = 100);
          },
          onWebResourceError: (error) {
            setState(() => _hasError = true);
          },
        ),
      )
      ..loadRequest(Uri.parse(_viewerUrl));
  }

  @override
  Widget build(BuildContext context) {
    final isKm = Get.locale?.languageCode == 'km';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xff0F0F12) : const Color(0xff1A1A2E),
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xff1A1A1E) : const Color(0xff1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_loadingProgress < 100)
              Text(
                isKm ? 'កំពុងទាញយក...' : 'Loading...',
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.white,
          ),
          onPressed: () => Get.back(),
        ),
        bottom: _loadingProgress < 100
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  value: _loadingProgress / 100,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              )
            : null,
      ),
      body: _hasError
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                      size: 56,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isKm ? 'មិនអាចបើកឯកសារ PDF បានទេ' : 'Failed to load PDF',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                          _loadingProgress = 0;
                        });
                        _controller.loadRequest(Uri.parse(_viewerUrl));
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(isKm ? 'ព្យាយាមម្ដងទៀត' : 'Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : WebViewWidget(controller: _controller),
    );
  }
}
