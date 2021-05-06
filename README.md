<!--
SPDX-FileCopyrightText: 2021 2020 SAP SE or an SAP affiliate company and cloud-sdk-ios-fioriarkit contributors

SPDX-License-Identifier: Apache-2.0
-->

## **SAP Fiori for iOS ARKit**

***
This project is a SwiftUI implementation of the SAP Fiori for iOS ARKit, and is meant to leverage the Augmented Reality capabilities from the frameworks provided by Apple for various Enterprise use cases.

This project currently contains support for `AR Cards` corresponding to annotations relative to an image or object in the real world. Future use cases include Indoor Navigation.

###Background

##### ARKit

A framework provided by Apple which processes and provides sensor data from the IMU for an Augmented Reality experience to work. Such as motion tracking, localizing device, camera capture, and image analysis/processing.

##### RealityKit

While ARKit handles the above it does not render any content into the scene. RealityKit is a framework that follows the Entity-Component Architectural pattern. This handles establishing a scene that 3D content and audio can be anchored to.

##### Reality Composer

Creation of Augmented Reality experiences without a visual understanding of the scene can be difficult. Reality Composer is an app for iOS and Mac with functionalities to compose AR scenes around a chosen anchor type. 3D content can be placed and given conditional actions and audio. A benefit of using this app is that the scene can be previewed in AR and edited in real time using an iOS device.

> **Note**: Reality Composer is required to scan an object when choosing an Object Anchor.

##### SwiftUI

3D content design has many challenges. It can be time consuming, expensive, require additional skills, and generates large files. 3D Content is also difficult to make dynamic changes such as animations through interaction and conditions. As a solution, instead of placing 3D content into the scene. Invisible anchors are placed as children relative to the chosen achor. Their locations are projected from the world scene onto the screen and SwiftUI Views are rendered at those locations.

## AR Cards

> **WARNING**: Concepts and implementation for components is `in-development` and can change at any time!!! 

The AR Cards use case is essentially annotations represented by a marker in the real world that correspond to data displayed in a card. There is a one to one mapping of markers to cards. After creation of an scene in reality composer and the data thats associated with those positions they can be loaded into the content view. Supports `Image` and `Object` anchors.

### Usage

#####Composing the scene
1. Open the Reality Composer app and create a scene with the desired anchor
2. Place spheres in the desired position and preview in AR to fine tune
3. Name the spheres starting from 0

#####Data Consumption
Models Conform to CardItemComponent. The name of the entity from Reality Composer corresponds to the id of the Model

#####Creating the ContentView and loading the data
```swift
struct FioriARKitCardsExample: View {
    @StateObject var arModel = ARAnnotationViewModel<DeveloperCardModel>()
    
    var body: some View {
        
        ARAnnotationContentView(arModel: arModel, image: Image("qrImage"), cardAction: { id in
            // action to pass to corresponding card from the CardItemModel ID
		})
		.onAppear(perform: loadData)
    }

    func loadData() {
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

Support for the modules is provided thorough this open-source repository.  Please file Github Issues for any issues experienced, or questions.  

## Contributing

If you want to contribute, please check the [Contribution Guidelines](./CONTRIBUTING.md)

## To-Do (upcoming changes)

See **Limitations**.

## Examples

Functionality can be further explored with a demo app  which is already part of this package (`Apps/Examples/Examples.xcodeproj`).

