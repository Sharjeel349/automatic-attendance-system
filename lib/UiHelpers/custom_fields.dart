import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class FormInput extends StatelessWidget {
  const FormInput({super.key, required this.labeltext, required this.textController, required this.inputType,this.isobsecure=false, this.obsecuredPress});

  final String labeltext;
  final TextEditingController textController;
  final TextInputType inputType;
  final bool isobsecure;
  final VoidCallback? obsecuredPress;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      inputFormatters: [
        if (inputType == TextInputType.visiblePassword)
          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9!@#\$-]'))
      ],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please fill details';
        if (inputType == TextInputType.visiblePassword) {
          if (value.length < 8) return 'Password must contain at least 8 characters';
             return null;
        }
        return null;
      },

      obscureText: isobsecure,
      obscuringCharacter: '*',
      keyboardType: inputType,
      controller: textController,

      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        labelText: labeltext,
        suffixIcon: inputType == TextInputType.visiblePassword ?  IconButton(onPressed: obsecuredPress, icon:Icon(isobsecure == true ? Icons.visibility : Icons.visibility_off),) : null,
      ),
    );
  }
}