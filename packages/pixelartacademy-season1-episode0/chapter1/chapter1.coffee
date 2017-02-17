LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Season1.Episode0.Chapter1 extends LOI.Adventure.Chapter
  C1 = @

  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1'

  @fullName: -> "Living the dream"

  @sections: -> [
    @Start
    @Immigration
    @Airship
  ]

  @initialize()

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
