import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {


  final Contact contact;
  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  //controladores dos campos
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _nameFocus = FocusNode();// dá foco no field de nome caso tente ser salvo com campo vazio
    
  bool _userEdited = false;

  Contact _editedContact;

@override
  void initState() {
    super.initState();

    if(widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());
      //caso o contato já exista, mostra seus dados na tela de edição
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(// chama a função da janela de confirmação antes de sair da tela
      onWillPop: _requestPop,
      child: Scaffold (
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(_editedContact.name ?? "Novo Contato"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if(_editedContact !=null && _editedContact.name.isNotEmpty) {// testa se o nome está preenchido ou em branco
            Navigator.pop(context, _editedContact);
          } else {
            FocusScope.of(context).requestFocus(_nameFocus);
          }
        },
        child: Icon(Icons.check),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(//serve pro teclado não cobrir os campos da tela
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            GestureDetector(// para poder clicar na imagem
              child: Container(
                width: 140.0,
                height: 140.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: _editedContact.img !=null ?
                      FileImage(File(_editedContact.img)) :
                      AssetImage("images/person.png"),
                      fit: BoxFit.cover
                    )
                ),
              ),
              onTap: (){
                ImagePicker.pickImage(source: ImageSource.camera).then((file){
                  if(file == null) return;
                  setState(() {
                    _editedContact.img = file.path;
                  });
                });
              },
            ),
            TextField(//campos com info do contato
              controller: _nameController,
              focusNode: _nameFocus,
              decoration: InputDecoration(labelText: "Nome"),
              onChanged: (text){//função para validar se exitiu alguma edição para mostrar na barra superior
                _userEdited = true;
                setState(() {
                 _editedContact.name = text; 
                });
              },
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "E-mail"),
              onChanged: (text){
                _userEdited = true;
                _editedContact.email = text;
              },
              keyboardType: TextInputType.emailAddress,//mostra @ no teclado
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "Phone"),
              onChanged: (text){
                _userEdited = true;
                _editedContact.phone = text;
              },
              keyboardType: TextInputType.phone,//teclado numérico
            )
          ],
        ),
      ),
    )
    );
  }

  Future<bool>_requestPop() { //função para testar se o contato sofreu edição e mostra janela de confirmação para salvamento
    if(_userEdited) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(//tela para validação de salvamento
            title: Text("Descartar Alterações?"),
            content: Text("Se sair as alterações serão perdidas."),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: () {
                  Navigator.pop(context);
                }
              ),
              FlatButton(
                child: Text("Sim"),
                onPressed: (){
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              )
            ],
          );
        }
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}