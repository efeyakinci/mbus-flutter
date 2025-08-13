import 'package:flutter/material.dart';
// ignore_for_file: unused_import
import 'package:mbus/constants.dart';
import 'package:mbus/theme/app_theme.dart';

class DialogAction {
  final String title;
  final Function() action;

  DialogAction(this.title, this.action);
}

class DialogData {
  final String title;
  final String message;
  final List<DialogAction> actions;

  DialogData(this.title, this.message, this.actions);
}

WidgetBuilder getMessageDialog(DialogData data) {
  return (context) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Container(
          // set the minimum height of the dialog to 200
          constraints: BoxConstraints(maxHeight: 500.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints: BoxConstraints(maxHeight: 50.0),
                  child: Center(
                      child:
                          Text(data.title, style: AppTextStyles.dialogTitle)),
                ),
                SizedBox(
                  height: 10,
                ),
                // Text container that scrolls if the text is too long and shrinks if the text is short
                Container(
                  constraints: BoxConstraints(maxHeight: 300.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [Text(data.message, style: AppTextStyles.body)],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: data.actions
                      .map((action) => TextButton(
                            child: Text(action.title),
                            onPressed: () {
                              action.action();
                              Navigator.of(context).pop();
                            },
                          ))
                      .toList(),
                )
              ],
            ),
          ),
        ),
      );
}
