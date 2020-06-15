import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String contactTable = "contactTable";
final String idColumn ="idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactHelper { //singleton declarando a classe com instance e construtor interno

  static final ContactHelper _instance = ContactHelper.internal(); //construtor interno

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _db; //declaração do banco para que sseja acessado somente pelo contactHelper

  Future<Database> get db async {//future devido ao await, já que o banco não retorna instantaneamente
    if(_db != null){
      return _db; //retorna o banco caso ele já tenha inicializado
    }else {
      _db = await initDb(); // senão, inicia o banco
      return _db;
    }
  }

  Future<Database> initDb() async { //função para inicializar o banco   //async complementa para que o await funcione
    final databasesPath = await getDatabasesPath(); //await faz com que espere o recebimento dos dados
    final path = join(databasesPath, "contactsnew.db");//local do arquivo do banco que vai dar load

    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion)async{//cria o banco na primeira vez que ele executa
      await db.execute(//espera o banco executar
        "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,"
        " $phoneColumn TEXT, $imgColumn TEXT)"//cria a tabela e declara as colunas
      );
    });
  }

  Future<Contact> saveContact(Contact contact) async { //insere o contato no banco
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact; //retorna o id do contato
  }

  Future<Contact> getContact(int id) async {// recebe a id do contato
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,// query para obter dados das tabelas
      columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
      where: "$idColumn = ?", whereArgs: [id]); //pega o contato através do id
    if(maps.length> 0){ //retorna um contato existente da lista
      return Contact.fromMap(maps.first);
    } else{ //senão, não existem contatos na lista
      return null;
    }
  }

  Future<int>deleteContact(int id) async {//função pra deletar um contato através do seu id
    Database dbContact = await db;
    return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {//função para atualziar dados de um contato
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(), where: "$idColumn= ?", whereArgs: [contact.id]);
  }

  Future<List> getAllContacts() async {//função para obter todos os contatos
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable"); //cria uma lista de contatos onde cada map é um contato
    List<Contact> listContact = List();
    for(Map m in listMap){
      listContact.add(Contact.fromMap(m));//adiciona na lista
    }
    return listContact;
  }

  Future<int> getNumber() async {//mostra quantidade de contatos
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {//função para fechar o banco
    Database dbContact = await db;
    dbContact.close();
  }
}

class Contact {

  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();

  //construtor > pega os dados através de um map, passando para o contato
  Contact.fromMap(Map map){
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }
  //função > pega do contato e passa para o map
  Map toMap() {
    Map<String, dynamic> map = { //string contém o campo e o dynamic o dado
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    //o banco de dados é quem da o id
    if(id != null){
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {//printa todas as informações do contato
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}