import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(const MovieInfiniteList());
}

class MovieInfiniteList extends StatelessWidget {
  const MovieInfiniteList({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie List Infinite Scroll',
      theme: ThemeData.dark(),
      home: const MovieInfiniteListPage(title: 'Movie List Infinite Scroll'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MovieInfiniteListPage extends StatefulWidget {
  const MovieInfiniteListPage({super.key, required this.title});
  final String title;

  @override
  State<MovieInfiniteListPage> createState() => _MovieInfiniteListPageState();
}

class _MovieInfiniteListPageState extends State<MovieInfiniteListPage> {
  final ScrollController _controllerMovie = ScrollController();
  final List<String> _titleMovie = <String>[];
  final List<String> _imageMovie = <String>[];
  final List<String> _yearMovie = <String>[];
  final List<String> _runtimeMovie = <String>[];
  int _page = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getMovies();
    _controllerMovie.addListener(_infiniteScroll);
  }

  Future<void> _getMovies() async {
    final Response response = await get(Uri.parse('https://yts.mx/api/v2/list_movies.json?limit=10&page=$_page'));
    final Map<String, dynamic> map = jsonDecode(response.body) as Map<String, dynamic>;
    final Map<String, dynamic> data = map['data'] as Map<String, dynamic>;
    final List<Map<dynamic, dynamic>> movies = List<Map<dynamic, dynamic>>.from(data['movies'] as List<dynamic>);
    for (final Map<dynamic, dynamic> item in movies) {
      _titleMovie.add(item['title'] as String);
      _imageMovie.add(item['medium_cover_image'] as String);
      _yearMovie.add(item['year'].toString());
      _runtimeMovie.add(item['runtime'].toString());
    }
    _page++;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 35, vertical: 35),
              child: ListView(
                scrollDirection: Axis.horizontal,
              ),
            ),
            Builder(
              builder: (BuildContext context) {
                if (_isLoading && _page == 1) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                } else {
                  return Expanded(
                    child: CustomScrollView(
                      controller: _controllerMovie,
                      scrollDirection: Axis.horizontal,
                      slivers: <Widget>[
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              final String titleMovie = _titleMovie[index];
                              final String imageMovie = _imageMovie[index];
                              final String yearMovie = _yearMovie[index];
                              final String runtimeMovie = _runtimeMovie[index];
                              return Column(
                                children: <Widget>[
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.5,
                                    width: MediaQuery.of(context).size.width * 0.8,
                                    margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                        image: NetworkImage(imageMovie),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      titleMovie,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Release Year: $yearMovie\nDuration: $runtimeMovie minutes',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              );
                            },
                            childCount: _titleMovie.length,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _infiniteScroll() {
    if (_controllerMovie.position.pixels == _controllerMovie.position.maxScrollExtent) {
      _getMovies();
    }
  }
}
