# Create an autoload for everything

Autoloads in Godot are objects that can be accessed from anywhere and there can be only one of them. They act like any other node, they can have children and render stuff to the screen, and still go through physics and idle processing.
The plan is to make every major game function its own autoload to ease testing, minimize code tangling and duplication, and make it more modular
