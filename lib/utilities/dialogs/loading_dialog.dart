import 'package:flutter/material.dart';

typedef CloseDialog = void Function();

CloseDialog showLoadingDialog({ required BuildContext context, required String text }) {
  final dialog = AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 10.0,),
        Text(text),
      ],
    ),
  );

  showDialog(
    context: context, 
    barrierDismissible: false,  // cuando el user toque fuera del pop-up de alerta 
                                // todo estará bloqueado (hasta que el proceso acabe)
    builder: (context) => dialog,
  );

  // CloseDialog retorna una función que puede ser llamada.
  // Esta función es la de cerrar el pop-up el propio CloseDialog ha abierto,
  // para que sea otro proceso quién lo pueda cerrar.
  return () => Navigator.of(context).pop();
}