import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mbus/constants.dart';
import 'package:mbus/dialogs/message_dialog.dart';
import 'package:mbus/mbus_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final log = Logger("NotificationService");

  WidgetBuilder getStartupMessageDialog(dynamic res) {
    final title = res['title'] ?? "Update Notes!";
    final message = res['message'] ?? "No message found";
    final id = res['id'] ?? "-1";
    final actions = [
      DialogAction("Dismiss", () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("dismissedMessageId", id);
      })
    ];

    return getMessageDialog(DialogData(title, message, actions));
  }

  Future<void> checkMessages(BuildContext context) async {
    try {
      final res = jsonDecode(await NetworkUtils.getWithErrorHandling(
          context, "get-startup-messages"));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String dismissedMessageId =
          prefs.getString("dismissedMessageId") ?? "None";
      final String messageId = res['id'] ?? "-1";

      if (double.parse(res['buildVersion']) > BUILD_VERSION &&
          messageId != dismissedMessageId) {
        await showDialog(
            context: context, builder: getStartupMessageDialog(res));
      }

      log.info("Got startup messages");
    } catch (e) {
      NetworkUtils.createNetworkError();
      return;
    }
  }

  Future<void> checkUpdateNotes(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool updateNotesDismissed = prefs.getBool("updateNotesDismissed") ?? false;

    if (updateNotesDismissed) {
      return;
    }

    Map<String, dynamic> notes = jsonDecode(
        await NetworkUtils.getWithErrorHandling(context, 'getUpdateNotes'));

    log.info("Got update notes");

    if (notes['version'] != BUILD_VERSION.toString()) {
      return;
    }

    showDialog(
        context: context,
        builder: (context) => Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              child: Container(
                // set the minimum height of the dialog to 200
                constraints: BoxConstraints(maxHeight: 500.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                          child: Text(
                        "Update Notes!",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                      SizedBox(
                        height: 20,
                      ),
                      // Text container that scrolls if the text is too long and shrinks if the text is short
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SingleChildScrollView(
                            child: Text(
                              notes["message"] ?? "No message found",
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            child: Text("Dismiss"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ));
  }
} 