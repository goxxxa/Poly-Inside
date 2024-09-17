import 'package:shared/shared.dart';

abstract class ClientRepository {
  ClientRepository();
  Future<void> addUser(User user);
  Future<User> getUserByUserId(int userId);
  Stream<GetListProfessorResponse> getAllProfessors();
  Stream<Review> getAllReviewsByProfessor(String professorId);
  Stream<Review> getAllReviewByUser(int userId);
  Future<void> addReview(Review review);
  Future<void> updateReview(Review review);
  Future<void> updateUser(User user);
}