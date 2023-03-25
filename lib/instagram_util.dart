import 'dart:convert';

import 'package:dio/dio.dart';

class InstagramUtil {
  static Future<String> getDownloadUrl(String url) async {
    var linkEdit = url.replaceAll(" ", "").split("/");
    var response = await Dio().get(Uri.parse(
            '${linkEdit[0]}//${linkEdit[2]}/${linkEdit[3]}/${linkEdit[4]}' +
                "?__a=1&__d=dis")
        .toString());
    var data = response.data;
    var graphql = data['graphql'];
    var shortcodeMedia = graphql['shortcode_media'];
    var videoUrl = shortcodeMedia['video_url'];
    return videoUrl;
  }

  static Future<String> getPreviewUrl(String url) async {
    var linkEdit = url.replaceAll(" ", "").split("/");
    var response = await Dio().get(Uri.parse(
            '${linkEdit[0]}//${linkEdit[2]}/${linkEdit[3]}/${linkEdit[4]}' +
                "?__a=1&__d=dis")
        .toString());
    var data = response.data;
    var graphql = data['graphql'];
    var shortcodeMedia = graphql['shortcode_media'];
    var videoUrl = shortcodeMedia['display_url'];
    return videoUrl;
  }
}
