LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Season1.Episode0.Chapter1 extends LOI.Adventure.Chapter
  C1 = @

  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1'

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

  inventory: ->
    hasBackpack = C1.Backpack.state 'inInventory'
    backpackOpened = C1.Backpack.state 'opened'

    hasBottle = PAA.Items.Bottle.state 'inInventory'

    hasSuitcase = C1.Suitcase.state 'inInventory'

    [
      C1.Backpack if hasBackpack
      C1.Passport if hasBackpack and backpackOpened
      C1.AcceptanceLetter if hasBackpack and backpackOpened
      PAA.Items.Bottle if hasBottle
      C1.Suitcase if hasSuitcase
    ]

  timeToAirshipDeparture: ->
    return unless time = LOI.adventure.time()
    elapsedSeconds = time - @state('startTime')

    # Departure is in 10 minutes.
    10 * 60 - elapsedSeconds
