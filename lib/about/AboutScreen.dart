import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mbus/constants.dart';

const TITLE_STYLE = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: MICHIGAN_BLUE);
const TERMS_AND_CONDITIONS = "M-Bus or UM Transit APIs are not responsible or liable for any viruses or other contamination of your system or for any delays, inaccuracies, errors or omissions arising out of your use of the application or with respect to the material contained on the application, including without limitation, any material posted on the application. This application and all materials contained on it are distributed and transmitted \"as is\" without warranties of any kind, either express or implied, including without limitation, warranties of title or implied warranties of merchantability or fitness for a particular purpose. M-Bus or UM Transit are not liable for any actual, special, indirect, incidental or consequential damages that may arise from the use of, or the inability to use, the application and or the materials contained on the application whether the materials contained on the application are provided by the M-Bus, UM Transit, or a third party.\n\nTerms of use adapted from UM Magic Bus Terms of Use at https://mbus.ltp.umich.edu/terms-use";
const PRIVACY_POLICY = "This section details the user data M-Bus collects and how the data are used and treated.\n\nM-Bus as an entity does not store or collect any information about you. However, M-Bus utilizes the University of Michigan Magic Bus API, which does collect some information about you. As the Magic Bus Terms of Service state, \"We automatically collect and store technical information about your visit to our site including: (1) the name of the domain and host from which you access the Internet; (2) the type of browser software and operating system used to access our site; (3) the date and time you access our site; and (4) the pages you visit on our site. The technical information collected will not personally identify you. We also store technical information that we collect through cookies and log files to create a profile of our customers. The profile information is used to improve the content of the site, to perform a statistical analysis of use of the site and to enhance use of the site. Technical information stored in a profile will not be linked to any personal information provided to us through your other use of our websites.\"\n\nPlease refer to the U-M Magic Bus Terms of Service at https://mbus.ltp.umich.edu/terms-use for the latest versions of the U-M Magic Bus documents.\n\nAdditionally, M-Bus provides your location to Google Maps SDK to display your location on the map. Information about how Google Maps handles your data can be located at http://www.google.com/policies/privacy";

class TermsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return (
    Scaffold(
      appBar: AppBar(title: Image.asset('assets/mbus_logo.png', height: 32,),),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text("Terms of Use", style: TITLE_STYLE,),
                SizedBox(height: 8,),
                SelectableText(TERMS_AND_CONDITIONS),
                SizedBox(height: 24,),
                Text("Privacy Policy", style: TITLE_STYLE,),
                SizedBox(height: 8,),
                SelectableText(PRIVACY_POLICY),
                SizedBox(height: 24),
                CupertinoButton(child: Text("Go Back"), onPressed: Navigator.of(context).pop)
              ],
            ),
          ),
        ),
      )
    )
    );
  }
}