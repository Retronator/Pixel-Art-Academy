LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

class PAA.Season1.Episode0.Chapter2 extends LOI.Adventure.Chapter
  C2 = @

  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter2'
  template: -> @constructor.id()

  @fullName: -> "Retronator HQ"
  @number: -> 2

  @sections: -> [
    C2.Intro
    C2.Registration
    C2.Immersion
  ]

  @scenes: -> [
    @Inventory
    @Store
    @SecondStreet
    @Cafe
  ]

  @timelineId: -> LOI.TimelineIds.RealLife

  @initialize()

  constructor: ->
    super

    # Move the player to Caltrain on start if coming from Dare to Dream intro.
    @autorun (computation) =>
      return unless @active() and not @finished()
      return unless LOI.adventure.currentTimelineId() is PAA.TimelineIds.DareToDream

      # Force the move so that exit responses are not called.
      LOI.adventure.setLocationId SanFrancisco.Soma.Caltrain.id()
      LOI.adventure.goToTimeline LOI.TimelineIds.RealLife

  onRendered: ->
    super

    # Finish intro.
    @autorun (computation) =>
      return unless @active() and not @finished()
      return unless @fadeOutNeeded()

      Meteor.setTimeout =>
        @state 'fadeOutDone', true
      ,
        1000

  fadeOutNeeded: ->
    # Intro is needed just at the Caltrain location (those coming directly to Retronator HQ should not be included).
    LOI.adventure.currentLocationId() is SanFrancisco.Soma.Caltrain.id() and not @state 'fadeOutDone'

  fadeVisibleClass: ->
    'visible' if @fadeOutNeeded()

  finished: ->
    # Chapter 2 ends when you finish immersion.
    C2.Immersion.finished()
