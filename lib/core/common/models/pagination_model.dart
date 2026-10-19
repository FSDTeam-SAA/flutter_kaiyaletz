class PaginationModel {
  final int? total;
  final int? page;
  final int? pages;
  final int? limit;

  PaginationModel({this.total, this.page, this.pages, this.limit});

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      total: json['total'],
      limit: json['limit'],
      page: json['page'],
      pages: json['pages'] ?? json['totalPages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'total': total, 'page': page, 'pages': pages, 'limit': limit};
  }
}
