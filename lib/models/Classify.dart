class ClassifyModel {
  late int code;
  late String message;
  late List<Classify>? data;

  ClassifyModel({this.code = 0, this.message = '', this.data});

  ClassifyModel.fromJson(Map<String, dynamic> json) {
    code = json['status'];
    message = json['msg'];
    if (json['data'] != null) {
      data = <Classify>[];
      json['data'].forEach((v) {
        data?.add(new Classify.fromJson(v));
      });
    }
  }
}

class Classify {
  // int id;
  String name;

  Classify({this.name = ''});

  factory Classify.fromJson(Map<String, dynamic> json) {
    return Classify(
      // id: json['id'],
      name: json['name'],
    );
  }
}
