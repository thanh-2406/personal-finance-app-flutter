import 'package:intl/intl.dart';

class CurrencyFormatter {
  // Creates a formatter: e.g., 500000 -> 500.000 đ
  static final _formatter = NumberFormat.decimalPattern('vi_VN');

  static String format(double amount) {
    return _formatter.format(amount) + ' đ';
  }
}