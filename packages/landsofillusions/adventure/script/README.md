# Lands of Illusions Adventure Script

Adventure Script is the language used to write interactions in the world of Lands of Illusions.

## Syntax
  
### Nodes

#### Script
```
# script name
```

`Script` node that defines the name under which the root node is exported.

#### Label
```
## label name
```

`Label` node which you can jump to from other nodes.

#### DialogLine
```
actor name: dialog line
```
or
```
actor name:
    dialog line 1
    dialog line 2
```

`DialogLine` node that an actor delivers.

#### Choice
```
* dialog line -> [label name]
```
`Choice` node with a `DialogLine` node that the player can decide between. 
If choice is taken, script continues to given `Label`. (see `Jump` node below).

#### Code
```
`javascript expression`
```
`Code` node that gets executed and potentially writes to the game state.

### Modifiers

#### Conditionals

```
any line `javascript condition`
```
Include the preceding node only if condition evaluates to a truthy value.

#### Jump

```
any line -> [label name]
```
or
```
-> [label name]
```

Jump to the `Label` node after this node (instead of following through to the node below in the script).
