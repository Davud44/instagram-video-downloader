import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:instagram/instagram_util.dart';
import 'package:path_provider/path_provider.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({Key? key}) : super(key: key);

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  bool _previewLoading = false, _videoDownloading = false;

  String? _previewUrl;

  void _getPreviewUrl() async {
    setState(() {
      _previewLoading = true;
      _previewUrl = null;
    });
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      String url = await InstagramUtil.getPreviewUrl(clipboardData!.text!);
      setState(() {
        _previewUrl = url;
        _previewLoading = false;
      });
    } catch (e) {
      setState(() {
        _previewLoading = false;
      });
      _showErrorSnackBar();
    }
  }

  void _getDownloadUrl() async {
    setState(() {
      _videoDownloading = true;
    });
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      String url = await InstagramUtil.getDownloadUrl(clipboardData!.text!);
      File file = await _downloadVideo(url, '${DateTime.now()}.mp4');
      await GallerySaver.saveVideo(file.path);
      setState(() {
        _videoDownloading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video yükləndi'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF4BB543),
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _videoDownloading = false;
      });
      _showErrorSnackBar();
    }
  }

  Future<File> _downloadVideo(String url, String fileName) async {
    Dio dio = Dio();
    try {
      var response = await dio.get(url,
          options: Options(responseType: ResponseType.bytes));
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      File file = File('$appDocPath/$fileName');
      return file.writeAsBytes(response.data);
    } catch (e) {
      throw Exception('Failed to download video: $e');
    }
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Xəta baş verdi'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFFFF9494),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            _getPreviewUrl();
                          },
                          child: _previewLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator.adaptive(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ))
                              : const Text('Yapışdır')),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: ElevatedButton(
                          onPressed: () {
                            _getDownloadUrl();
                          },
                          child: _videoDownloading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator.adaptive(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ))
                              : const Text('Yüklə')),
                    )
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                if (_previewUrl != null) ...[Image.network(_previewUrl!)]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
