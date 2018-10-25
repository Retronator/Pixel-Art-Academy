LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.Timeout extends Script.Node
  constructor: (options) ->
    super arguments...

    @milliseconds = options.milliseconds
