LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.DialogueLine extends Script.Node
  constructor: (options) ->
    super arguments...
    
    @actor = options.actor
    @actorName = options.actorName
    @line = options.line
    @immediate = options.immediate
    @command = options.command
