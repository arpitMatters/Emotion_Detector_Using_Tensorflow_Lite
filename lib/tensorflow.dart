import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Tensorflow extends StatefulWidget {
  @override
  _TensorflowState createState() => _TensorflowState();
}

class _TensorflowState extends State<Tensorflow> {
  List _outputs;
  File
      _image; //image taken from image_picker are saved as variables of type File.
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  loadModel() async {
    // asynchronously waiting for the assets to load
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1, // number of threads will be 1 since dart works as isolate.
    );
  }

  classifyImage(File image) async {
    //image stream is passed to classifyImage.
    var output = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true);
    setState(() {
      _loading =
          false; //we are setting loading to false when classifying image.
      _outputs = output; //storing output to list _outputs.
    });
  }

  @override
  void dispose() {
    Tflite.close(); //dispose of the model and closing tflite.
    super.dispose();
  }

  pickImage() async {
    // to pick an image from gallery.
    var image = await ImagePicker.pickImage(
        source: ImageSource
            .gallery); // async waiting before next step to return a future.
    if (image == null) return null;
    setState(() {
      _loading = true; //when picking image we set loading to true.
      _image = image;
    });
    classifyImage(_image); // we pass the image to classifyImage func.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Tensorflow Lite",
          style: TextStyle(color: Colors.white, fontSize: 25),
        ),
        backgroundColor: Colors.amber,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _loading
                ? Container(
                    //if loading is true, import the image from gallery.
                    height: 300,
                    width: 300,
                  )
                : Container(
                    margin: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _image == null
                            ? Container()
                            : Image.file(
                                _image), // if we select an image from gallery, then load that image to the screen
                        SizedBox(
                          height: 20,
                        ),
                        _image == null
                            ? Container()
                            : _outputs != null
                                ? // if image is loaded and there is an output in the _outputs list then print that output below the image.
                                Text(
                                    _outputs[0]["label"],
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 20),
                                  )
                                : Container(child: Text(""))
                      ],
                    ),
                  ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            FloatingActionButton(
              tooltip: 'Pick Image',
              onPressed: pickImage,
              child: Icon(
                Icons.add_a_photo,
                size: 20,
                color: Colors.white,
              ),
              backgroundColor: Colors.amber,
            ),
          ],
        ),
      ),
    );
  }
}
