This is the dedicated user configuration autoload and interface.
Designed to be as dynamic and easy to use as possible, utilizing some of Godot's magic with nodes to save data.

## The IndieConfig node
This node is the dedicated node holding it all.

To use it, start by extending from it with a you own script. Then, in the `_enter_tree` method, put all the `add_config_*` methods to create all the configurations you need.
After that, to save data, simply save the node that has your new script to hard drive as a scene.
