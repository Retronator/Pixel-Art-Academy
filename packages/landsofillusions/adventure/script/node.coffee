LOI = LandsOfIllusions

class LOI.Adventure.Script.Node
  constructor: (@director) ->
    
  transition: (@nextNode) ->
    @director.scriptTransition @, @nextNode
