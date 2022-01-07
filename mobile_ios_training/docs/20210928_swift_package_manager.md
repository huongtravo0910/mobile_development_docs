# SWIFT PACKAGE MANAGER

## WHAT

A package manager is a tool that automates the process of installing, upgrading, configuring, and removing a software, or in this case, inside our app.

(https://www.codementor.io/blog/swift-package-manager-5f85eqvygj)



| Types of package managers       | Swift Package management     | CocoaPods    | Carthage    | 
| :------------- | :---------- | :----------- |:----------- |
| **Advantages** |  <br> - Build with Swift <br> - By Apple <br> - Automatically manage a dependency’s dependencies. If a dependency relies on another dependency, Swift Package Manager will handle it for you. <br> - Anyone inside the project will easily know what dependencies your app is using.  |  - A centralized dependency manager for Swift and Objective-C Cocoa projects <br> - Build with Ruby <br> - By community <br> -  Can search for a dependency on the official CocoaPods website.<br> - Automatically manage a dependency’s dependencies. If a dependency relies on another dependency, CocoaPods will handle it for you. <br> - It's easy to check if a new version of a dependency is available by using the command pod outdated <br> - If the dependency supports it, you can try the dependency before integrating it into your project by using the command   `pod try ...`  <br> - Every framework supports Carthage.|-  A decentralized dependency manager for Swift and Objective-C Cocoa projects <br> - Build with Swift <br> - By community <br> - Automatically manage a dependency’s dependencies. If a dependency relies on another dependency, CocoaPods will handle it for you. <br> - It's easy to check if a new version of a dependency is available by using the carthage outdated command. <br> - Project builds faster in comparison to CocoaPods as Carthage only builds the frameworks once (when you call the carthage update or carthage bootstrap command). <br> - Your project remains untouched since you will only add frameworks and a new build phase.|
| **Disadvantages**  | - It is compatible with Swift 5 and Xcode 11 <br/> - Below Xcode 11, SPM is supported only for mac and linux (since Swift 3) | - Have to wait a long time the first time you install your dependencies or update with `pod update` <br> - Every time you build your project, all your dependencies will also be built, which leads to slower build times. <br> - Hard to remove once it’s integrated <br> - CocoaPods changes the project structure. Takes time to understand the structure|- Not every framework supports Carthage. <br> - Carthage only works with dynamic frameworks. It doesn’t work with static libraries.|

## WHY
With a package manager, we can easily manage dependencies inside your software.

## HOW
### 1. **Swift Package management**
 
#### a. How to create

#### b. How to import into a project




### 2. **CocoaPods**

#### a. How to create

#### b. How to import into a project

### 3. **Carthage**
 
#### a. How to create

#### b. How to import into a project
