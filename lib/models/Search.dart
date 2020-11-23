class SearchModel {
  int code;
  String message;
  List<Search> data;

  SearchModel({this.code, this.message, this.data});

  SearchModel.fromJson(Map<String, dynamic> json) {
    code = json['status'];
    message = json['msg'];
    if (json['data'] != null) {
      data = new List<Search>();
      json['data'].forEach((v) {
        data.add(new Search.fromJson(v));
      });
    }
  }
}

class Search {
  String bookName;
  String authorName;
  String bookUrl;
  String source;

  Search({this.bookName, this.authorName, this.bookUrl, this.source});

  factory Search.fromJson(Map<String, dynamic> json) {
    return Search(
      bookName: json['name'],
      authorName: json['author'],
      bookUrl: json['url'],
      source: json['source'],
    );
  }
}
