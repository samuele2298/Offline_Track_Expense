
class Person {
  final int id;
  final String name;
  final double balance;

  Person({
    required this.id,
    required this.name,
    required this.balance,
  });

  factory Person.fromMap(Map<String, dynamic> json) => Person(
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


  static final  Person none =  Person(id:-1,name:'none',balance: 0); // Define the empty person constant

  @override
  String toString() {
    return '\nPerson{id: $id, name: $name, balance: $balance}';
  }
}

