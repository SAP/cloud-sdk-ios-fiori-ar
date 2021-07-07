
<p align="center">
  </br>
  <span><b>SAP Fiori for iOS ARKit</b></span>
</p>

***

<div align="center">
    <a href="https://github.com/SAP/cloud-sdk-ios-fioriarkit#installation">Installation
    </a>
    |
    <a href="https://github.com/SAP/cloud-sdk-ios-fioriarkit#examples"> Examples
    </a>
    |
    <a href="https://sap.github.io/cloud-sdk-ios-fioriarkit"> API Documentation
    </a>
	|
    <a href="https://github.com/SAP/cloud-sdk-ios-fioriarkit/blob/main/CHANGELOG.md"> Changelog
    </a>
</div>

***

<div align="center">
    <a href="https://github.com/SAP/cloud-sdk-ios-arkit/actions?query=workflow%3A%22CI%22">
        <img src="https://github.com/SAP/cloud-sdk-ios-fioriarkit/workflows/CI/badge.svg"
             alt="Build Status">
    </a>
    <a href="https://conventionalcommits.org">
        <img src="https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg"
             alt="Conventional Commits">
    </a>
    <a href="http://commitizen.github.io/cz-cli/">
        <img src="https://img.shields.io/badge/commitizen-friendly-brightgreen.svg"
             alt="Commitizen friendly">
    </a>
    <a href="https://api.reuse.software/info/github.com/SAP/cloud-sdk-ios-fioriarkit">
        <img src="https://api.reuse.software/badge/github.com/SAP/cloud-sdk-ios-fioriarkit"
             alt="REUSE status">
    </a>
</div>

***
### Summary

This project is a SwiftUI implementation of the Augmented Reality (AR) patterns in the [SAP Fiori for iOS Design Guidelines](https://experience.sap.com/fiori-design-ios/).

Currently supported:
- [AR Annotations](https://experience.sap.com/fiori-design-ios/article/ar-annotations/)

## AR Annotations

https://user-images.githubusercontent.com/77754056/121744202-2ea88c80-cac8-11eb-811d-9c9edb6423fa.mp4

Annotations refer to [Cards](https://experience.sap.com/fiori-design-ios/article/ar-cards/) that match with a corresponding [Marker](https://experience.sap.com/fiori-design-ios/article/ar-marker/) located relative to an image or object in the real world. To view annotations in the world view, the user scans the image / object with the [AR Scanner](https://experience.sap.com/fiori-design-ios/article/ar-annotations/#ar-scanner).

3D modeling is not required to represent AR annotations as the respective controls (`ARScanView`, `MarkerView` and `CardView`) are implemented with SwiftUI in this package.

An app developer needs to provide a scene of markers relative to an `Image` or `Object` anchor. Such scene creation is possible with Apple's [Reality Composer](https://developer.apple.com/augmented-reality/tools/) tool.

Depending on how the scene is stored (`rcproject`, `.reality` or `.usdz` files) the app developer has to specify an appropiate loading strategy to populate the scene and the associated card data.

Cards support SwiftUI [ViewBuilder](https://developer.apple.com/documentation/swiftui/viewbuilder) to allow custom design.

### Usage

#### Reality Composer Strategy

##### Composing the scene

1. Open the Reality Composer app and create a scene with an image or object anchor
2. Choose an image or scan an object and give the scene a name e.g. ExampleScene
3. Place spheres in the desired position
4. Preview in AR to fine tune
5. Name the spheres with a type that conforms to LosslessStringConvertable
6. The name of the sphere will correspond to the `CardItemModel` ID
7. Add the rcproject file in your xcode project

> **Notes**:
- Reality Composer is required to scan an object when choosing an Object Anchor.
- Scanning an object requires using an iOS device in the Reality Composer app
- The spheres are for scene creation and will be invisible in the ARCards scene

<p align="center">
<img height="400" alt="rcDemo1" src="https://user-images.githubusercontent.com/77754056/119742939-784d7200-be4e-11eb-928d-6d83b07e49ff.png">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img height="400" alt="rcDemo2" src="https://user-images.githubusercontent.com/77754056/119743047-a6cb4d00-be4e-11eb-8543-4ed018fa25f3.jpeg">
</p>

##### Data Consumption

CardItem Models Conform to `CardItemComponent`. The *name* of the Entity (Sphere) from Reality Composer corresponds to the *id* property of the Model. The list of initial CardItems are passed into the `RealityComposerStrategy` with the Reality Composer rcproject File Name and the name of the scene. For an image Anchor, the image that will be detected must be passed into the strategy to create an `ARReferenceImage`.

##### Creating the ContentView and loading the data

```swift
import FioriARKit

struct FioriARKitCardsExample: View {
    @StateObject var arModel = ARAnnotationViewModel<ExampleCardModel>()
    
    var body: some View {
    /**
     Initializes an AR Experience with a Scanning View flow with Markers and Cards upon anchor discovery

     - Parameters:
        - arModel: The View Model which handles the logic for the AR Experience
        - image: The image which will be displayed in the Scanning View
        - cardAction: Card Action
    */
        SingleImageARCardView(arModel: arModel, image: Image("qrImage"), cardAction: { id in
            // action to pass to corresponding card from the CardItemModel ID
        })
        .onAppear(perform: loadInitialData)
    }

    func loadInitialData() {
        let cardItems = [ExampleCardModel(id: "WasherFluid", title_: "Recommended Washer Fluid"), ExampleCardModel(id: "OilStick", title_: "Check Oil Stick")]
        guard let anchorImage = UIImage(named: "qrImage") else { return }
        let loadingStrategy = RealityComposerStrategy(cardContents: cardItems, anchorImage: anchorImage, physicalWidth: 0.1, rcFile: "realityComposerFileName", rcScene: "sceneName")
        arModel.load(loadingStrategy: loadingStrategy)
    }
}
```
## Requirements

- iOS 14 or higher
- Xcode 12 or higher
- Reality Composer 1.1 or higher
- Swift Package Manager

## Installation

The package is intended for consumption via Swift Package Manager.  

 - To add to your application target, navigate to the `Project Settings > Swift Packages` tab, then add the repository URL.
 - To add to your framework target, add the repository URL to your **Package.swift** manifest.

In both cases, **xcodebuild** tooling will manage cloning and updating the repository to your app or framework project.

## Configuration

**FioriARKit** as umbrella product currently will contain everything the package has to offer. As the package evolves the package could be split into multiple products for different use cases.

## Limitations

Key gaps which are present at time of open-source project launch:
- An authoring flow for pinning/editing an annotation in app
- An Annotation Loading Strategy which loads an array of positions for annotations relative to the detected image/object
- While Reality Composer is useful for scene creation, editing the scene programmatically is possible, but those changes cannot be saved to the file

## Known Issues

See **Limitations**.

## How to obtain support

[Create a GitHub issue](https://github.com/SAP/cloud-sdk-ios-fioriarkit/issues/new/choose) to create bug report, file a feature request or ask a question.

## Contributing

If you want to contribute, please check the [Contribution Guidelines](./CONTRIBUTING.md)

## To-Do (upcoming changes)

See **Limitations**.

## Examples

Functionality can be further explored with a demo app which is already part of this package (`Apps/Examples/Examples.xcodeproj`).
