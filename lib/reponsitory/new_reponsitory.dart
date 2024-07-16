import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newsapp/models/categories_new_model.dart';
import 'package:newsapp/models/new_channel_headlines_model.dart';

class NewReponsitory {
  Future<CategoriesNewsModel> fetchNewsCategoires(String category) async {
    String newsUrl =
        'https://newsapi.org/v2/everything?q=$category&apiKey=63427eeba3a44bc5bb16f17f1c141de7';
    final response = await http.get(Uri.parse(newsUrl));
    print('URL: $newsUrl');
    print('Response Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return CategoriesNewsModel.fromJson(body);
    } else {
      throw Exception('Error');
    }
  }

  Future<NewChannelsHeadlinesModel> fetchNewsChannelHeadlinesApi(String newsChannel) async {
    String newsUrl = 'https://newsapi.org/v2/top-headlines?sources=${newsChannel}&apiKey=63427eeba3a44bc5bb16f17f1c141de7';
    print('URL: $newsUrl');
    final response = await http.get(Uri.parse(newsUrl));
    print('Response Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return NewChannelsHeadlinesModel.fromJson(body);
    } else {
      throw Exception('Error');
    }
  }

  Future<CategoriesNewsModel> fetchCategoriesNewApi(String category) async {
    return await fetchNewsCategoires(category);
  }
}
