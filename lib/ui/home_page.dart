import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:agenda_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {orderaz, orderza}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();//pega o banco

  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState(); //mostra os contatos já salvos ao inicializar o app
    _getAllContacts();//obtém todos os contatos
  }

  @override
  Widget build(BuildContext context) {//criar layout
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de contatos"),
        backgroundColor: Colors.indigo,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A-Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.orderza,
              )
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white70,
      floatingActionButton: FloatingActionButton(//cria botão para add contatos
        onPressed: (){
          _showContactPage();
        },
        child: Icon(Icons.add),//mostra icone de add no botão
        backgroundColor: Colors.indigo,
      ),
      body: ListView.builder(//corpo do app gerando uma lista desntro de um container para dar o padding
        padding: EdgeInsets.all(10.0),//add borda
        itemCount: contacts.length,//tamanho da lista com o tamanho de contatos
        itemBuilder: (context, index){
          return _contactCard(context, index);//retorna o card do contato com os dados
        },
      )
    );
  }

  Widget _contactCard(BuildContext context, int index){//cria os cards dos contatos
    return GestureDetector(// gesture detector serve para dar a opção de toque no card
      child: Card(
        child: Padding(//padding do card
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(//container para deixar a imagem redonda
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,//shape circular da imagem
                  image: DecorationImage(
                    image: contacts[index].img !=null ? // se o contato tiver imagem, pega a imagem dele do banco
                      FileImage(File(contacts[index].img)) :
                      AssetImage("images/person.png"),//caso contrário pega a imagem padrão do sistema
                      fit: BoxFit.cover
                    )
                ),
              ),
              Padding(//dar um espaço da imagem para a info do contato
                padding: EdgeInsets.only(left: 10.0),
                child: Column(// formar uma coluna vertical de contatos
                  children: <Widget>[
                    Text(contacts[index].name ?? "",// ?? exibe o campo em branco caso não seja adicionado nome no banco
                    style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    Text(contacts[index].email ?? "",
                    style: TextStyle(fontSize: 18.0),
                    ),
                    Text(contacts[index].phone ?? "",
                    style: TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
              )
            ],
          ),
          ),
      ),
      onTap: (){
        _showOptions(context, index);
      },
      );
  }

  _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context){
        return BottomSheet(
          onClosing: (){},
          builder: (context){
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Ligar", 
                        style: TextStyle(color: Colors.indigo, fontSize: 20.0)),
                      onPressed: (){
                        launch("tel:${contacts[index].phone}");
                        Navigator.pop(context);
                      }
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Editar", 
                        style: TextStyle(color: Colors.indigo, fontSize: 20.0)),
                      onPressed: (){
                        Navigator.pop(context);
                        _showContactPage(contact: contacts[index]);
                      }
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Excluir", 
                        style: TextStyle(color: Colors.indigo, fontSize: 20.0)),
                      onPressed: (){
                        helper.deleteContact(contacts[index].id);
                        setState(() {
                          contacts.removeAt(index);
                          Navigator.pop(context);
                        });
                        
                      }
                    ),
                  )
                ],
              ),
            );
          },
        );
      }
    );
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(context, 
      MaterialPageRoute(builder: (context) => ContactPage(contact: contact,))
    );
    if(recContact != null){
      if(contact !=null){
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
        _getAllContacts();
    }
  }

  _getAllContacts() {
    helper.getAllContacts().then((list){
      setState(() {
      contacts = list;  
      });
    });
  }

  void _orderList(OrderOptions result) {
    switch(result){
      case OrderOptions.orderaz:
      contacts.sort((a,b){
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
        break;
      case OrderOptions.orderza:
      contacts.sort((a,b){
        return b.name.toLowerCase().compareTo(a.name.toLowerCase());
      });
        break;
    }
    setState(() {
      
    });
  }

}