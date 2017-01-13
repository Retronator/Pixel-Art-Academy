LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.InterfaceLine extends Script.Node
  constructor: (options) ->
    super

    @line = options.line
    @silent = options.silent
