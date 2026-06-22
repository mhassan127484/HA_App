import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

abstract class UseCase<R, Params> {
  Future<Either<Failure, R>> call(Params params);
}

class NoParams {
  const NoParams();
}

abstract class StreamUseCase<R, Params> {
  Stream<Either<Failure, R>> call(Params params);
}
