LOI = LandsOfIllusions

Vocabulary = LOI.Parser.Vocabulary

class LOI.Adventure.Group extends LOI.Adventure.Scene
  isVisible: -> false
    
  presentMembers: ->
    # Override to provide thing members that are currently present at the scene.
    []

  things: ->
    @presentMembers()
