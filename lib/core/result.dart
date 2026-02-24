sealed class Result<T> {
  const Result();

  R when<R>({required R Function(T data) success, required R Function(AppFailure failure) failure});
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  R when<R>({required R Function(T data) success, required R Function(AppFailure failure) failure}) {
    return success(data);
  }
}

class Failure<T> extends Result<T> {
  final AppFailure error;
  const Failure(this.error);

  @override
  R when<R>({required R Function(T data) success, required R Function(AppFailure failure) failure}) {
    return failure(error);
  }
}

class AppFailure {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  const AppFailure({required this.message, this.cause, this.stackTrace});
}
