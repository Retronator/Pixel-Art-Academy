LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.Label extends Script.Node
  constructor: (options) ->
    super
    
    @name = options.name

  end: ->
    # Set that we have visited this label.

    # For ephemeral state, we need to change the plain object and rewrite it to trigger reactivity.
    state = @script.ephemeralState()
    state[@name] = true
    @script.ephemeralState state

    # For normal state, we just use the state object setter.
    @script.stateObject @name, true

    # Finish transition.
    super
