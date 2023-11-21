import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

Future<void> main() async {
  var movieInfoNowPlaying = await MovieInfo.fetchMovieInfo(
      MovieInfo.nowPlaying);
  var movieInfoPopular = await MovieInfo.fetchMovieInfo(MovieInfo.popular);
  var movieInfoComingSoon = await MovieInfo.fetchMovieInfo(
      MovieInfo.comingSoon);

  runApp(
    MaterialApp(
      home: Scaffold(
        body: MyApp(
          movieInfoPopular: movieInfoPopular,
          movieInfoNowPlaying: movieInfoNowPlaying,
          movieInfoComingSoon: movieInfoComingSoon,
        ),
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class MyApp extends StatelessWidget {
  final MovieInfo movieInfoPopular;
  final MovieInfo movieInfoNowPlaying;
  final MovieInfo movieInfoComingSoon;

  const MyApp({
    super.key,
    required this.movieInfoPopular,
    required this.movieInfoNowPlaying,
    required this.movieInfoComingSoon,
  });

  static const _layoutTitles = [
    'Popular Movies',
    'Now in Cinemas',
    'Coming Soon',
  ];

  @override
  Widget build(BuildContext context) {
    final movieInfos = [
      movieInfoPopular,
      movieInfoNowPlaying,
      movieInfoComingSoon,
    ];

    return Padding(
      padding: EdgeInsets.only(left: 20, top: 35),
      child: ListView(
        children: [
          for (var i = 0; i < _layoutTitles.length; i++)
            ScrollLayout(
              layoutTitle: _layoutTitles[i],
              movieInfo: movieInfos[i],
              width: i == 0 ? null : 180,
            ),
        ],
      ),
    );
  }
}

class ScrollLayout extends StatelessWidget {
  final String layoutTitle;
  final MovieInfo movieInfo;
  final double? width;

  final height = 160.0;

  const ScrollLayout({
    super.key,
    required this.layoutTitle,
    required this.movieInfo,
    this.width,
  });

  @override
  Widget build(BuildContext context) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              layoutTitle,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < movieInfo.results!.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MovieDetailed(
                                        moiveId: movieInfo.results![i].id!,
                                        index: i,
                                        layoutTitle: layoutTitle,
                                      ),
                                ),
                              ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(13),
                            ),
                            child: Hero(
                              tag: '${layoutTitle}movie$i',
                              child: Image.network(
                                MovieInfo.imgUrl + movieInfo.results![i]
                                    .backdropPath!,
                                width: width,
                                height: height,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        if (layoutTitle != 'Popular Movies')
                          Container(
                            width: 100,
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              movieInfo.results![i].title!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          )
        ],
      );
}

class MovieDetailed extends StatefulWidget {
  final int moiveId;
  final int index;
  final String layoutTitle;

  MovieDetailed({
    super.key,
    required this.index,
    required this.layoutTitle,
    required this.moiveId,
  });

  @override
  State<MovieDetailed> createState() => _MovieDetailedState();
}

class _MovieDetailedState extends State<MovieDetailed> {
  @override
  Widget build(BuildContext context) =>
      FutureBuilder(
        future: MovieInfo.fetchMovieInfo(
            MovieInfo.movieDetail + widget.moiveId.toString()),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final movieInfo = snapshot.data as MovieInfo;
            final genres = movieInfo.genres!.map((e) => e.name).join(', ');
            final fullStar = movieInfo.voteAverage! ~/ 2;
            final halfStar = fullStar + (movieInfo.voteAverage! % 2).toInt();

            return Stack(
              children: [
                Hero(
                  tag: '${widget.layoutTitle}movie${widget.index}',
                  child: Image.network(
                    MovieInfo.imgUrl + movieInfo.posterPath!,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Scaffold(
                  appBar: AppBar(
                    title: Text('Back to list'),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            movieInfo.title!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            for (var i = 0; i < 5; i++)
                              if (i < fullStar) ...[
                                Icon(
                                  Icons.star_rounded,
                                  color: Colors.yellow,
                                  size: 20,
                                ),
                              ] else
                                if (i < halfStar) ...[
                                  Icon(
                                    Icons.star_half_rounded,
                                    color: Colors.yellow,
                                    size: 20,
                                  ),
                                ] else
                                  ...[
                                    Icon(
                                      Icons.star_border_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Text(
                              '${movieInfo.runtime! ~/ 60}h ${movieInfo
                                  .runtime! % 60}min  |  $genres',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          'Storyline',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 75.0),
                          child: Text(
                            movieInfo.overview!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              backgroundColor: Color(0xfff8d84a),
                            ),
                            child: Text(
                              'But Ticket',
                              style: TextStyle(
                                  color: Colors.black, fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                ),
              ],
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );
}

// ! after this line, All class is Data Class
class MovieInfo {
  MovieInfo({
    this.page,
    this.results,
    this.totalPages,
    this.totalResults,
    this.dates,
    this.adult,
    this.backdropPath,
    this.belongsToCollection,
    this.budget,
    this.genres,
    this.homepage,
    this.id,
    this.imdbId,
    this.originalLanguage,
    this.originalTitle,
    this.overview,
    this.popularity,
    this.posterPath,
    this.productionCompanies,
    this.productionCountries,
    this.releaseDate,
    this.revenue,
    this.runtime,
    this.spokenLanguages,
    this.status,
    this.tagline,
    this.title,
    this.video,
    this.voteAverage,
    this.voteCount,
  });

  final int? page;
  final List<Result>? results;
  final int? totalPages;
  final int? totalResults;
  final Dates? dates;
  final bool? adult;
  final String? backdropPath;
  final dynamic belongsToCollection;
  final int? budget;
  final List<Genre>? genres;
  final String? homepage;
  final int? id;
  final String? imdbId;
  final OriginalLanguage? originalLanguage;
  final String? originalTitle;
  final String? overview;
  final double? popularity;
  final String? posterPath;
  final List<ProductionCompany>? productionCompanies;
  final List<ProductionCountry>? productionCountries;
  final DateTime? releaseDate;
  final int? revenue;
  final int? runtime;
  final List<SpokenLanguage>? spokenLanguages;
  final String? status;
  final String? tagline;
  final String? title;
  final bool? video;
  final double? voteAverage;
  final int? voteCount;

  static const popular = 'https://movies-api.nomadcoders.workers.dev/popular';
  static const nowPlaying = 'https://movies-api.nomadcoders.workers.dev/now-playing';
  static const comingSoon = 'https://movies-api.nomadcoders.workers.dev/coming-soon';
  static const movieDetail = 'https://movies-api.nomadcoders.workers.dev/movie?id=';
  static const imgUrl = 'https://image.tmdb.org/t/p/w500';

  static Future<String> fetchJsonData(String url) async {
    final http = HttpClient();
    final request = await http.getUrl(Uri.parse(url));
    final response = await request.close();
    return await response.transform(utf8.decoder).join();
  }

  static Future<MovieInfo> fetchMovieInfo(String url) async {
    final response = await fetchJsonData(url);
    return MovieInfo.fromRawJson(response);
  }

  factory MovieInfo.fromRawJson(String str) =>
      MovieInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MovieInfo.fromJson(Map<String, dynamic> json) =>
      MovieInfo(
        page: json["page"],
        results: json["results"] == null ? [] : List<Result>.from(
            json["results"]!.map((x) => Result.fromJson(x))),
        totalPages: json["total_pages"],
        totalResults: json["total_results"],
        dates: json["dates"] == null ? null : Dates.fromJson(json["dates"]),
        adult: json["adult"],
        backdropPath: json["backdrop_path"],
        belongsToCollection: json["belongs_to_collection"],
        budget: json["budget"],
        genres: json["genres"] == null ? [] : List<Genre>.from(
            json["genres"]!.map((x) => Genre.fromJson(x))),
        homepage: json["homepage"],
        id: json["id"],
        imdbId: json["imdb_id"],
        originalLanguage: originalLanguageValues.map[json["original_language"]],
        originalTitle: json["original_title"],
        overview: json["overview"],
        popularity: json["popularity"]?.toDouble(),
        posterPath: json["poster_path"],
        productionCompanies: json["production_companies"] == null
            ? []
            : List<ProductionCompany>.from(
            json["production_companies"]!.map((x) =>
                ProductionCompany.fromJson(x))),
        productionCountries: json["production_countries"] == null
            ? []
            : List<ProductionCountry>.from(
            json["production_countries"]!.map((x) =>
                ProductionCountry.fromJson(x))),
        releaseDate: json["release_date"] == null ? null : DateTime.parse(
            json["release_date"]),
        revenue: json["revenue"],
        runtime: json["runtime"],
        spokenLanguages: json["spoken_languages"] == null
            ? []
            : List<SpokenLanguage>.from(
            json["spoken_languages"]!.map((x) => SpokenLanguage.fromJson(x))),
        status: json["status"],
        tagline: json["tagline"],
        title: json["title"],
        video: json["video"],
        voteAverage: json["vote_average"]?.toDouble(),
        voteCount: json["vote_count"],
      );

  Map<String, dynamic> toJson() =>
      {
        "page": page,
        "results": results == null ? [] : List<dynamic>.from(
            results!.map((x) => x.toJson())),
        "total_pages": totalPages,
        "total_results": totalResults,
        "dates": dates?.toJson(),
        "adult": adult,
        "backdrop_path": backdropPath,
        "belongs_to_collection": belongsToCollection,
        "budget": budget,
        "genres": genres == null ? [] : List<dynamic>.from(
            genres!.map((x) => x.toJson())),
        "homepage": homepage,
        "id": id,
        "imdb_id": imdbId,
        "original_language": originalLanguageValues.reverse[originalLanguage],
        "original_title": originalTitle,
        "overview": overview,
        "popularity": popularity,
        "poster_path": posterPath,
        "production_companies":
        productionCompanies == null ? [] : List<dynamic>.from(
            productionCompanies!.map((x) => x.toJson())),
        "production_countries":
        productionCountries == null ? [] : List<dynamic>.from(
            productionCountries!.map((x) => x.toJson())),
        "release_date":
        "${releaseDate!.year.toString().padLeft(4, '0')}-${releaseDate!.month
            .toString().padLeft(2, '0')}-${releaseDate!.day.toString().padLeft(
            2, '0')}",
        "revenue": revenue,
        "runtime": runtime,
        "spoken_languages": spokenLanguages == null ? [] : List<dynamic>.from(
            spokenLanguages!.map((x) => x.toJson())),
        "status": status,
        "tagline": tagline,
        "title": title,
        "video": video,
        "vote_average": voteAverage,
        "vote_count": voteCount,
      };
}

class Dates {
  Dates({
    this.maximum,
    this.minimum,
  });

  final DateTime? maximum;
  final DateTime? minimum;

  factory Dates.fromRawJson(String str) => Dates.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Dates.fromJson(Map<String, dynamic> json) =>
      Dates(
        maximum: json["maximum"] == null ? null : DateTime.parse(
            json["maximum"]),
        minimum: json["minimum"] == null ? null : DateTime.parse(
            json["minimum"]),
      );

  Map<String, dynamic> toJson() =>
      {
        "maximum":
        "${maximum!.year.toString().padLeft(4, '0')}-${maximum!.month.toString()
            .padLeft(2, '0')}-${maximum!.day.toString().padLeft(2, '0')}",
        "minimum":
        "${minimum!.year.toString().padLeft(4, '0')}-${minimum!.month.toString()
            .padLeft(2, '0')}-${minimum!.day.toString().padLeft(2, '0')}",
      };
}

class Genre {
  Genre({
    this.id,
    this.name,
  });

  final int? id;
  final String? name;

  factory Genre.fromRawJson(String str) => Genre.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Genre.fromJson(Map<String, dynamic> json) =>
      Genre(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() =>
      {
        "id": id,
        "name": name,
      };
}

enum OriginalLanguage { en, es, ko, ja, fi, de, it, la, uk, fr, id, vi, th, nl, ru, no, ur, pt }

final originalLanguageValues = EnumValues({
  "en": OriginalLanguage.en,
  "es": OriginalLanguage.es,
  "fi": OriginalLanguage.fi,
  "ja": OriginalLanguage.ja,
  "ko": OriginalLanguage.ko,
  "de": OriginalLanguage.de,
  "it": OriginalLanguage.it,
  "la": OriginalLanguage.la,
  "uk": OriginalLanguage.uk,
  "fr": OriginalLanguage.fr,
  "id": OriginalLanguage.id,
  "vi": OriginalLanguage.vi,
  "th": OriginalLanguage.th,
  "nl": OriginalLanguage.nl,
  "ru": OriginalLanguage.ru,
  "no": OriginalLanguage.no,
  "ur": OriginalLanguage.ur,
  "pt": OriginalLanguage.pt,
});

class ProductionCompany {
  ProductionCompany({
    this.id,
    this.logoPath,
    this.name,
    this.originCountry,
  });

  final int? id;
  final String? logoPath;
  final String? name;
  final String? originCountry;

  factory ProductionCompany.fromRawJson(String str) =>
      ProductionCompany.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductionCompany.fromJson(Map<String, dynamic> json) =>
      ProductionCompany(
        id: json["id"],
        logoPath: json["logo_path"],
        name: json["name"],
        originCountry: json["origin_country"],
      );

  Map<String, dynamic> toJson() =>
      {
        "id": id,
        "logo_path": logoPath,
        "name": name,
        "origin_country": originCountry,
      };
}

class ProductionCountry {
  ProductionCountry({
    this.iso31661,
    this.name,
  });

  final String? iso31661;
  final String? name;

  factory ProductionCountry.fromRawJson(String str) =>
      ProductionCountry.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductionCountry.fromJson(Map<String, dynamic> json) =>
      ProductionCountry(
        iso31661: json["iso_3166_1"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() =>
      {
        "iso_3166_1": iso31661,
        "name": name,
      };
}

class Result {
  Result({
    this.adult,
    this.backdropPath,
    this.genreIds,
    this.id,
    this.originalLanguage,
    this.originalTitle,
    this.overview,
    this.popularity,
    this.posterPath,
    this.releaseDate,
    this.title,
    this.video,
    this.voteAverage,
    this.voteCount,
  });

  final bool? adult;
  final String? backdropPath;
  final List<int>? genreIds;
  final int? id;
  final OriginalLanguage? originalLanguage;
  final String? originalTitle;
  final String? overview;
  final double? popularity;
  final String? posterPath;
  final DateTime? releaseDate;
  final String? title;
  final bool? video;
  final double? voteAverage;
  final int? voteCount;

  factory Result.fromRawJson(String str) => Result.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Result.fromJson(Map<String, dynamic> json) =>
      Result(
        adult: json["adult"],
        backdropPath: json["backdrop_path"],
        genreIds: json["genre_ids"] == null ? [] : List<int>.from(
            json["genre_ids"]!.map((x) => x)),
        id: json["id"],
        originalLanguage: originalLanguageValues
            .map[json["original_language"]]!,
        originalTitle: json["original_title"],
        overview: json["overview"],
        popularity: json["popularity"]?.toDouble(),
        posterPath: json["poster_path"],
        releaseDate: json["release_date"] == null ? null : DateTime.parse(
            json["release_date"]),
        title: json["title"],
        video: json["video"],
        voteAverage: json["vote_average"]?.toDouble(),
        voteCount: json["vote_count"],
      );

  Map<String, dynamic> toJson() =>
      {
        "adult": adult,
        "backdrop_path": backdropPath,
        "genre_ids": genreIds == null ? [] : List<dynamic>.from(
            genreIds!.map((x) => x)),
        "id": id,
        "original_language": originalLanguageValues.reverse[originalLanguage],
        "original_title": originalTitle,
        "overview": overview,
        "popularity": popularity,
        "poster_path": posterPath,
        "release_date":
        "${releaseDate!.year.toString().padLeft(4, '0')}-${releaseDate!.month
            .toString().padLeft(2, '0')}-${releaseDate!.day.toString().padLeft(
            2, '0')}",
        "title": title,
        "video": video,
        "vote_average": voteAverage,
        "vote_count": voteCount,
      };
}

class SpokenLanguage {
  SpokenLanguage({
    this.englishName,
    this.iso6391,
    this.name,
  });

  final String? englishName;
  final OriginalLanguage? iso6391;
  final String? name;

  factory SpokenLanguage.fromRawJson(String str) =>
      SpokenLanguage.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SpokenLanguage.fromJson(Map<String, dynamic> json) =>
      SpokenLanguage(
        englishName: json["english_name"],
        iso6391: originalLanguageValues.map[json["iso_639_1"]]!,
        name: json["name"],
      );

  Map<String, dynamic> toJson() =>
      {
        "english_name": englishName,
        "iso_639_1": originalLanguageValues.reverse[iso6391],
        "name": name,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
