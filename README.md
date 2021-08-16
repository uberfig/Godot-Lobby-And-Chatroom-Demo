This project is just the lobby system from the Bomberman demo made to be plug-and-play to aid in learning Godot's networking capabilities

Plug-And-play
------

To use this in your own projects you just need to copy the lobby file into your project's file, then make gamestate.gd a singleton. You can then change the scene gamestate.gd instances in the start game function with your project's main scene 

Project flow
------

This project uses the gamestate.gd singleton to look after hosting and joining games, as well as switching from the lobby scene to the chatroom scene when hosting a game and freeing the chatroom scene and switching back to the lobby when a game is ended or the server is disconnected
