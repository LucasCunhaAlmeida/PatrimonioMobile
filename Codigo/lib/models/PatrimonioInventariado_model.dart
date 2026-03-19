class PatrimonioInventariado {
  final int? id;
  String numero;
  final int idInventario;
  final int idSetor;

  PatrimonioInventariado({
    this.id,
    required this.numero,
    required this.idInventario,
    required this.idSetor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero': numero,
      'idInventario': idInventario,
      'idSetor': idSetor,
    };
  }

  factory PatrimonioInventariado.fromMap(Map<String, dynamic> map) {
    return PatrimonioInventariado(
      id: map['id'],
      numero: map['numero'],
      idInventario: map['idInventario'],
      idSetor: map['idSetor'],
    );
  }
}