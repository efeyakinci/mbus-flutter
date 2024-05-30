# Getting Started

## Building MBus

### Prerequisites

1. **Install Flutter**:
   Follow the instructions on the [official Flutter website](https://docs.flutter.dev/get-started/install) to install Flutter on your machine.

2. **Install Dart**:
   Dart comes with Flutter, but make sure you have the latest version. You can check the version with:
   ```bash
   dart --version
   ```

### Installing Dependencies

Before building the project, you need to install the required dependencies.

1. Navigate to the project directory:
   ```bash
   cd path/to/your/mbus/project
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```


### Functional Widgets

MBus uses flutter_functional_widget to write new widgets. This package works by using the build_runner dependency to generate the widget code.

To build the project, first run:

```bash
dart run build_runner watch 
```

This will generate the necessary .g.dart files for the project. Do not edit or commit these files.

### Google Maps SDK

To use the Google Maps SDK, you will need to create a new project on the Google Cloud Platform and enable the Maps SDK for Android and iOS.

To set your keys for Android, (create and) edit the `local.properties` file in the `android` directory and define a `googlemaps.apiKey` property with your API key.

To set your keys for iOS, create the `gmap.xcconfig` file in `ios/Flutter` and define a `GMAP_API_KEY` property with your API key for the Google Maps SDK.

### Backend Configuration

To set the backend URL, add `--dart-define=BACKEND_URL=<URL>` to the `flutter run` arguments.

## Running the project

To run the project, use the following command:

```bash
flutter run
```