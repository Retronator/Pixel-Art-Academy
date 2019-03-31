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

`DialogueLine` node that an actor delivers.

#### Choice

    * dialog line -> [label name]
    
or

    * @dialog line -> [label name]

`Choice` node with a `DialogueLine` node that the player can decide between. 
If choice is taken, script continues to given `Label`. (see `Jump` node below).

The `@` in front of the dialog line indicates that the player (the user) is speaking this, even if the script is 
executed while synced with a character. This is used for conversation with the player and their character.

#### ChoicePlaceholder

    * *placeholderId*

`ChoicePlaceholder` node will prompt all listeners to provide optional choices for that placeholder ID.

#### Code

    `javascript expression`

`Code` node that gets executed and potentially writes to the game state.

#### Timeout
    `wait number`
    
`Timeout` node that waits the provided number of milliseconds before continuing.

#### Pause
    `pause`
    
Instructs the interface to wait for user input (usually a key press) before continuing with the script.

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

### Text substitutions

Dialog and narrative lines can be marked with extra meaning.

#### Command hints

    You should ![open the door](open door).
    
The interface will highlight the text "open the door" and display the command hint "open door".

#### Character name and pronouns

    _char_ tries to open the door, but _they_ fail. _Their_ strength is too low.
    
`_char_` will be substituted with character's short name.

`_they_` will be substituted with character's subjective pronoun she/he/they.

`_them_` will be substituted with character's objective pronoun her/him/them.

`_their_` will be substituted with character's possessive adjective her/his/their.

`_theirs_` will be substituted with character's possessive pronoun (for use without object) hers/his/theirs.

`_char's_` will be substituted with possessive form of character's name.

The case of the command (`_they_` vs `_They_`) is preserved (she/he/they and She/He/They).

`_are_` will be substituted with singular (is) or plural (are) verb depending on the pronouns of the character.

#### Other names and pronouns

Similar to character names, substitutions can be created for other things using their shorthand name.

`_thing_` will be substituted with thing's short name.

`_thing:they_` and all variants (them/their/theirs) will be substituted with thing's pronouns.

`_thing's_` will be substituted with possessive form of thing's name.

`_thing:are_` will be substituted with singular or plural verb.

#### Character groups

`_are_` will be substituted with singular (is) or plural (are) verb depending on the size of the group.

### Text formatting

#### Colors

    %%c(hue)-(shade)%(text)c%%
    
`(hue)` and `(shade)` should be numbers inside the avatar palette (shade 0 is shade 6 in Atari2600).

`(text)` is the string being colored.

#### Case transform

    %%tU(text)t%%

Transforms `(text)` to uppercase.

    %%tL(text)t%%

Transforms `(text)` to lowercase.

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
* `<thing shorthand>`: State of thing objects provided with the `setThings` method on the script.
* `<thing shorthand>Instance`: Same as above, but gives the read-only thing instance itself.
* `location`: The state of the current location you're at.
* `@user`: The logged in user's state. It's null when not logged in.
* `@user.name`: A read-only variable with user's account name.
* `@user.itemKeys`: A read-only map of catalog keys that this user has purchased.
* `@character`: Read-only character instance.
* `@inventory`: A map of items in your inventory. State addressable by thing ID, with Instance suffix for instance itself.
* `@scripts`: All script states, addressable by script ID.
* `@things`: All thing states, addressable by thing ID.

#### Persistence

Script state is persistent by default. You can use the `_` sign before
variable names to address a variable that will be reset for each play session.

    _visited = true
    @_globalCount++ 

`_visited` will be undefined at the start of the next play session, while
`visited` would remain `true` until changed otherwise.
