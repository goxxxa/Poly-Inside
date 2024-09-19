import 'package:drift/drift.dart';
import 'package:shared/shared.dart';

part 'database.g.dart';

@UseRowClass(Professor)
class Professors extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BlobColumn get avatar => blob()();
  IntColumn get reviewsCount => integer()();
  RealColumn get rating => real()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@UseRowClass(Review)
class RejectedReviews extends Table {
  TextColumn get id => text()();
  IntColumn get userId => integer()();
  TextColumn get professorId => text()();
  TextColumn get comment => text()();
  RealColumn get objectivity => real()();
  RealColumn get loyalty => real()();
  RealColumn get professionalism => real()();
  RealColumn get harshness => real()();
  TextColumn get date => text()();
  IntColumn get rating => integer()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@UseRowClass(User)
class Users extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  BlobColumn get avatar => blob()();
  IntColumn get rating => integer().withDefault(const Constant<int>(0))();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@UseRowClass(Review)
class Reviews extends Table {
  TextColumn get id => text()();
  IntColumn get userId => integer()();
  TextColumn get professorId => text()();
  TextColumn get comment => text()();
  RealColumn get objectivity => real()();
  RealColumn get loyalty => real()();
  RealColumn get professionalism => real()();
  RealColumn get harshness => real()();
  TextColumn get date => text()();
  IntColumn get rating => integer()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@DriftDatabase(tables: [Professors, Users, Reviews, RejectedReviews])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
