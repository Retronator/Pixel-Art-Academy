LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.DialogLine extends Script.Node
  constructor: (options) ->
    super
    
    @actor = options.actor
    @line = options.line
