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

  @initialize()

  constructor: ->
    super

    # React to player drinking.
    @autorun (computation) =>
      hasBottle = PAA.Items.Bottle.state 'inInventory'
      hasDrink = PAA.Items.Bottle.state 'drinkType'

      # Drinking happened if the bottle is in the inventory and the drink went from full to empty.
      if hasBottle and @_hadBottle and @_hadDrink and not hasDrink
        @state 'hadDrink', true

      @_hadBottle = hasBottle
      @_hadDrink = hasDrink

    @inOutro = new ReactiveField false

    # Listen for the goal condition.
    @autorun (computation) =>
      endingConditions = for endingCondition in ['tooLate', 'passOut', 'asleep']
        @constructor.Airship.state endingCondition

      if _.some endingConditions
        # The chapter is finished, proceed with outro animation.
        computation.stop()
        
        @inOutro true
        LOI.adventure.addModalDialog @
        
        Meteor.setTimeout =>
          LOI.adventure.removeModalDialog @
          PixelArtAcademy.Season1.Episode0.state 'currentChapter', 'PixelArtAcademy.Season1.Episode0.Chapter2'
        ,
          6000

  inventory: ->
    hasBackpack = C1.Items.Backpack.state 'inInventory'
    backpackOpened = C1.Items.Backpack.state 'opened'

    hasBottle = PAA.Items.Bottle.state 'inInventory'

    hasSuitcase = C1.Items.Suitcase.state 'inInventory'

    [
      C1.Items.Backpack if hasBackpack
      C1.Items.Passport if hasBackpack and backpackOpened
      C1.Items.AcceptanceLetter if hasBackpack and backpackOpened
      PAA.Items.Bottle if hasBottle
      C1.Items.Suitcase if hasSuitcase
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
