import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simso/view/design-constants.dart';
import '../model/entities/user-model.dart';
import '../model/entities/image-model.dart';
import '../controller/add-photo-controller.dart';
import 'package:simso/model/services/ipicture-service.dart';
import '../service-locator.dart';
import '../model/entities/globals.dart' as globals;

List<CameraDescription> cameras;

IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw ArgumentError('Unknown lens direction');
}

class AddPhoto extends StatefulWidget {

  final UserModel user;
  final ImageModel image;

  AddPhoto(this.user, this.image);
  
  // @override
  // AddPhotoState createState() => AddPhotoState();

  @override
  State<StatefulWidget> createState() {
    return AddPhotoState(user, image);
  }
}

class AddPhotoState extends State<AddPhoto> {

  UserModel user;
  ImageModel image;
  ImageModel imageCopy;
  AddPhotoController controller2;
  var formKey = GlobalKey<FormState>();
  IImageService imageService = locator<IImageService>();

  // final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<CameraDescription> cameras;
  CameraController controller;
  
  bool isReady = false;
  bool showCamera = true;
  String imagePath;

  TextEditingController summaryController = TextEditingController();
  // TextEditingController countryController = TextEditingController();
  // TextEditingController abvController = TextEditingController();

  AddPhotoState(this.user, this.image) {
    controller2 = AddPhotoController(this);
    if (image == null) {
      // addButton
      imageCopy = ImageModel.empty();
    } else {
      imageCopy = ImageModel.clone(image); //clone
    }
  }

  void stateChanged(Function fn) {
    setState(fn);
  }

  @override
  void initState() {
    super.initState();
    setupCameras();
  }

  Future<void> setupCameras() async {
    try {
      cameras = await availableCameras();
      controller = new CameraController(cameras[0], ResolutionPreset.medium);
      await controller.initialize();
    } on CameraException catch (_) {
      setState(() {
        isReady = false;
      });
    }
    setState(() {
      isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    globals.context = context;
    return WillPopScope(
      onWillPop: () {
        return Future.value(true);
    },
    child: Scaffold(
        appBar: AppBar(
          title: Text("My Photos"),
          backgroundColor: DesignConstants.blue,
        ),
        body: Form(
            child: Center(
            child: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Center(
                  child: showCamera
                      ? Container(
                          height: 290,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Center(
                              child: cameraPreviewWidget()),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                              imagePreviewWidget(),
                              editCaptureControlRowWidget(),
                            ]),
                ),
                showCamera ? captureControlRowWidget() : Container(),
                cameraOptionsWidget(),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: imageCopy.summary,
                        decoration: InputDecoration(
                          labelText: 'Summary',
                        ),
                        autocorrect: false,
                        validator: controller2.validateSummary,
                        onSaved: controller2.saveSummary,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Builder(
                          builder: (context) {
                            return RaisedButton(
                              color: DesignConstants.blue,
                              child: Text('Add Image',
                                      style: TextStyle(color:Colors.white
                                      ),
                              ),
                              onPressed: controller2.add,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    )),
        )));

  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.high);

    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        //showInSnackBar('Camera error ${controller.value.errorDescription}');
        print(controller.value.errorDescription);
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      //showInSnackBar('Camera error ${e}');
      print(e);
    }

    if (mounted) {
      setState(() {});
    }
  }


  Widget cameraOptionsWidget() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          showCamera ? cameraTogglesRowWidget() : Container(),
        ],
      ),
    );
  }

  //flip camera function
  Widget cameraTogglesRowWidget() {
    final List<Widget> toggles = <Widget>[];

    if (cameras != null) {
      if (cameras.isEmpty) {
        return const Text('No camera found');
      } else {
        for (CameraDescription cameraDescription in cameras) {
          toggles.add(
            SizedBox(
              width: 90.0,
              child: RadioListTile<CameraDescription>(
                title: Icon(getCameraLensIcon(cameraDescription.lensDirection)),
                groupValue: controller?.description,
                value: cameraDescription,
                onChanged: controller != null ? onNewCameraSelected : null,
              ),
            ),
          );
        }
      }
    }

    return Row(children: toggles);
  }

  //capture image function
  Widget captureControlRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.camera_alt),
          color: Colors.blue,
          onPressed: controller != null && controller.value.isInitialized
              ? onTakePictureButtonPressed
              : null,
        ),
      ],
    );
  }

  //retake picture
  Widget editCaptureControlRowWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Align(
        alignment: Alignment.topCenter,
        child: IconButton(
          icon: const Icon(Icons.cancel),
          color: Colors.blue,
          onPressed: () => setState(() {
                showCamera = true;
              }),
        ),
      ),
    );
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          showCamera = false;
          imagePath = filePath;
        });
      }
    });
  }

  // void showInSnackBar(String message) {
  //   scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  // }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      return null;
    }
    return filePath;
  }

  //camera display
  Widget cameraPreviewWidget() {
    if (!isReady || !controller.value.isInitialized) {
      return Container();
    }
    return AspectRatio(
        aspectRatio: 1,
        //aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller));
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Widget imagePreviewWidget() {
    return Container(
        child: Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Align(
        alignment: Alignment.topCenter,
        child: imagePath == null
            ? null
            : SizedBox(
                child: Image.file(File(imagePath)),
                height: 290.0,
              ),
      ),
    ));
  }
}