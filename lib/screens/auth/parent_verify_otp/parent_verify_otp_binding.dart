part of 'parent_verify_otp_view.dart';

class ParentVerifyOtpViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => ParentVerifyOtpViewController());
   }
}