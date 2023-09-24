import 'package:invoice/Components/model/customer.dart';
import 'package:invoice/Components/model/supplier.dart';

class Invoice {
  final InvoiceInfo info;
  final Supplier supplier;
  final Customer customer;
  final List<InvoiceItem> items;

  const Invoice({
    required this.info,
    required this.supplier,
    required this.customer,
    required this.items,
  });
}

class InvoiceInfo {
  final String number;
  final DateTime date;
  final DateTime dueDate;

  const InvoiceInfo({
    required this.number,
    required this.date,
    required this.dueDate,
  });
}

class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final String brand;
  final String size;

  const InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.brand,
    required this.size,
  });
}
