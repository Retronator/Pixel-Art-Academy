LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.Label extends Script.Node
  constructor: (options) ->
    super arguments...
    
    @name = options.name

  end: ->
    # Set that we have visited this label.
    @script.state @name, true
    @script.ephemeralState @name, true

    # Finish transition.
    super arguments...
