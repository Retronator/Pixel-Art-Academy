LOI = LandsOfIllusions
Start = PixelArtAcademy.Season1.Episode1.Start
Apartment = SanFrancisco.Apartment

Vocabulary = LOI.Parser.Vocabulary

class Start.WakeUp extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Season1.Episode1.Start.WakeUp'

  @location: -> Apartment.Studio

  @intro: -> "You find yourself … nowhere. Everything is pitch black."

  @initialize()

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/start/scenes/wakeup.script'

  onEnter: (enterResponse) ->
    @startScript()
    
  removeExits: ->
    "#{Vocabulary.Keys.Directions.Out}": Apartment.Hallway
