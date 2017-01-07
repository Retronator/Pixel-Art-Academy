LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.Callback extends Script.Node
  constructor: (options) ->
    super
    
    @name = options.name

  toString: -> "#{Callback}{#{@name}}"
