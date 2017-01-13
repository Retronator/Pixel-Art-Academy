LOI = LandsOfIllusions

class LOI.Adventure.Script.Node
  constructor: (options) ->
    @next = options.next

  end: ->
    @transition @next

  transition: (nextNode) ->
    LOI.adventure.director.scriptTransition @, nextNode
