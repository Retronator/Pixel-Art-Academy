LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.CommandLine extends Script.Node
  constructor: (options) ->
    super

    @line = options.line
    @replaceLastCommand = options.replaceLastCommand
    @silent = options.silent
