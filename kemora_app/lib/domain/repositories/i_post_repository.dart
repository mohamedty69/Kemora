import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/post.dart';
import 'package:image_picker/image_picker.dart';

abstract class IPostRepository {
  Future<Either<Failure, List<Post>>> getFeed();
  Future<Either<Failure, Post>> createPost(String content, {XFile? imageFile, int? locationId});
  Future<Either<Failure, void>> likePost(String postId);
  Future<Either<Failure, void>> unlikePost(String postId);
  Future<Either<Failure, List<Comment>>> getPostComments(String postId);
  Future<Either<Failure, Comment>> addComment(String postId, String content, {String? parentCommentId});
  Future<Either<Failure, void>> deletePost(String postId);
  Future<Either<Failure, void>> updatePost(String postId, String content);
}
