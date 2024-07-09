import 'dart:async';

import 'package:firstapp/helpers/loading/loading_screen_controller.dart';
import 'package:flutter/material.dart';

class LoadingScreen {
  factory LoadingScreen() => _shared;
  static final LoadingScreen _shared = LoadingScreen._sharedInstance();
  LoadingScreen._sharedInstance();

  LoadingScreenController? controller;

  void show({required BuildContext context, required String text,}) {
    // Si ya existe un controller solo se actualiza su texto, si no, se ejecuta showOverlay.
    if (controller?.update(text) ?? false) {
      return;
    } else {
      controller = showOverlay(context: context, text: text);
    }
  } 
    

  void hide() {
    controller?.close();
    controller = null;
  }

  LoadingScreenController showOverlay({required BuildContext context, required String text,}){
    final _text = StreamController<String>(); // Creamos un StreamController
    _text.add(text);                          // le metemos el "text" proporcionado.

    final state = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    // Este será nuestro OVERLAY
    final overlay = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.black.withAlpha(150),
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: size.width * 0.8,
                maxHeight: size.height * 0.8,
                minWidth: size.width * 0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      StreamBuilder(
                        stream: _text.stream, 
                        builder: (context, snapshot) {
                          if (snapshot.hasData){
                            return Text(
                              snapshot.data as String,
                              textAlign: TextAlign.center,
                            );
                          } else {
                            return Container(); //empty
                          }
                        }
                      ),
                    ],
                  ),
                ),
              ),
            )
          ),
        );
      },
    );


    // Así se muestra el overlay. Lo insertamos en el estado ("state" viene de "Overlay.of()" ).
    state?.insert(overlay);

    return LoadingScreenController(
      close: () {
        _text.close();
        overlay.remove();
        return true;
      },
      update: (text) {
        _text.add(text);
        return true;
      },
    );

  }
}