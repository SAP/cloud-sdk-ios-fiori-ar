# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

## [2.0.0](https://github.com/SAP/cloud-sdk-ios-fiori-ar/compare/1.1.0...2.0.0) (2021-12-17)

### ⚠ BREAKING CHANGES

The [migration guide](https://github.com/SAP/cloud-sdk-ios-fiori-ar/wiki/FioriAR-2.0-Migration-Guide) helps you to understand the breaking changes and how to adopt them.

Maybe the most prominent breaking change is 🧨 module `FioriARKit` was renamed to `FioriAR`.

### Features

**Create AR annotations within your app and store them remotely with SAP Mobile Services**

FioriAR provides reusable views and utilities to create/update/delete scenes with AR annotations directly from your app. This is the recommended approach considering how easy it is to create and handle AR annotations.

Scene information will be stored remotely within SAP Mobile Services. As a prerequisite the feature [Mobile Augmented Reality](https://help.sap.com/viewer/468990a67780424a9e66eb096d4345bb/Cloud/en-US/81d0455bab6c4d4f99905993e1676268.html) needs to be assigned to your application in SAP Mobile Services cockpit.

See [here](https://github.com/SAP/cloud-sdk-ios-fiori-ar/tree/main#in-app-handling-relying-on-sap-mobile-services) for more information.

## [1.1.0](https://github.com/SAP/cloud-sdk-ios-fiori-ar/compare/1.0.0...1.1.0) (2021-07-08)

Has a few but easily adoptable ⚠ BREAKING CHANGES

### Features

* 🎸 Loading directly from a usdz File ([fc14e55](https://github.com/SAP/cloud-sdk-ios-fiori-ar/commit/fc14e5500cfd43756f2de9695ef3c5908008fde4))
* 🎸 Decoding JSON in RealityComposerStrategy ([#47](https://github.com/SAP/cloud-sdk-ios-fiori-ar/issues/47)) ([6c14176](https://github.com/SAP/cloud-sdk-ios-fiori-ar/commit/6c14176cf53cde882a7821ee92875a864fbbeef6))
* 🎸 Loading from Reality File and SceneLoadable ([c25ac1a](https://github.com/SAP/cloud-sdk-ios-fiori-ar/commit/c25ac1a22426157e7f650dad22ba04f5b1bf353c))
  
## [1.0.0](https://github.com/SAP/cloud-sdk-ios-fiori-ar/releases/tag/1.0.0) (2021-06-11)

- Initial release! 🎉
- Support for `AR Cards`, see README for more information
