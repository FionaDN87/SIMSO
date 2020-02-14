import 'package:simso/view/navigation-drawer.dart';
import 'package:unicorndial/unicorndial.dart';
import 'package:flutter/material.dart';
import 'package:simso/controller/homepage-controller.dart';
import 'package:simso/model/services/itimer-service.dart';
import 'package:simso/model/services/iuser-service.dart';
import '../model/entities/user-model.dart';
import '../service-locator.dart';
import '../model/entities/globals.dart' as globals;

class Homepage extends StatefulWidget {
  final UserModel user;

  Homepage(this.user);

  @override
  State<StatefulWidget> createState() {
    return HomepageState(user);
  }
}

class HomepageState extends State<Homepage> {
  BuildContext context;
  IUserService userService = locator<IUserService>();
  ITimerService timerService = locator<ITimerService>();
  HomepageController controller;
  UserModel user;
  String returnedID;
  var idController = TextEditingController();
  var formKey = GlobalKey<FormState>();

  HomepageState(this.user) {
    controller = HomepageController(this, this.userService, this.timerService);
    controller.setupTimer();
  }

  void stateChanged(Function f) {
    setState(f);
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    var childButtons = List<UnicornButton>();

    childButtons.add(
      UnicornButton(
        hasLabel: true,
        labelText: "Add Thoughts",
        labelFontSize: 10,
        currentButton: FloatingActionButton(
          heroTag: "Add Thoughts",
          backgroundColor: Colors.white,
          mini: true,
          child: Icon(
            Icons.library_music,
            color: Colors.black,
          ),
          // Text(
          //   "Add Playlist",
          //   style: TextStyle(color: Colors.black),
          // ),
          onPressed: controller.addThoughts,
        ),
      ),
    );

    childButtons.add(
      UnicornButton(
        hasLabel: true,
        labelText: "Add Photos",
        labelFontSize: 10,
        currentButton: FloatingActionButton(
          heroTag: "Add Photos",
          backgroundColor: Colors.white,
          mini: true,
          child: Icon(
            Icons.library_music,
            color: Colors.black,
          ),
          // Text(
          //   "Add Playlist",
          //   style: TextStyle(color: Colors.black),
          // ),
          onPressed: controller.addPhotos,
        ),
      ),
    );

    childButtons.add(
      UnicornButton(
        hasLabel: true,
        labelText: "Add Memes",
        labelFontSize: 10,
        currentButton: FloatingActionButton(
          heroTag: "Add Memes",
          backgroundColor: Colors.white,
          mini: true,
          child: Icon(
            Icons.library_music,
            color: Colors.black,
          ),
          // Text(
          //   "Add Playlist",
          //   style: TextStyle(color: Colors.black),
          // ),
          onPressed: controller.addMemes,
        ),
      ),
    );

    childButtons.add(
      UnicornButton(
        hasLabel: true,
        labelText: "Add Music",
        labelFontSize: 10,
        currentButton: FloatingActionButton(
          heroTag: "Add Music",
          backgroundColor: Colors.white,
          mini: true,
          child: Icon(
            Icons.music_note,
            color: Colors.black,
          ),
          // Text(
          //   "Add Song",
          //   style: TextStyle(color: Colors.black),
          // ),
          onPressed: controller.addMusic,
        ),
      ),
    );

    return Scaffold(
      floatingActionButton: UnicornDialer(
        backgroundColor: Colors.transparent,
        parentButtonBackground: Colors.blueGrey[300],
        orientation: UnicornOrientation.VERTICAL,
        parentButton: Icon(
          Icons.menu,
        ),
        childButtons: childButtons,
      ),
      appBar: AppBar(),
      drawer: MyDrawer(user),
      body: Container(
          child: Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              onSaved: controller.saveEmail,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              onSaved: controller.saveUsername,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            FlatButton(
              onPressed: controller.saveUser,
              child: Text(
                'Add Data',
              ),
            ),
            Text(
              returnedID == null
                  ? ''
                  : 'The ID of your new document has returned',
              style: TextStyle(color: Colors.redAccent),
            ),
            TextFormField(
              onSaved: controller.saveUserID,
              controller: idController,
              decoration: InputDecoration(
                labelText: 'Get Customer by ID',
              ),
            ),
            FlatButton(
              onPressed: controller.getUserData,
              child: Text(
                'Get User',
              ),
            ),
            Text('User Email: ' + user.email == null ? '' : 'user.email'),
            Text('Username: ' + user.username == null ? '' : 'user.username'),
            Text(globals.timer == null ? '' : '${globals.timer.timeOnAppSec}'),
            FlatButton(
              onPressed: controller.refreshState,
              child: Text(
                'Resfresh State',
              ),
            ),
          ],
        ),
      )),
    );
  }
}
