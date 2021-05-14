# **SAP Fiori for iOS ARKit**

***
### Summary

This project is a SwiftUI implementation of the SAP Fiori for iOS ARKit, and is meant to leverage the Augmented Reality capabilities from the frameworks provided by Apple for various Enterprise use cases.

There is currently support for `AR Cards`. This refers to Cards that match with a corresponding Marker that represent annotations relative to an image or object in the real world.

### Background

##### ARKit

A framework provided by Apple which processes and provides sensor data from the IMU for an Augmented Reality experience to work. Such as motion tracking, localizing device, session capture, and image analysis/processing. ARKit uses ARAnchor and it's limited subtypes (ARPlaneAnchor, ARImageAnchor, ARObjectAnchor) to keep track of their points of interest in the ARSession. For more in-depth information refer to the [ARKit Documentation.](https://developer.apple.com/documentation/arkit "ARKit Documentation.")

##### RealityKit

While ARKit handles the above it does not render any content into the scene. RealityKit is a framework and API above ARKit that follows the Entity-Component Architectural pattern. Entities are 3D models that can have Components or behaviors applied to them. This handles establishing a scene that 3D content and audio can be anchored to from the ARKit anchors. RealityKit has it's own notion of AnchorEntities that have overlapping functionality with ARKit Anchors yet with the purpose of anchoring 3D content. For more in-depth information refer to the [RealityKit Documentation.](https://developer.apple.com/documentation/realitykit/ "RealityKit Documentation.")

##### Reality Composer

Creation of Augmented Reality experiences without a visual understanding of the scene can be difficult. Hardcoding and measuring the xyz locations of content can be tedious. Reality Composer is an app for iOS and Mac with functionalities to compose AR scenes around a chosen anchor type. 3D content can be placed and given conditional actions and audio. A benefit of using this app is that the scene can be previewed in AR and edited in real time using an iOS device.

> **Note**: Reality Composer is required to scan an object when choosing an Object Anchor.

##### SwiftUI

3D content design has many challenges. It can be time consuming, expensive, require additional skills, and generates large files. 3D Content is also difficult to make dynamic changes such as animations through interaction and conditions. As a solution, instead of placing 3D content into the scene. Invisible Entities are placed as children relative to the chosen Anchor. Their locations are projected from the world scene onto the screen and SwiftUI Views are rendered at those locations.

## AR Cards

<p align="center">
<img src="media/carEngineGif.gif" alt="alt text" width="296" height="640" align="center">
</p>

> **WARNING**: Concepts and implementation for components are `in-development` and can change at any time!!! 

The AR Cards use case is essentially annotations represented by a marker in the real world that correspond to data displayed in a card. There is a one to one mapping of markers to cards. After creation of a scene in reality composer and the data that's associated with those positions, they can be loaded into the content view. Supports `Image` and `Object` anchors.

|  Annotation Authoring | Definition |  Supported |
| :---------------- | :--------------- | :------------: |
| Initially Loaded         |  Strategy which loads annotations with pre-defined locations and data before the Image/Object Anchor is discovered. Upon discovery the annotations are loaded into the scene. Supports a Reality Composer Strategy.                              | :white_check_mark:  |
| User Edited in App   |  After the Image/Object is discovered, an editing mode to edit the current marker's locations and respective card's content. Adding and Removing new anchors with defined content.      | In Development |
| Automated               |   An Point of Interest is automatically discovered and added to the scene. A hypothetical example, Vision Framework Model can detect a compliant Image in the capture session and then add it to the AR Scene as an Image Anchor with a respective Card/Marker. | In Development |

### Usage

##### With Reality Composer Strategy: Composing the scene

1. Open the Reality Composer app and create a scene with the desired anchor
2. Place spheres in the desired position and preview in AR to fine tune
3. Name the spheres with a type that conforms to LosslessStringConvertable
4. Save the rcproject file in your xcode project

> **Note**: The spheres will be invisible in the scene

##### Data Consumption

CardItem Models Conform to CardItemComponent. The *name* of the Entity (Sphere) from Reality Composer corresponds to the *id* property of the Model. The list of initial CardItems are passed into the RealityComposerStrategy with Reality Composer File Name and the name of the scene.

##### Creating the ContentView and loading the data

```swift
struct FioriARKitCardsExample: View {
    @StateObject var arModel = ARAnnotationViewModel<ExampleCardModel>()
    
    var body: some View {
        
        SingleImageARCardView(arModel: arModel, image: Image("qrImage"), cardAction: { id in
            // action to pass to corresponding card from the CardItemModel ID
		})
		.onAppear(perform: loadInitialData)
    }

    func loadInitialData() {
        let cardItems = NetworkMockup.fetchData()
        let loadingStrategy = RealityComposerStrategy(cardContents: cardItems, rcFile: "RealityComposerFileName", rcScene: "SceneName")
        arModel.load(loadingStrategy: loadingStrategy)
    }
}
```
## Requirements

- iOS 14 or higher
- Xcode 12 or higher
- Reality Composer 1.1 or higher
- Swift Package Manager

## Download and Installation

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

