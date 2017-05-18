LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Season1.Episode0.Chapter1 extends LOI.Adventure.Chapter
  C1 = @

  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1'
  template: -> @constructor.id()

  @fullName: -> "Living the dream"
  @number: -> 1

  @url: -> 'chapter1'

  @sections: -> [
    @Start
    @Immigration
    @Airship
  ]
    
  @scenes: -> [
    @Inventory
  ] 
    
  @timelineId: -> PAA.TimelineIds.DareToDream

  @initialize()
  
  constructor: ->
    super
    
    @inOutro = new ReactiveField false

    # Play outro animation when we finish the chapter.
    @autorun (computation) =>
      return unless @active() and not @finished()

      endingConditions = for endingCondition in ['tooLate', 'passOut', 'asleep']
        @constructor.Airship.state endingCondition

      # Any of the ending conditions triggers the chapter to be finished.
      return unless _.some endingConditions
      computation.stop()
      
      # Only do it once (since chapter finished will trigger on each subsequent reload).
      return if @state 'playedOutro'

      # The chapter is finished, proceed with outro animation.
      @inOutro true

      LOI.adventure.addModalDialog
        dialog: @
        dontRender: true
      
      Meteor.setTimeout =>
        LOI.adventure.removeModalDialog @
        @state 'playedOutro', true
      ,
        6000

  finished: ->
    @state('playedOutro') is true

  timeToAirshipDeparture: ->
    return unless time = LOI.adventure.time()
    elapsedSeconds = time - @state('startTime')

    # Departure is in 10 minutes.
    10 * 60 - elapsedSeconds

  fadeVisibleClass: ->
    'visible' if @inOutro() and not @finished()

  # Listener

  onCommand: (commandResponse) ->
    return unless LOI.adventure.currentTimelineId() is PAA.TimelineIds.DareToDream

    commandResponse.onExactPhrase
      form: [Vocabulary.Keys.Verbs.WakeUp]
      action: =>
        # End intro section.
        C1.Start.state 'leftTerrace', true

        # End immigration section.
        C1.Immigration.state 'leftCustoms', true

        # End airship section.
        C1.Airship.state 'asleep', true
