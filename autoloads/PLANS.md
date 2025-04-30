# Create an autoload for everything

Autoloads in Godot are objects that can be accessed from anywhere and there can be only one of them. They act like any other node, they can have children and render stuff to the screen, and still go through physics and idle processing.
The plan is to make every major game function its own autoload to ease testing, minimize code tangling and duplication, and make it more modular to integrate it to future changes seamlessly.

## Map Loading Handler (MapHandler)
This autoload only handles the loading and switching of maps, the maps themselves are meant to have their own code handling whatever happens in them, making use of the other autoloads to do more universally important stuff.

## Player Data Handler
**NOT IMPLEMENTED YET**

## Local Player Input and Events Handler (LocalPlayer)

## Loading Screen (LoadingScreen)

## Main Menu

## Pause Menu

## Entity Handler

## Projectile Handler
