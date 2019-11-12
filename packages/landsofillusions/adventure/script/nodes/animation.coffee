LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.Animation extends Script.Node
  constructor: (options) ->
    super arguments...
    
    @name = options.name
    @callback = options.callback
