import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/i_post_repository.dart';
import '../datasources/post_remote_data_source.dart';
import 'package:image_picker/image_picker.dart';

class PostRepositoryImpl implements IPostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Post>>> getFeed() async {
    try {
      final posts = await remoteDataSource.getFeed();
      return Right(posts);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }

  @override
  Future<Either<Failure, Post>> createPost(String content, {XFile? imageFile, int? locationId}) async {
    try {
      final post = await remoteDataSource.createPost(content, imageFile: imageFile, locationId: locationId);
      return Right(post);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }

  @override
  Future<Either<Failure, void>> likePost(String postId) async {
    try {
      await remoteDataSource.likePost(postId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }

  @override
  Future<Either<Failure, void>> unlikePost(String postId) async {
    try {
      await remoteDataSource.unlikePost(postId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }

  @override
  Future<Either<Failure, List<Comment>>> getPostComments(String postId) async {
    try {
      final comments = await remoteDataSource.getPostComments(postId);
      return Right(comments);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }

  @override
  Future<Either<Failure, Comment>> addComment(String postId, String content, {String? parentCommentId}) async {
    try {
      final comment = await remoteDataSource.addComment(postId, content, parentCommentId: parentCommentId);
      return Right(comment);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    try {
      await remoteDataSource.deletePost(postId);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePost(String postId, String content) async {
    try {
      await remoteDataSource.updatePost(postId, content);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }
}
