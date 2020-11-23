class IntroModel {
  int code;
  String message;
  Intro data;

  IntroModel({this.code, this.message, this.data});

  IntroModel.fromJson(Map<String, dynamic> json) {
    code = json['status'];
    message = json['msg'];
    data = Intro.fromJson(json['data']);
  }
}

class Intro {
  String bookName;
  String authorName;
  String classifyName;
  String lastUpdateAt;
  String bookDesc;
  String recentChapterUrl;
  String source;

  Intro(
      {this.bookName,
      this.authorName,
      this.classifyName,
      this.lastUpdateAt,
      this.bookDesc,
      this.recentChapterUrl,
      this.source});

  factory Intro.fromJson(Map<String, dynamic> json) {
    return Intro(
      bookName: json['name'],
      authorName: json['author'],
      classifyName: json['category'],
      lastUpdateAt: json['new_chapter'],
      bookDesc: json['description'],
      recentChapterUrl: json['url'],
      source: json['source'],
    );
  }

  toJson() {
    return '''
    bookName = $bookName,
    authorName = $authorName,
    classifyName = $classifyName,
    lastUpdateAt = $lastUpdateAt,
    bookDesc = $bookDesc,
    recentChapterUrl = $recentChapterUrl,
    source = $source,
    ''';
  }
}
