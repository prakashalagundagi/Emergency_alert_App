import 'package:sms_advanced/sms_advanced.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class SMSService {
  final SmsSender _sender = SmsSender();

  Future<bool> sendSMS(String phoneNumber, String message) async {
    try {
      var smsStatus = await ph.Permission.sms.status;
      if (!smsStatus.isGranted) {
        smsStatus = await ph.Permission.sms.request();
        if (!smsStatus.isGranted) {
          print('SMS permission denied');
          return false;
        }
      }

      if (phoneNumber.isEmpty || message.isEmpty) {
        print('Phone number or message is empty');
        return false;
      }

      final smsMessage = SmsMessage(
        phoneNumber,
        message,
      );

      await _sender.sendSms(smsMessage);
      print('SMS sent successfully to $phoneNumber');
      return true;
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }

  Future<bool> sendEmergencyAlert(String phoneNumber, String locationUrl) async {
    final message = '🚨 EMERGENCY ALERT! I need help. My current location is: $locationUrl';
    return await sendSMS(phoneNumber, message);
  }

  Future<bool> sendCustomMessage(String phoneNumber, String customMessage) async {
    return await sendSMS(phoneNumber, customMessage);
  }

  Future<bool> sendToMultipleContacts(List<String> phoneNumbers, String message) async {
    if (phoneNumbers.isEmpty) {
      print('No phone numbers provided');
      return false;
    }

    bool allSent = true;
    for (final phoneNumber in phoneNumbers) {
      final result = await sendSMS(phoneNumber, message);
      if (!result) {
        allSent = false;
      }
    }

    return allSent;
  }

  Future<bool> checkSMSPermission() async {
    try {
      final status = await ph.Permission.sms.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking SMS permission: $e');
      return false;
    }
  }

  Future<bool> requestSMSPermission() async {
    try {
      final status = await ph.Permission.sms.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting SMS permission: $e');
      return false;
    }
  }

  String formatPhoneNumber(String phoneNumber) {
    String formatted = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    
    if (!formatted.startsWith('+') && formatted.length == 10) {
      formatted = '+1' + formatted;
    }
    
    return formatted;
  }

  bool isValidPhoneNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    return cleaned.length >= 10 && cleaned.length <= 15;
  }
}
