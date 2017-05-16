LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.Map.Scene extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Items.Map.Scene'
  @location: -> LOI.Adventure.Inventory

  @initialize()

  things: ->
    # You have the map after you completed the script in Arrivals.
    hasMap = true if _.nestedProperty LOI.adventure.gameState(), "scripts.#{PAA.Season1.Episode0.Chapter1.Airship.Arrivals.id()}.MentalMap"

    # For existing players, also show the map after reaching chapter 2.
    hasMap = true if _.nestedProperty LOI.adventure.gameState(), "things.#{PAA.Season1.Episode0.Chapter2.id()}"

    [
      PAA.Items.Map if hasMap
    ]
