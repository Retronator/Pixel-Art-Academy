LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.DialogueLine extends Script.Node
  constructor: (options) ->
    super
    
    @actor = options.actor
    @line = options.line
    @immediate = options.immediate
