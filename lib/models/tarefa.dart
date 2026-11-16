enum Prioridade {
  baixa('Baixa'),
  media('Média'),
  alta('Alta');

  const Prioridade(this.rotulo);
  final String rotulo;
}

class Tarefa {
  const Tarefa({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dataVencimento,
    required this.prioridade,
    required this.concluida,
  });

  final String id;
  final String titulo;
  final String descricao;
  final DateTime dataVencimento;
  final Prioridade prioridade;
  final bool concluida;

  bool atrasadaEm(DateTime agora) =>
      !concluida &&
      dataVencimento.isBefore(DateTime(agora.year, agora.month, agora.day));

  factory Tarefa.fromMap(String id, Map<Object?, Object?> map) {
    return Tarefa(
      id: id,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      dataVencimento: DateTime.parse(map['dataVencimento'] as String),
      prioridade: Prioridade.values.byName(map['prioridade'] as String),
      concluida: map['concluida'] as bool,
    );
  }

  Map<String, Object> toMap() => {
    'id': id,
    'titulo': titulo,
    'descricao': descricao,
    'dataVencimento':
        '${dataVencimento.year.toString().padLeft(4, '0')}-'
        '${dataVencimento.month.toString().padLeft(2, '0')}-'
        '${dataVencimento.day.toString().padLeft(2, '0')}',
    'prioridade': prioridade.name,
    'concluida': concluida,
  };

  Tarefa copyWith({
    String? id,
    String? titulo,
    String? descricao,
    DateTime? dataVencimento,
    Prioridade? prioridade,
    bool? concluida,
  }) => Tarefa(
    id: id ?? this.id,
    titulo: titulo ?? this.titulo,
    descricao: descricao ?? this.descricao,
    dataVencimento: dataVencimento ?? this.dataVencimento,
    prioridade: prioridade ?? this.prioridade,
    concluida: concluida ?? this.concluida,
  );
}
