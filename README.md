## AppConnectSwift

AppConnectSwift is an example iOS app, written in Swift, that showcases proper usage of the AppConnect SDK. The functionality of AppConnect is contained within a library called Babbage, an homage to the [father of the computer](https://en.wikipedia.org/wiki/Charles_Babbage).

### Prequesites

If you are running this application, it is assumed that:

- You were provided Artifactory credentials by a Medidata representative
- You have a valid Rave installation with Patient Cloud functionality enabled
- You were provided a CRF to recreate the form used in this example app

### Setup

AppConnect is packaged as a [CocoaPod](https://cocoapods.org/) to ease installation and usage. To properly access the AppConnect pod, you must have credentials for the Artifactory repository where the library is hosted. Set the following environment variables based on the credentials you were provided:


    export ARTIFACTORY_USERNAME=providedusername
    export ARTIFACTORY_PASSWORD=providedpassword


Once the variables have been set, run `pod install` to install the necessary dependencies. When the CocoaPods have finished installing, open `AppConnectSwift.xcworkspace` and click "Run." The app should build and run successfully.

### Architecture

The application contains the following important view controllers

- **LoginViewController**: handles user authenticated based on a provided username / password
- **FormListViewController**: loads and displays the available forms for the authenticated user
- **OnePageFormViewController**: loads and displays a form on a single screen, providing validation before form submission
- **MultiPageFormViewController**: loads and displays a form one field at a time, using the FieldViewController to display the individual fields
