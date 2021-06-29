import 'package:equatable/equatable.dart';

class HymnData extends Equatable {
  final int id;
  final String title;
  final List<String> contents;

  const HymnData(this.id, this.title, this.contents);

  @override
  List<Object> get props => [id, title, contents];
}
