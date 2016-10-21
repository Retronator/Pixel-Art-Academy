LOI = LandsOfIllusions

class LOI.Adventure.Script.Node
  constructor: ->

  initialize: (options) ->
    @director = options.director
    @scriptNode = options.scriptNode

  end: ->
    @transition @next

  transition: (@nextNode) ->
    @director.scriptTransition @, @nextNode
