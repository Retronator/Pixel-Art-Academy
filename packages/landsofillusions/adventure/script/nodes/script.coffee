LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.Script extends Script.Node
  constructor: (options) ->
    super
    
    @id = options.id
    @labels = options.labels
    @callbacks = options.callbacks
