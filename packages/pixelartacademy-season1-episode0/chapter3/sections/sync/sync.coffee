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

  constructor: ->
    super

    # Subscribe to user's activated characters.
    @_charactersSubscription = LOI.Character.activatedForCurrentUser.subscribe()

  destroy: ->
    super

    @_charactersSubscription.stop()

  active: ->
    # Sync section starts when Construct section completes, but Construct doesn't use the
    # static finished implementation, so we must pass the instance as a required section.
    # HACK: chapter.sections are sometimes not set on loading, so we check for their presence.
    return unless constructSection = _.find @chapter.sections?(), (section) => section instanceof C3.Construct

    @requireFinishedSections constructSection

  @finished: ->
    # Sync section is over when the player has synced with a character
    # from the operator dialog. Make sure we don't return undefined.
    HQ.Items.OperatorLink.scriptState('CharacterSync') is true
