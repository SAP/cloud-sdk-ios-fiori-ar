# Examples Application

You can explore FioriAR's functionality with this iOS application.

By running the app and studying its source code you will understand
- how to view a scene by loading a `.rcproject`, `.reality` or `.usdz` bundled as part of the application
- how to create/update and view a scene stored remotely in SAP Mobile Services (subscription necessary)

For this you need to adjust the values of `IntegratonTest` related enums located in `Tests.swift` file.

```swift
enum IntegrationTest {
    enum System {
        static let clientID = "<Example: 011ff655-e717-4660-8e50-ea8efd65f0c5>"
        static let authURL = "<Example: https://157dd9actrial-dev-com-example-sample.cfapps.us10.hana.ondemand.com/oauth2/api/v1/authorize>"
        static let redirectURL = "<Example: https://157dd9actrial-dev-com-example-sample.cfapps.us10.hana.ondemand.com>"
        static let tokenURL = "<Example: https://157dd9actrial-dev-com-example-sample.cfapps.us10.hana.ondemand.com/oauth2/api/v1/token>"
    }

    enum TestData {
        static let sceneId = 20110991
        static let sceneAlias = "myOwnAlias"
    }
}
```

You can find system related information the "Security" tab of your application in SAP Mobile Services.

<img width="1521" alt="MobileServicesOAuthClient" src="https://user-images.githubusercontent.com/4176826/146615888-76040348-1d81-490b-8019-c38640f07475.png">

You can test data related information in "Mobile Augmented Reality" feature of your applicaton in SAP Mobile Services once test data was created by you.

<img width="1571" alt="MobileServicesAugmentedReality" src="https://user-images.githubusercontent.com/4176826/146616151-409dd08a-4cbb-403c-aaa8-5115b0f0a7b4.png">
