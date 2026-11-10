import 'package:get/get.dart';
import '../../features/auth/domain/contracts/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';

/// App-wide Dependency Injection Binding using GetX
/// Registers repository contracts and global state singletons
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Core Data Repositories (Injected by Contract Interface)
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(), fenix: true);

    // 2. Global State Controllers
    Get.put<AuthController>(
      AuthController(Get.find<AuthRepository>()),
      permanent: true,
    );
  }
}

