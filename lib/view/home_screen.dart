import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newsapp/models/categories_new_model.dart';
import 'package:newsapp/models/new_channel_headlines_model.dart';
import 'package:newsapp/view/categories_screen.dart';
import 'package:newsapp/view/news_detail_screen.dart';
import 'package:newsapp/view_model/news_view_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum FilterList { bbcNews, aryNews, alJazeera }

class _HomeScreenState extends State<HomeScreen> {
  NewsViewModel newsViewModel = NewsViewModel();
  TextEditingController _searchController = TextEditingController();
  FilterList? selectedMenu;
  String name = 'bbc-news';
  String selectedCategory = 'General';
  String searchQuery = '';
  final format = DateFormat('MMMM dd, yyyy');

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CategoriesScreen()));
            },
            icon: Image.asset(
              'images/category_icon.png',
              height: 30,
              width: 30,
            )),
        title: Text(
          'News',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        actions: [
          PopupMenuButton<FilterList>(
              initialValue: selectedMenu,
              icon: Icon(
                Icons.more_vert,
                color: Colors.black,
              ),
              onSelected: (FilterList item) {
                setState(() {
                  selectedMenu = item;
                  if (FilterList.bbcNews == item) {
                    name = 'bbc-news';
                  } else if (FilterList.aryNews == item) {
                    name = 'ary-news';
                  } else if (FilterList.alJazeera == item) {
                    name = 'al-jazeera-english';
                  }

                  // Update the category based on selected menu
                  selectedCategory = name; // Update selected category here
                });
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<FilterList>>[
                    PopupMenuItem<FilterList>(
                      value: FilterList.bbcNews,
                      child: Text('BBC News'),
                    ),
                    PopupMenuItem<FilterList>(
                      value: FilterList.aryNews,
                      child: Text('Ary News'),
                    ),
                    PopupMenuItem<FilterList>(
                      value: FilterList.alJazeera,
                      child: Text('Al-Jazeera News'),
                    ),
                  ])
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search News',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                SizedBox(
                  height: height * .55,
                  width: width,
                  child: FutureBuilder<NewChannelsHeadlinesModel>(
                    future: newsViewModel.fetchNewChannelHeadlinesApi(name),
                    builder: (BuildContext context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: SpinKitCircle(
                            size: 50,
                            color: Colors.blue,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text("Error: ${snapshot.error}"),
                        );
                      } else if (!snapshot.hasData ||
                          snapshot.data!.articles == null) {
                        return Center(
                          child: Text("No data available"),
                        );
                      } else {
                        List articles = snapshot.data!.articles!.where((article) {
                          return article.title!
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase());
                        }).toList();

                        return ListView.builder(
                          itemCount: articles.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            DateTime dateTime = DateTime.parse(
                                articles[index].publishedAt.toString());
                            var article = articles[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NewsDetailScreen(
                                            newImage: article.urlToImage
                                                .toString(),
                                            newTitle: article.title.toString(),
                                            newData: article.publishedAt
                                                .toString(),
                                            author: article.author.toString(),
                                            description: article.description
                                                .toString(),
                                            source: article.source!.name
                                                .toString())));
                              },
                              child: SizedBox(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      height: height * 0.6,
                                      width: width * .9,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: height * .02,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: CachedNetworkImage(
                                          imageUrl: article.urlToImage ?? '',
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              spinKit2,
                                          errorWidget: (context, url, error) =>
                                              Icon(Icons.error_outline,
                                                  color: Colors.red),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 20,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            12), // Match the border radius of the card
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 10, sigmaY: 10),
                                          child: Card(
                                            elevation: 5,
                                            color: Colors.white.withOpacity(
                                                0.3), // Adjust opacity to see the blur effect
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Container(
                                              alignment: Alignment.bottomCenter,
                                              padding: EdgeInsets.all(15),
                                              height: height * .22,
                                              width: width * .8, // Constrain width
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width: width * 0.7,
                                                    child: Text(
                                                      article.title.toString(),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Container(
                                                    width: width * 0.7,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          article.source!.name
                                                              .toString(),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                        Text(
                                                          format.format(dateTime),
                                                          maxLines: 1,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FutureBuilder<CategoriesNewsModel>(
                    future: newsViewModel.fetchCategoriesNewApi(
                        selectedCategory), // Use selectedCategory here
                    builder: (BuildContext context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: SpinKitCircle(
                            size: 50,
                            color: Colors.blue,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text("Error: ${snapshot.error}"),
                        );
                      } else if (!snapshot.hasData ||
                          snapshot.data!.articles == null ||
                          snapshot.data!.articles!.isEmpty) {
                        return Center(
                          child: Text("No data available"),
                        );
                      } else {
                        List articles = snapshot.data!.articles!.where((article) {
                          return article.title!
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase());
                        }).toList();

                        return ListView.builder(
                          itemCount: articles.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(), // Prevent scrolling inside ListView
                          itemBuilder: (context, index) {
                            final article = articles[index];

                            if (article.urlToImage == null ||
                                article.title == null ||
                                article.description == null) {
                              // Skip the article if any of these fields are null
                              return SizedBox.shrink();
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => NewsDetailScreen(
                                        newImage: article.urlToImage!,
                                        newTitle: article.title!,
                                        newData: article.publishedAt!,
                                        author: article.author ?? 'Unknown',
                                        description: article.description!,
                                        source: article.source!.name!,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: height * .12,
                                  child: Row(
                                    children: [
                                      Container(
                                        height: height * .12,
                                        width: width * .28,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                              article.urlToImage!,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * .04,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              article.title!,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Spacer(),
                                            Text(
                                              article.description!,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const spinKit2 = SpinKitCircle(
  color: Colors.blue,
  size: 50.0,
);
