
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

This project is a SwiftUI implementation of the SAP Fiori for iOS ARKit, and is meant to leverage the Augmented Reality capabilities from the frameworks provided by Apple for various Enterprise use cases.

There is currently support for `AR Cards`. This refers to Cards that match with a corresponding Marker that represent annotations relative to an image or object in the real world.

### Background

##### ARKit

A framework provided by Apple which processes and provides sensor data from the IMU for an Augmented Reality experience to work. Such as motion tracking, localizing device, session capture, and image analysis/processing. ARKit uses `ARAnchor` and it's limited subtypes (`ARPlaneAnchor`, `ARImageAnchor`, `ARObjectAnchor`) to keep track of their points of interest in the `ARSession`. For more in-depth information refer to the [ARKit Documentation.](https://developer.apple.com/documentation/arkit "ARKit Documentation.")

##### RealityKit

While ARKit handles the above it does not render any content into the scene. RealityKit is a framework and API above ARKit that follows the Entity-Component Architectural pattern. `Entity` are 3D models that can have Components or behaviors applied to them. This handles establishing a scene that 3D content and audio can be anchored to from the ARKit anchors. RealityKit has it's own notion of `AnchorEntity` that have overlapping functionality with ARKit Anchors yet with the purpose of anchoring 3D content. For more in-depth information refer to the [RealityKit Documentation.](https://developer.apple.com/documentation/realitykit/ "RealityKit Documentation.")

##### Reality Composer

Creation of Augmented Reality experiences without a visual understanding of the scene can be difficult. Hardcoding and measuring the xyz locations of content can be tedious. Reality Composer is an app for iOS and Mac with functionalities to compose AR scenes around a chosen anchor type. 3D content can be placed and given conditional actions and audio. A benefit of using this app is that the scene can be previewed in AR and edited in real time using an iOS device.

> **Note**: Reality Composer is required to scan an object when choosing an Object Anchor.

##### SwiftUI

3D content design has many challenges. It can be time consuming, expensive, require additional skills, and generates large files. 3D Content is also difficult to make dynamic changes such as animations through interaction and conditions. As a solution, instead of placing 3D content into the scene. Invisible Entities are placed as children relative to the chosen Anchor. Their locations are projected from the world scene onto the screen and SwiftUI Views are rendered at those locations.

## AR Cards

> **WARNING**: Concepts and implementation for components are `in-development` and can change at any time!!!

<p align="center">
<img src="https://user-images.githubusercontent.com/77754056/119206581-262cdb00-ba61-11eb-8a87-1e83d52d53c3.mp4" alt="alt text" height="450" align="center">
</p>

The AR Cards use case is essentially annotations represented by a marker in the real world that correspond to data displayed in a card with an optional action. There is a one to one mapping of markers to cards. After creation of a scene in reality composer and the data that's associated with those positions, they can be loaded into the content view. Supports `Image` and `Object` anchors.

### Usage

#### Reality Composer Strategy

##### Composing the scene

1. Open the Reality Composer app and create a scene with the image or object anchor
2. Choose an image or scan an object and give the scene a name e.g. ExampleScene
3. Place spheres in the desired position
4. Preview in AR to fine tune
5. Name the spheres with a type that conforms to LosslessStringConvertable
6. The name of the sphere will correspond to the `CardItemModel` ID
7. Add the rcproject file in your xcode project

> **Notes**: 
- Scanning an object requires using an iOS device in the Reality Composer app
- The spheres are for scene creation and will be invisible in the ARCards scene

<p align="center">
<img height="350" alt="rcDemo1" src="https://user-images.githubusercontent.com/77754056/119742939-784d7200-be4e-11eb-928d-6d83b07e49ff.png">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img height="350" alt="rcDemo2" src="https://user-images.githubusercontent.com/77754056/119743047-a6cb4d00-be4e-11eb-8543-4ed018fa25f3.jpeg">
</p>

##### Data Consumption

CardItem Models Conform to `CardItemComponent`. The *name* of the Entity (Sphere) from Reality Composer corresponds to the *id* property of the Model. The list of initial CardItems are passed into the `RealityComposerStrategy` with the Reality Composer rcproject File Name and the name of the scene. For an image Anchor, the image that will be detected must be passed into the strategy to create an `ARReferenceImage`.

##### Creating the ContentView and loading the data

```swift
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
        let loadingStrategy = RealityComposerStrategy(cardContents: cardItems, anchorImage: anchorImage, physicalWidth: 0.1, rcFile: "ExampleRC", rcScene: "ExampleScene")
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

**FioriARKit** as umbrella product currently will contain everything the package as to offer. As the package evolves the package could be split into multiple products for different use cases.

## Limitations

The module is currently in development, and should not yet be used productively. Breaking changes may occur in 0.x.x release(s)

Key gaps which are present at time of open-source project launch:
- An authoring flow for pinning/editing an annotation in app
- An Annotation Loading Strategy which loads an array of positions for annotations relative to the detected image/object
- While Reality Composer is useful for scene creation, editing the scene programmatically is possible, but those changes cannot be saved to the file

## Known Issues

See **Limitations**.

## How to obtain support

Support for the modules is provided thorough this open-source repository. Please file Github Issues for any issues experienced, or questions.  

## Contributing

If you want to contribute, please check the [Contribution Guidelines](./CONTRIBUTING.md)

## To-Do (upcoming changes)

See **Limitations**.

## Examples

Functionality can be further explored with a demo app which is already part of this package (`Apps/Examples/Examples.xcodeproj`).


