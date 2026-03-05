class Folder {
  final int? id;
  final String folderName;
  final String timestamp;

  Folder({
    this.id,
    required this.folderName,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'folder_name': folderName,
      'timestamp': timestamp,
    };
  }

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'],
      folderName: map['folder_name'],
      timestamp: map['timestamp'],
    );
  }
}