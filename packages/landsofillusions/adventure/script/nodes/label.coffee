LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.Label extends Script.Node
  constructor: (options) ->
    super
    
    @name = options.name

  end: ->
    # Every node we visit gets set to true on the script state, so we can reference it later.
    for field in ['state', 'ephemeralState']
      state = @script[field]()
      state[@name] = true

      # Trigger reactive change.
      @script[field] state

    # Finish transition.
    super
