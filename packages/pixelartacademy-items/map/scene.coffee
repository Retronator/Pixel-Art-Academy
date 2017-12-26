LOI = LandsOfIllusions
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class PAA.Items.Map.Scene extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.Items.Map.Scene'
  @location: -> LOI.Adventure.Inventory

  @initialize()

  things: ->
    # You have the map after you completed the script in Arrivals.
    hasMap = true if PAA.Season1.Episode0.Chapter1.Immigration.Concourse.scriptState 'MentalMap'

    # For existing players, also show the map after reaching chapter 2.
    hasMap = true if PAA.Season1.Episode0.state 'Chapter2'

    # For characters, always show the map.
    hasMap = true if LOI.character()

    [
      PAA.Items.Map if hasMap
    ]
