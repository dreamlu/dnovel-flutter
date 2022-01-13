class SearchModel {
  late int code;
  late String message;
  late List<Search>? data;

  SearchModel({this.code = 0, this.message = '', this.data});

  SearchModel.fromJson(Map<String, dynamic> json) {
    code = json['status'];
    message = json['msg'];
    if (json['data'] != null) {
      data = <Search>[];
      json['data'].forEach((v) {
        data?.add(new Search.fromJson(v));
      });
    }
  }
}

class Search {
  String bookName;
  String authorName;
  String bookUrl;
  String source;
  String cover;

  Search(
      {this.bookName = '',
      this.authorName = '',
      this.bookUrl = '',
      this.source = '',
      this.cover = ''});

  factory Search.fromJson(Map<String, dynamic> json) {
    return Search(
      bookName: json['name'],
      authorName: json['author'],
      bookUrl: json['url'],
      source: json['source'],
      cover: json['cover'],
    );
  }
}
