class PatrimonioInventariado {
  final int? id;
  String numero;
  int idInventario;
  int idSetor;
  String estadoPatrimonio;
  String estadoConservacao;

  PatrimonioInventariado({
    this.id,
    required this.numero,
    required this.idInventario,
    required this.idSetor,
    required this.estadoConservacao,
    required this.estadoPatrimonio,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numero': numero,
      'idInventario': idInventario,
      'idSetor': idSetor,
      'estadoPatrimonio': estadoPatrimonio,
      'estadoConservacao': estadoConservacao,
    };
  }

  factory PatrimonioInventariado.fromMap(Map<String, dynamic> map) {
    return PatrimonioInventariado(
      id: map['id'],
      numero: map['numero'],
      idInventario: map['idInventario'],
      idSetor: map['idSetor'],
      estadoPatrimonio: map['estadoPatrimonio'] as String,
      estadoConservacao: map['estadoConservacao'] as String,
    );
  }
}
