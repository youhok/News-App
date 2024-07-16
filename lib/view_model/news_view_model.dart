import 'package:newsapp/models/categories_new_model.dart';
import 'package:newsapp/models/new_channel_headlines_model.dart';
import 'package:newsapp/reponsitory/new_reponsitory.dart';

class NewsViewModel {
  final NewReponsitory _rep = NewReponsitory();

  Future<NewChannelsHeadlinesModel> fetchNewChannelHeadlinesApi(String newsChannel) async {
    final response = await _rep.fetchNewsChannelHeadlinesApi(newsChannel);
    return response;
  }

  Future<CategoriesNewsModel> fetchCategoriesNewApi(String category) async {
    final response = await _rep.fetchCategoriesNewApi(category);
    return response;
  }
}
