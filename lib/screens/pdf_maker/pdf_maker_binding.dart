import 'package:get/get.dart';
import 'pdf_maker_controller.dart';

class PdfMakerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PdfMakerController>(() => PdfMakerController());
  }
}
