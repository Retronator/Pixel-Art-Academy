LOI = LandsOfIllusions
PAA = PixelArtAcademy
C3 = PixelArtAcademy.Season1.Episode0.Chapter3
HQ = Retronator.HQ

class C3.Sync extends LOI.Adventure.Section
  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter3.Sync'

  @scenes: -> [
    @Basement
  ]

  @timelineId: -> LOI.TimelineIds.RealLife

  @initialize()

  @started: ->
    # Sync section starts when Construct section completes.
    @requireFinishedSections C3.Construct

  @finished: ->
    # Sync section is over when the player has synced with a character
    # from the operator dialog. Make sure we don't return undefined.
    HQ.Items.OperatorLink.scriptState('CharacterSync') is true
