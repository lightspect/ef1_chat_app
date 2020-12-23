import 'package:flutter/material.dart';

import 'color_utils.dart';

class AppButton extends StatelessWidget {
  AppButton(
      {this.onClick,
      this.text,
      this.textColor,
      this.color,
      this.splashColor,
      this.highlightColor,
      this.borderRadius,
      this.minWidth,
      this.height,
      this.fontSize,
      this.borderColor,
      this.style,
      this.leadingIcon,
      this.trailingIcon});

  final VoidCallback onClick;
  final String text;
  final Color textColor;
  final Color color;
  final Color splashColor;
  final Color highlightColor;
  final double borderRadius;
  final double minWidth;
  final double height;
  final double fontSize;
  final Color borderColor;
  final TextStyle style;
  final IconData leadingIcon;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
          bottom: 12.0, top: 12.0, left: 12.0, right: 12.0),
      child: MaterialButton(
        minWidth: minWidth ?? 160,
        height: height ?? 48,
        color: color ?? Colors.green,
        onPressed: onClick ?? () {},
        child: Text(
          text ?? "Button",
          style: TextStyle(fontSize: fontSize ?? 14),
        ),
        textColor: textColor ?? Colors.white,
        //splashColor: splashColor ?? Colors.red,
        //highlightColor: highlightColor ?? Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 5),
          side: BorderSide(
              color: borderColor ?? Colors.white,
              width: 1.0,
              style: BorderStyle.solid),
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  AppTextField(
      {this.controller,
      this.hintText,
      this.helpText,
      this.prefixIcon,
      this.suffixIcon,
      this.isPassword,
      this.enabled,
      this.readOnly,
      this.borderColor,
      this.textColor});

  final TextEditingController controller;
  final String hintText;
  final String helpText;
  final IconData prefixIcon;
  final IconData suffixIcon;
  final bool isPassword;
  final bool enabled;
  final bool readOnly;
  final Color borderColor;
  final Color textColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      margin: const EdgeInsets.only(top: 15.0),
      child: TextField(
        controller: controller,
        readOnly: null == readOnly ? false : true,
        obscureText: null == isPassword ? false : true,
        decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          hintText: null == hintText ? '' : hintText,
          hintStyle: TextStyle(color: Colors.grey),
          helperText: null == helpText ? '' : helpText,
          prefixIcon: null == prefixIcon ? null : Icon(prefixIcon),
          suffix: null == suffixIcon ? null : Icon(suffixIcon),
          enabled: null == enabled ? true : false,
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  LoginButton(
      {this.onClick,
      this.text,
      this.textColor,
      this.color,
      this.splashColor,
      this.highlightColor,
      this.borderRadius,
      this.minWidth,
      this.height,
      this.fontSize,
      this.borderColor,
      this.style,
      this.leadingIcon,
      this.trailingIcon,
      this.margin});

  final VoidCallback onClick;
  final String text;
  final Color textColor;
  final Color color;
  final Color splashColor;
  final Color highlightColor;
  final double borderRadius;
  final double minWidth;
  final double height;
  final double fontSize;
  final Color borderColor;
  final TextStyle style;
  final IconData leadingIcon;
  final IconData trailingIcon;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.all(12),
      child: MaterialButton(
        minWidth: minWidth ?? 160,
        height: height ?? 48,
        color: color ?? colorRed,
        onPressed: onClick ?? () {},
        child: Text(
          text ?? "Button",
          style: TextStyle(fontSize: fontSize ?? 14),
        ),
        textColor: textColor ?? Colors.white,
        //splashColor: splashColor ?? Colors.red,
        //highlightColor: highlightColor ?? Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 5),
          side: BorderSide(
              color: borderColor ?? colorRed,
              width: 1.0,
              style: BorderStyle.solid),
        ),
      ),
    );
  }
}

class LoginLogo extends StatelessWidget {
  LoginLogo({this.margin, this.width, this.image});

  final EdgeInsets margin;
  final double width;
  final Image image;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        margin: margin ?? EdgeInsets.only(bottom: 16),
        width: width ?? MediaQuery.of(context).size.width,
        child: Image(
          image: image ?? AssetImage('assets/images/logo_wallet.png'),
        ),
      ),
    );
  }
}

