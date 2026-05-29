class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.label,
    required this.last4,
  });

  final String id;
  final String label;
  final String last4;
}
