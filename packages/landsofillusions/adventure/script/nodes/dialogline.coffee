LOI = LandsOfIllusions
Script = LOI.Adventure.Script

class Script.Nodes.DialogLine extends Script.Node
  constructor: (@director, options) ->
    super

    @actor = options.actor
    @line = options.line
    @next = options.next

  end: ->
    @transition @next
