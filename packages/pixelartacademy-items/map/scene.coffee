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

    # Also show map for players directly coming to Retronator HQ.
    hasMap = true if Retronator.HQ.state()?

    # You don't need the map once you have sync.
    hasMap = false if PAA.Season1.Episode0.Chapter2.Immersion.state 'syncGiven'

    # Characters don't have the map, as they have sync from the start.
    hasMap = false if LOI.character()

    [
      PAA.Items.Map if hasMap
    ]
