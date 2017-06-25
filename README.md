# iOSBoilerplate
Boilerplate iOS app for Specdrums rings, written in Objective C. Use it to make your own Specdrums iOS application. Some cool ideas to get started on:
* Good ol' Simon
* Scavenger hunt for colors
* Augmented-reality Twister
* Color blindness aid

# Getting Starte
You should start by editing code in `ViewController.h/m` and the front-end in `Main.storyboard` to suit your application.

# Working with Specdrums rings
All interactions with Specdrums rings should be done through `Specdrums.m`. It has all the methods for sending commands to and handling the Bluetooth connection of the rings. It also has delegate callbacks for handling data received by the rings via BLE. So whatever view controller you're using, make sure you assign it as a `SpecdrumsDelegate` (see `ViewController.h`). See `Specdrums.h` for all available commands and delegate methods. Altering any other classes under `Specdrums Hardware Interface` is not advised.
