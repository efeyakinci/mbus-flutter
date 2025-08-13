import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mbus/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mbus/data/providers.dart';
import 'package:mbus/data/api_errors.dart';

enum SUBMISSION_STATES {
  PRE_SUBMIT,
  SUBMITTING,
  SUCCESS,
  TOO_MANY_REQUESTS,
  FAILED
}

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  SUBMISSION_STATES submissionState = SUBMISSION_STATES.PRE_SUBMIT;
  String feedback = "";

  void onSubmit() async {
    setState(() {
      submissionState = SUBMISSION_STATES.SUBMITTING;
    });
    try {
      final api = ProviderScope.containerOf(context, listen: false).read(apiClientProvider);
      await api.giveFeedback(feedback);
      setState(() {
        submissionState = SUBMISSION_STATES.SUCCESS;
      });
    } on RateLimitException {
      setState(() {
        submissionState = SUBMISSION_STATES.TOO_MANY_REQUESTS;
      });
    } catch (_) {
      setState(() {
        submissionState = SUBMISSION_STATES.FAILED;
      });
    }

  }

  Widget getLastFormElement() {
    switch (submissionState) {
      case SUBMISSION_STATES.PRE_SUBMIT:
        return AnimatedOpacity(
          opacity: feedback.length > 0 ? 1.0 : 0.0,
          duration: Duration(milliseconds: 250),
          child: CupertinoButton(
            color: MICHIGAN_BLUE,
            child: Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
            onPressed: feedback.length > 0 ? onSubmit : () {},
          ),
        );
      case SUBMISSION_STATES.SUBMITTING:
        return CircularProgressIndicator(color: MICHIGAN_BLUE,);
      case SUBMISSION_STATES.SUCCESS:
        return Row(
          children: [Icon(Icons.check_circle, color: MICHIGAN_BLUE,), SizedBox(width: 16,), Flexible(child: Text("Your feedback has been successfuly submitted."))],
        );
      case SUBMISSION_STATES.FAILED:
        return Row(
          children: [Icon(Icons.error, color: MICHIGAN_BLUE,), SizedBox(width: 16,), Flexible(child: SelectableText("Error while submitting the feedback. Please feel free to email the feedback through my contact info on efeakinci.com/mbus"))],
        );
      case SUBMISSION_STATES.TOO_MANY_REQUESTS:
        return Row(
        children: [Icon(Icons.error, color: MICHIGAN_BLUE,), SizedBox(width: 16,), Flexible(child: SelectableText("There have been too many requests from your current network. Please try again later."))],
        );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Image.asset('assets/mbus_logo.png', height: 32,),),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Feedback", style: TextStyle(color: MICHIGAN_BLUE, fontWeight: FontWeight.w900, fontSize: 48), textAlign: TextAlign.center),
                SizedBox(height: 16,),
                CupertinoTextField(
                  placeholder: "Start typing to submit feedback.",
                  minLines: 4,
                  maxLines: 20,
                  onChanged: (String s) {
                    setState(() {
                      feedback = s;
                    });
                  },
                ),
                SizedBox(height: 32,),
                getLastFormElement()
              ],
            ),
          ),
        ),
      ),
    );
  }
}


