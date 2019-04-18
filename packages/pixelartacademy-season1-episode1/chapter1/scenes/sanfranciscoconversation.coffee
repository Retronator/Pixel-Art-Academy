LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
HQ = Retronator.HQ
SF = SanFrancisco

Vocabulary = LOI.Parser.Vocabulary

class C1.SanFranciscoConversation extends LOI.Adventure.Scene.PersonConversation
  @id: -> 'PixelArtAcademy.Season1.Episode1.Chapter1.SanFranciscoConversation'

  @initialize()

  @defaultScriptUrl: -> 'retronator_pixelartacademy-season1-episode1/chapter1/scenes/sanfranciscoconversation.script'

  # Listener

  onCommand: (commandResponse) ->
    super arguments...

    scene = @options.parent

    # This conversation only applies to SF regions.
    regions = [
      SF.Soma
      SF.C3
      HQ
      HQ.LandsOfIllusions
      HQ.Residence
    ]

    location = LOI.adventure.currentLocation()
    return unless location.region() in regions

    for person in LOI.adventure.currentOtherPeople()
      do (person) =>
        commandResponse.onPhrase
          form: [Vocabulary.Keys.Verbs.TalkTo, person.avatar]
          priority: -1
          action: =>
            scene.prepareScriptForPerson person
            @startScript()
