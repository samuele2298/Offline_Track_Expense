
class Category {
  final int id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });


  factory Category.fromMap(Map<String, dynamic> json) => Category(
    id: json['id'],
    name: json['name'],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
  static final  Category none =  Category(id:-1,name:'none'); // Define the empty person constant

  @override
  String toString() {
    return '\nCategory(id: $id, name: $name)';
  }
}

