LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.Jump extends Script.Node
  constructor: (options) ->
    super arguments...

    @labelName = options.labelName
