import 'dart:convert';

class DetailModel {
  late int code;
  late String message;
  late Detail data;

  DetailModel({this.code = 0, this.message = '', required this.data});

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
  String currentUrl;

  Detail({
    this.title = '',
    this.content = '',
    this.prevUrl = '',
    this.nextUrl = '',
    this.currentUrl = '',
  });

  factory Detail.fromJson(Map<String, dynamic> json) {
    return Detail(
      title: json['title'],
      content: json['text'],
      prevUrl: json['previous_url'],
      nextUrl: json['next_url'],
      currentUrl: json['current_url'],
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'title': title,
        'text': content,
        'previous_url': prevUrl,
        'next_url': nextUrl,
        'current_url': currentUrl,
      };

  static List<Detail> toList(dynamic stringJson) {
    if (stringJson == null) {
      return [];
    }
    var map = jsonDecode(stringJson);
    List<Detail> list = [];
    map.forEach((json) {
      list.add(Detail(
        title: json['title'],
        content: json['text'],
        prevUrl: json['previous_url'],
        nextUrl: json['next_url'],
        currentUrl: json['current_url'],
      ));
    });
    return list;
  }
}
