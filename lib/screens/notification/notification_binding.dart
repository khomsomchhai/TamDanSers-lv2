part of 'notification_view.dart';

class NotificationViewBinding extends Bindings {

   @override
   void dependencies() {
       Get.lazyPut(() => NotificationController());
   }
}