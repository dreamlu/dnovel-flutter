class DetailModel {
  int code;
  String message;
  Detail data;

  DetailModel({this.code, this.message, this.data});

  DetailModel.fromJson(Map<String, dynamic> json) {
    code = json['status'];
    message = json['msg'];
    data = Detail.fromJson(json['data']);
  }
}

class Detail {
  String title;
  String content;
  String prevUrl;
  String nextUrl;

  Detail({
    this.title,
    this.content,
    this.prevUrl,
    this.nextUrl,
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      title: json['title'],
      content: json['text'],
      prevUrl: json['previous_url'],
      nextUrl: json['next_url'],
    );
  }
}
