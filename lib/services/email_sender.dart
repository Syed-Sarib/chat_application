import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailSender {
  static Future<bool> sendEmail(String toEmail, String subject, String body) async {
    final String username = 'muhammadmaaz0017@gmail.com';
    final String appPassword = 'ygwdcwlhszvptevu'; // 16-digit app password

    final smtpServer = gmail(username, appPassword);

    final message = Message()
      ..from = Address(username, 'SM-Intouch')
      ..recipients.add(toEmail)
      ..subject = subject
      ..text = body;

    try {
      print('[EmailSender] Sending email to $toEmail...');
      final sendReport = await send(message, smtpServer);
      print('[EmailSender] Email sent successfully: $sendReport');
      return true;
    } on MailerException catch (e) {
      print('[EmailSender] Email not sent: $e');
      for (var p in e.problems) {
        print('[EmailSender] Problem: ${p.code}: ${p.msg}');
      }
      return false;
    }
  }
}
