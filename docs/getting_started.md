This is a guide to the basics of Babbage - intialization, making network requests, and loading data from the datastore.

## Installation
To install Babbage, include it in your Podfile:

Using the credentials provided to you, run the following command to install the Babbage Cocoapod:

```bash
ARTIFACTORY_USERNAME=myusername ARTIFACTORY_PASSWORD=mypassword pod install
```

## Initialization
In Swift / Objective-C, Babbage must be initialized with two arguments. The first is a directory in which to store data. The second is a 32-byte key used to encrypt sensitive information. This key must be the same for all builds of the app.

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

### Important Considerations
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
  client.loadSubjectsForUser(user, inDatastore: datastore) { (subjects: [AnyObject]!, error: NSError!) -> Void in
    client.loadFormsForSubject(subjects.first!, inDatastore: datastore) { (forms: [AnyObject]!, error: NSError!) -> Void in
      ...
    }
  }
}
```

### Important Considerations
- The preceding example assumes the user is associated with a single subject. In reality they may have multiple subjects associated with them.
- The example assumes a best-case scenario where each request is successful. A robust application should have adequate error handling throughout the process.
- To avoid interfering with the UI, make all requests asynchronously on a background thread.

