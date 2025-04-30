# Create an autoload for everything

Autoloads in Godot are objects that can be accessed from anywhere and there can be only one of them. They act like any other node, they can have children and render stuff to the screen, and still go through physics and idle processing.
The plan is to make every major game function its own autoload to ease testing, minimize code tangling and duplication, and make it more modular to integrate it to future changes seamlessly.

## Map Loading Handler (MapHandler)
This autoload only handles the loading and switching of maps, the maps themselves are meant to have their own code handling whatever happens in them, making use of the other autoloads to do more universally important stuff.

### Why maps should handle themselves
The reason why maps should handle everything that happens within them is to keep playtesting simple. You should be able to simply run the scene itself in Godot to test how the map feels, without complex wrapper scenes on top providing dependencies. The map loader should not even run any functions in a map after loading it, Godot has the `_ready` method for the map to use to start doing things; the loader should only be concerned with letting anything else know, via signals, that maps are changing.

## User Configuration Handler
**NOT IMPLEMENTED YET**

This autoload handles all persistent data related to the user, and should remain entirely local. Things such as control, graphical, auditorial and other settings are handled here, but also more major data like save files, achievements and unlockables, although those might have their own autoloads to handle them, and they will use this autoload for knowing what to look for.
This autoload also comes with a UI that can be activated anytime, and can even have additional settings added into them beyond just the built-in ones.

## Local Player Input and Camera Handler (LocalPlayer)
In multiplayer games, there are two sides with events happening in them: Client-side and Server-side. The Server-side handles all the important game logic, events and data. Meanwhile the Client-side handles everything that makes the game responsive and alive to the player, like the local camera, UI elements representing important data, and player input; This autoload is meant to handle everything related to the Client, but it isnt the only one that does. 

### Other local autoloads
Other autoloads that do things on the client side will exist, and they should have the prefix "Local" only if they are exclusively local, and have no remote capability (They don't have RPC functions, don't do anything with their `multiplayer` property and only use other autoloads if they need data related to remote things) .

## Loading Screen (LoadingScreen)
TODO: Rename LoadingScreen to LocalLoadingScreen

A simple autoload that simply handles the visibility, progress and text of a loading screen. Entirely local.

## Main Menu


## Pause Menu

## Entity Handler

## Projectile Handler
