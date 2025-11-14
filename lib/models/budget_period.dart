enum BudgetPeriod {
  daily,
  weekly,
  monthly,
  custom,
}

// Helper function to convert a string (from Firestore) to the enum
BudgetPeriod periodFromString(String? periodStr) {
  switch (periodStr) {
    case 'daily':
      return BudgetPeriod.daily;
    case 'weekly':
      return BudgetPeriod.weekly;
    case 'custom':
      return BudgetPeriod.custom;
    case 'monthly':
    default:
      return BudgetPeriod.monthly;
  }
}

// Helper function to get a display string
String getPeriodDisplayName(BudgetPeriod period) {
  switch (period) {
    case BudgetPeriod.daily:
      return 'Hàng ngày';
    case BudgetPeriod.weekly:
      return 'Hàng tuần';
    case BudgetPeriod.monthly:
      return 'Hàng tháng';
    case BudgetPeriod.custom:
      return 'Tùy chọn';
  }
}