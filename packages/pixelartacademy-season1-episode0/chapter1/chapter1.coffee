LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Season1.Episode0.Chapter1 extends LOI.Adventure.Chapter
  C1 = @

  @id: -> 'PixelArtAcademy.Season1.Episode0.Chapter1'

  @fullName: -> "Living the dream"

  @sections: -> [
    @Start
    @Immigration
  ]

  inventory: ->
    hasBackpack = C1.Start.Backpack.state 'inInventory'
    backpackOpened = C1.Start.Backpack.state 'opened'

    hasBottle = PAA.Items.Bottle.state 'inInventory'

    [
      C1.Start.Backpack if hasBackpack
      C1.Start.Passport if hasBackpack and backpackOpened
      C1.Start.AcceptanceLetter if hasBackpack and backpackOpened
      PAA.Items.Bottle if hasBottle
    ]
