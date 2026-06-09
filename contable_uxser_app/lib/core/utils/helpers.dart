import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

String formatCurrency(double amount) {
  final formatter = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 2,
  );
  return formatter.format(amount);
}

String formatDate(DateTime date) {
  return DateFormat('dd/MM/yyyy HH:mm').format(date);
}

String generateLocalId() {
  return const Uuid().v4();
}
