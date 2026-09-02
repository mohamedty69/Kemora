import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/post.dart';
import '../repositories/i_post_repository.dart';
import 'package:image_picker/image_picker.dart';

class GetFeedUseCase {
  final IPostRepository repository;

  GetFeedUseCase(this.repository);

  Future<Either<Failure, List<Post>>> call() async {
    return await repository.getFeed();
  }
}

class CreatePostUseCase {
  final IPostRepository repository;

  CreatePostUseCase(this.repository);

  Future<Either<Failure, Post>> call(String content, {XFile? imageFile, int? locationId}) async {
    return await repository.createPost(content, imageFile: imageFile, locationId: locationId);
  }
}

class ToggleLikeUseCase {
  final IPostRepository repository;

  ToggleLikeUseCase(this.repository);

  Future<Either<Failure, void>> call(String postId) async {
    return await repository.likePost(postId);
  }
}

class AddCommentUseCase {
  final IPostRepository repository;

  AddCommentUseCase(this.repository);

  Future<Either<Failure, Comment>> call(String postId, String content, {String? parentCommentId}) async {
    return await repository.addComment(postId, content, parentCommentId: parentCommentId);
  }
}

class GetPostCommentsUseCase {
  final IPostRepository repository;

  GetPostCommentsUseCase(this.repository);

  Future<Either<Failure, List<Comment>>> call(String postId) async {
    return await repository.getPostComments(postId);
  }
}

class DeletePostUseCase {
  final IPostRepository repository;

  DeletePostUseCase(this.repository);

  Future<Either<Failure, void>> call(String postId) async {
    return await repository.deletePost(postId);
  }
}

class UpdatePostUseCase {
  final IPostRepository repository;

  UpdatePostUseCase(this.repository);

  Future<Either<Failure, void>> call(String postId, String content) async {
    return await repository.updatePost(postId, content);
  }
}
