LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.Script extends Script.Node
  constructor: (options) ->
    super
    
    @name = options.name
    @labels = {}