class TextFormFieldWidget extends StatefulWidget {
  final TextInputType textInputType;
  final String hintText;
  final Widget prefixIcon;
  final Widget suffixIcon;
  final String defaultText;
  final Color textColor;
  final Color cursorColor;
  final Color focusBorderColor;
  final FocusNode focusNode;
  final bool obscureText;
  final bool enable;
  final double width;
  final TextEditingController controller;
  final Function functionValidate;
  final TextInputAction actionKeyboard;
  final Function onSubmitField;
  final Function onFieldTap;
  final Function onChange;
  final EdgeInsets padding;

  const TextFormFieldWidget(
      {@required this.hintText,
      this.width,
      this.focusNode,
      this.textInputType,
      this.defaultText,
      this.obscureText = false,
      this.enable = true,
      this.textColor,
      this.cursorColor,
      this.focusBorderColor,
      this.controller,
      this.functionValidate,
      this.actionKeyboard = TextInputAction.next,
      this.onSubmitField,
      this.onFieldTap,
      this.prefixIcon,
      this.suffixIcon,
      this.padding,
      this.onChange});

  @override
  _TextFormFieldWidgetState createState() => _TextFormFieldWidgetState();
}

class _TextFormFieldWidgetState extends State<TextFormFieldWidget> {
  double bottomPaddingToError = 8;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? EdgeInsets.all(16),
      width: widget.width ?? 288,
      child: TextFormField(
        enabled: widget.enable,
        cursorColor: widget.cursorColor ?? Colors.white,
        obscureText: widget.obscureText,
        keyboardType: widget.textInputType,
        textInputAction: widget.actionKeyboard,
        focusNode: widget.focusNode,
        style: TextStyle(
          color: widget.textColor ?? Colors.white,
          fontSize: 14.0,
          letterSpacing: 1.2,
        ),
        initialValue: widget.defaultText,
        decoration: InputDecoration(
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          hintText: widget.hintText,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: widget.focusBorderColor ?? Colors.white),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 14.0,
            letterSpacing: 1.2,
          ),
          contentPadding:
              EdgeInsets.only(top: 12, bottom: bottomPaddingToError),
          isDense: true,
          errorStyle: TextStyle(
            color: colorRed,
            fontSize: 12.0,
            fontWeight: FontWeight.w300,
            fontStyle: FontStyle.normal,
            letterSpacing: 1.2,
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colorRed),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colorRed),
          ),
        ),
        controller: widget.controller,
        validator: (value) {
          if (widget.functionValidate != null) {
            String resultValidate = widget.functionValidate(value);
            if (resultValidate != null) {
              return resultValidate;
            }
          }
          return null;
        },
        onFieldSubmitted: (value) {
          if (widget.onSubmitField != null) widget.onSubmitField(value);
        },
        onTap: () {
          if (widget.onFieldTap != null) widget.onFieldTap();
        },
        onChanged: (value) {
          if (widget.onChange != null) widget.onChange(value);
        },
      ),
    );
  }
}

void changeFocus(
    BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}

class CustomAlertDialog extends StatelessWidget {
  CustomAlertDialog({
    this.title,
    this.icon,
    this.bodyTitle,
    this.bodySubtitle,
    this.bodyAction,
    this.action,
  });
  final String title;
  final Icon icon;
  final String bodyTitle;
  final String bodySubtitle;
  final List<Widget> bodyAction;
  final List<Widget> action;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title ?? "Custom Alert Dialog",
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
          child: ListBody(children: [
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Visibility(
                visible: icon != null,
                child: icon ??
                    Icon(
                      Icons.check_circle,
                      color: colorGreen,
                      size: 60,
                    ),
              ),
              Visibility(
                visible: bodyTitle.isNotEmpty,
                child: Text(
                  bodyTitle ?? "Success",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Visibility(
                visible: bodySubtitle.isNotEmpty,
                child: Text(
                  bodySubtitle ?? "",
                  textAlign: TextAlign.center,
                ),
              ),
              Column(
                children: bodyAction ?? <Widget>[],
              )
            ],
          ),
        )
      ])),
      actions: action ?? <Widget>[],
    );
  }
}

class ExitAlertDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Exit?'),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(
            'Cancel',
            style: Theme.of(context).textTheme.button.copyWith(
                  fontWeight: FontWeight.normal,
                ),
          ),
        ),
        FlatButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: Text('Exit'),
        ),
      ],
    );
  }
}
