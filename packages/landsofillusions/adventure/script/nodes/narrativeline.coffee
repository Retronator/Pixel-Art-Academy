LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.NarrativeLine extends Script.Node
  constructor: (options) ->
    super arguments...

    @line = options.line
    @scrollStyle = options.scrollStyle
