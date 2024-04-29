
class Account {
  final int? id;
  final String name;
  final double balance;

  Account({
    this.id,
    required this.name,
    required this.balance,
  });

  factory Account.fromMap(Map<String, dynamic> json) => Account(
    id: json['id'],
    name: json['name'],
    balance: json['balance'].toDouble(),
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
    };
  }
  static final  Account none =  Account(id:-1,name:'none',balance: 0); // Define the empty person constant

  @override
  String toString() {
    return '\nAccount(id: $id, name: $name, balance: $balance)';
  }


}

