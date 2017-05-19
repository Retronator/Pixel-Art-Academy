# Lands of Illusions Adventure Script

Adventure Script is the language used to write interactions in the world of Lands of Illusions.

## Syntax
  
### Nodes

#### Script

    # script id

`Script` node that defines the id under which the root node is exported.

#### Label

    ## label name

`Label` node which you can jump to from other nodes.

#### Callback
    
    ### callback name

`Callback` node which calls back into game code and waits until resumed.

#### Narrative

    > narrative line

`NarrativeLine` node that describes what is happening.

#### Dialog

    actor name: dialog line

or

    actor name:
        dialog line 1
        dialog line 2

`DialogLine` node that an actor delivers.

#### Choice

    * dialog line -> [label name]

`Choice` node with a `DialogLine` node that the player can decide between. 
If choice is taken, script continues to given `Label`. (see `Jump` node below).

#### Code

    `javascript expression`

`Code` node that gets executed and potentially writes to the game state.

#### Timeout
    `wait number`
    
`Timeout` node that waits the provided number of milliseconds before continuing.

### Modifiers

#### Conditionals

    any line `javascript condition`

Include the preceding node only if condition evaluates to a truthy value.

#### Jump

    any line -> [label name]

or

    -> [label name]

Jump to the `Label` node after this node (instead of following through 
to the node below in the script).

### Comments

You can use html syntax to add in comments.

    <!-- Just hanging out here. -->

### String interpolation

You can insert any variables into text lines with the code syntax. Make sure
the code snippet is not at the end though since it will be treated as a conditional instead.

    Hello world, `user.profile.name`.

### Code variables

#### Context

The code gets executed in script's context. The variable values here are 
known as script state and each script has their own namespace (the name
of the root Script node).

If you want a variable to be available everywhere, you can store it in the global
game state which can be accessed with the `@` sign.

    @happy = true

`@happy` will be `true` across scripts while `happy` would hold true only in this script's code.

Note that you should use the namespace that's as restrictive as it can be to store the value.
For example, a variable that needs to be the same across all scripts from episode 0 would have
the address `@scripts.PixelArtAcademy.Season1.Episode0`.

There are some special variables that provide other contexts:

* `this`: Parent object of the script, usually a thing with same ID as the script.
* `<thing shorthand>`: Thing objects provided with the `setThings` method on the script.
* `location`: The state of the current location you're at.
* `@user`: The logged in user's state. It's null when not logged in.
* `@user.name`: A read-only variable with user's account name.
* `@user.itemKeys`: A read-only map of catalog keys that this user has purchased.
* `@player.inventory`: A map of items in your inventory.
* `@scripts`: All script states, addressable by script ID.
* `@things`: All thing states, addressable by thing ID.

#### Persistence

Script state is persistent by default. You can use the `_` sign before
variable names to address a variable that will be reset for each play session.

    _visited = true
    @_globalCount++ 

`_visited` will be undefined at the start of the next play session, while
`visited` would remain `true` until changed otherwise.
