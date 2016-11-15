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

If you want a variable to be available everywhere,
use the `@` sign before variable names.

    @happy = true

This is also known as the global state. `@happy` will be `true` across
scripts while `happy` would hold true only in this script's code.

There are some special variables that provide other contexts:

* `@user`: The logged in user's state. It's null when not logged in.
* `@user.name`: A read-only variable with user's account name.
* `location`: The local state unique to the location you're at.
* `@locations`: All location states, addressable by location ID.
* `@actors`: All actor states, addressable by actor ID.
* `@items`: All item states, addressable by item ID.
* `@player.inventory`: A subset of @items with only the items in your inventory.

#### Persistence

Script state is persistent by default. You can use the `_` sign before
variable names to address a variable that will be reset for each play session.

    _visited = true
    @_globalCount++ 

`_visited` will be undefined at the start of the next play session, while
`visited` would remain `true` until changed otherwise.
