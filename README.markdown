# NSClippy

## Clippy for iOS

NSClippy is a port of [ClippyJS](https://www.smore.com/clippy-js) for that nostalgic hit on iOS. My thanks to [smore](https://www.smore.com) for providing the original sprites and sounds.

## Screenshots

![NSClippy screenshot](Screenshot.png)

## Requirements

* Xcode 4.5 or higher
* Apple LLVM compiler
* iOS 5.0 or higher
* ARC

## How to use

Adding Clippy to your view:

```objectivec
NSClippy *clippy = [[NSClippy alloc] initWithAgent:@"clippy"];
[self.view addSubview:clippy];
[clippy show];
```
And to show an animation:

```objectivec
[clippy showAnimation:@"GetArtsy"];
```
	
## Installation

Either manually copy all the files from the NSClippy directory (excluding the Example) into your project, or you can add it via [Cocoapods](http://cocoapods.org) by putting this line into your podfile:

	pod 'NSClippy'

## Todo

* Mac support
* Show random idle animation
* Add speech bubble pop over
* Queue for animations
* Add other characters such as Merlin, Rover, and Links.
