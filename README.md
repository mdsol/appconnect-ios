## AppConnectSwift

AppConnectSwift is an example iOS app, written in Swift, that showcases proper usage of the AppConnect SDK. The functionality of AppConnect is contained within a library called Babbage, an homage to the [father of the computer](https://en.wikipedia.org/wiki/Charles_Babbage).

### Prequesites

If you are running this application, it is assumed that:

- You were provided Artifactory credentials by a Medidata representative
- You have a valid Rave installation with Patient Cloud functionality enabled
- You were provided a CRF to recreate the form used in this example app

### Setup

The Babbage library is packaged as a [CocoaPod](https://cocoapods.org/) to ease installation and usage. To properly access the Babbage pod, you must have credentials for the Artifactory repository where the library is hosted. Set the following environment variables based on the credentials you were provided:


    export ARTIFACTORY_USERNAME=providedusername
    export ARTIFACTORY_PASSWORD=providedpassword


Once the variables have been set, run `pod install` to install the necessary dependencies. When the CocoaPods have finished installing, open `AppConnectSwift.xcworkspace` and click "Run." The app should build and run successfully.

### Architecture

The application contains the following important view controllers

- **LoginViewController** - Handles user authentication based on a provided username / password.
- **FormListViewController** - Loads and displays the available forms for authenticated users.
- **OnePageFormViewController** -  Loads and displays a form on a single screen, providing validation before users submit forms.
- **MultiPageFormViewController** - Loads and displays a form one field at a time. Uses the FieldViewController to display the fields.
- **ReviewController** - Allows user to review their answers before submitting forms.

### Using the Case Report Form (CRF)

The AppConnect SDK comes with a sample CRF - SampleCRF.xls - that contains the two forms used in the sample app.

To use this sample form:

1. Import the linked CRF into Rave for a subject of your choosing.
2. Log in with the sample app using the credentials of the subject you chose.
> You should see two forms, Form 1 and Form 2. The former is hardcoded to open as a one-page form. The latter will open as a multi-page form.
