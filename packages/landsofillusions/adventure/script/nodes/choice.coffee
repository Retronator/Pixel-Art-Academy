LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.Choice extends Script.Node
  constructor: (options) ->
    super arguments...

    @node = options.node
