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
    @Intro
    @Immigration
    @Airship
  ]
    
  @timelineId: -> PAA.TimelineIds.DareToDream

  @initialize()
  
  constructor: ->
    super
    
    @inventory = new @constructor.Inventory parent: @

    @inOutro = new ReactiveField false

    # Play outro animation when we finish the chapter.
    @autorun (computation) =>
      return if @finished()

      endingConditions = for endingCondition in ['tooLate', 'passOut', 'asleep']
        @constructor.Airship.state endingCondition

      # Any of the ending conditions triggers the chapter to be finished.
      return unless _.some endingConditions
      computation.stop()
      
      # Only do it once (since chapter finished will trigger on each subsequent reload).
      return if @state 'playedOutro'

      # The chapter is finished, proceed with outro animation.
      @inOutro true
      LOI.adventure.addModalDialog @
      
      Meteor.setTimeout =>
        LOI.adventure.removeModalDialog @
        @state 'playedOutro', true
      ,
        6000

  destroy: ->
    @inventory.destroy()
        
  finished: ->
    @state 'playedOutro'
    
  scenes: -> [
    @inventory
  ]

  timeToAirshipDeparture: ->
    return unless time = LOI.adventure.time()
    elapsedSeconds = time - @state('startTime')

    # Departure is in 10 minutes.
    10 * 60 - elapsedSeconds

  fadeVisibleClass: ->
    'visible' if @inOutro()

  onCommand: (commandResponse) ->
    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.WakeUp]
      action: =>
        C1.Items.Backpack.state 'inInventory', true
        C1.Airship.state 'asleep', true
