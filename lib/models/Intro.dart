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
  String lastUpdateAt; // 最新章节名
  String bookDesc;
  String recentChapterUrl;
  String source;
  String cover; // 封面

  Intro(
      {this.bookName,
      this.authorName,
      this.classifyName,
      this.lastUpdateAt,
      this.bookDesc,
      this.recentChapterUrl,
      this.source,
      this.cover});

  factory Intro.fromJson(Map<String, dynamic> json) {
    return Intro(
      bookName: json['name'],
      authorName: json['author'],
      classifyName: json['category'],
      lastUpdateAt: json['new_chapter'],
      bookDesc: json['description'],
      recentChapterUrl: json['url'],
      source: json['source'],
      cover: json["cover"],
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
    coder = $cover,
    ''';
  }
}
