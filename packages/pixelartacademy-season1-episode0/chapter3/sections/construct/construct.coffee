LOI = LandsOfIllusions
PAA = PixelArtAcademy
C3 = PixelArtAcademy.Season1.Episode0.Chapter3
HQ = Retronator.HQ

class C3.Construct extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter3.Construct'

  @scenes: -> [
    @Loading
  ]

  @timelineId: -> LOI.TimelineIds.Construct

  @initialize()

  @started: -> true

  @finished: ->
    # Construct section is over when the player has any activated characters.
    # We should still force them to go through the dialog at least once first.
    return false unless C3.Construct.Loading.scriptState('MainQuestions')

    activatedCharacter = _.find Retronator.user().characters, (character) => character.activated

    activatedCharacter?
