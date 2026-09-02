import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../repositories/i_auth_repository.dart';
import 'package:image_picker/image_picker.dart';

class UploadProfilePictureUseCase {
  final IAuthRepository repository;

  UploadProfilePictureUseCase(this.repository);

  Future<Either<Failure, String>> call(XFile imageFile) async {
    return await repository.uploadProfilePicture(imageFile);
  }
}
