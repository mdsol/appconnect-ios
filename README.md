## AppConnectSwift

AppConnectSwift is an example iOS app, written in Swift, that showcases proper usage of the AppConnect SDK. The functionality of AppConnect is contained within a library called Babbage, an homage to the [father of the computer](https://en.wikipedia.org/wiki/Charles_Babbage).

>See [Medidata AppConnect Home](https://learn.mdsol.com/display/APPCONNECTprd/Medidata+AppConnect+Home) for more information. 

### Prerequisites

If you are running this application, it is assumed that:

- You were provided Artifactory credentials by a Medidata representative.
- You have a valid Rave installation with Patient Cloud functionality enabled.

>You also need permission to access Rave studies and sites. If you do not have these permissions, contact your Medidata representative for more information.

### Setup

The Babbage library is packaged as a [CocoaPod](https://guides.cocoapods.org/using/getting-started.html) to ease installation and usage. To properly access the Babbage pod, you must have credentials for the Artifactory repository where the library is hosted. Set the following environment variables based on the credentials you were provided:

```bash
    export ARTIFACTORY_USERNAME=providedusername
    export ARTIFACTORY_PASSWORD=providedpassword
```


Once the variables have been set, run `pod install` to install the necessary dependencies. When the CocoaPods have finished installing, open `AppConnectSwift.xcworkspace` and click "Run." The app should build and run successfully.

### Architecture

The application contains the following important view controllers

- **LoginViewController** - Handles user authentication based on a provided username / password.
- **FormListViewController** - Loads and displays the available forms for authenticated users.
- **OnePageFormViewController** -  Loads and displays a form on a single screen, providing validation before users submit forms.
- **MultiPageFormViewController** - Loads and displays a form one field at a time. Uses the FieldViewController to display the fields.
- **CaptureImageViewController** - Loads a form for taking pictures with device camera, upload an image from photo library and save it to S3.
- **ReviewController** - Allows user to review their answers before submitting forms.

### Using the Case Report Form (CRF)

The AppConnect SDK comes with a sample CRF - SampleCRF.xls - that contains the two forms used in the sample app.

To use this sample form:

1. Import the linked CRF into Rave for a subject of your choosing.
2. Log in with the sample app using the credentials of the subject you chose.

> You should see two forms, Form 1 and Form 2. Form 1 opens as one page. Form 2 opens as multiple pages.

# Using the API in your own application #

This is a guide to the basics of Babbage - intialization, making network requests, and loading data from the datastore.

## Installation
To install Babbage, include it in your Podfile:

Using the credentials provided to you, run the following command to install the Babbage Cocoapod:

```bash
ARTIFACTORY_USERNAME=myusername ARTIFACTORY_PASSWORD=mypassword pod install
```

## Initialization
In Swift / Objective-C, Babbage must be initialized with two arguments. The first is a directory in which to store data. The second is a 32-byte key used to encrypt sensitive information. This key must be unique for each installation, and remain the same on each launch.

```swift
// In AppDelegate.swift
let dir = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask).last
let key = "12345678901234567890123456789012".dataUsingEncoding(NSUTF8StringEncoding)
MDBabbage.startWithDatastoreAtURL(dir, encryptionKey: key)
```

## Loading Data from the Datastore
You can store and retrieve persistent data using the Datastore class.

```swift
let datastore = MDDatastoreFactory.create()
let user = datastore.userWithID(Int64(self.userID))
```

>**Important Considerations:** 
  - Although there can be multiple Datastore instances, they are all communicating with the same persistent store (a local SQlite database).
  - Datastore instances are not thread-safe. If you are creating a new thread - perhaps to make a network request asynchronously - then you should create a new Datastore to accompany it.
  - Instances loaded from a Datastore are not thread-safe. Instead of passing an instance to a separate thread, pass the instance's ID - for example, Java: `user.getID()`, Swift: `user.objectID` - and use a separate Datastore to load the instance.


## Network Requests
Babbage talks to back-end services to retrieve all information, such as users, subjects, forms, and so on. A normal application flow goes something like this:

1. Log in using a username / password 
2. Load subjects for the logged in user
3. Load forms and present them to the user

The following code replicates this process:
```swift
client.logIn(username, inDatastore: datastore, password: password) { (user: MDUser!, error: NSError!) -> Void in
  client.loadSubjectsForUser(user) { (subjects: [AnyObject]!, error: NSError!) -> Void in
    client.loadFormsForSubject(subjects.first!) { (forms: [AnyObject]!, error: NSError!) -> Void in
      ...
    }
  }
}
```

>**Important Considerations:** 
  - The preceding example assumes the user is associated with a single subject. In reality they may have multiple subjects associated with them.
  - The example assumes a best-case scenario where each request is successful. A robust application should have adequate error handling throughout the process.
  - To avoid interfering with the UI, make all requests asynchronously on a background thread.


### Documentation ###

Please refer to the documentation for detailed instruction on how to use the various APIs.
