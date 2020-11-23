class NovelModel {
  int code;
  String message;
  List<Novel> data;

  NovelModel({this.code, this.message, this.data});

  NovelModel.fromJson(Map<String, dynamic> json) {
    code = json['status'];
    message = json['msg'];
    if (json['data'] != null) {
      data = new List<Novel>();
      json['data'].forEach((v) {
        data.add(new Novel.fromJson(v));
      });
    }
  }
}

class Novel {
  String authorName;
  String bookName;
  String bookUrl;
  String source;

  Novel({this.authorName, this.bookName, this.bookUrl, this.source});

  factory Novel.fromJson(Map<String, dynamic> json) {
    return Novel(
      authorName: json['author'],
      bookName: json['name'],
      bookUrl: json['url'],
      source: json['source'],
    );
  }
}
