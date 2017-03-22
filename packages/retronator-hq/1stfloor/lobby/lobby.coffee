LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Parser.Vocabulary

class HQ.Lobby extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Lobby'
  @url: -> 'retronator/lobby'
  @scriptUrls: -> [
    'retronator-hq/hq.script'
    'retronator-hq/locations/1stfloor/lobby/tablet.script'
  ]

  @version: -> '0.0.1'

  @fullName: -> "Retronator HQ lobby"
  @shortName: -> "lobby"
  @description: ->
    "
      You are in a comfortable lobby like hall. There is a big screen on the wall displaying all supporters of
      Retronator. Underneath is a shelf with an array of tablets. The sign says: _get tablet_ to explore Retronator HQ.
    "
  
  @initialize()

  constructor: ->
    super

  things: ->
    [
      HQ.Lobby.Display.id()
      HQ.Items.Tablet.id()
    ]

  exits: ->
    exits = {}
    exits[Vocabulary.Keys.Directions.East] = HQ.Entrance.id()
    exits[Vocabulary.Keys.Directions.Out] = HQ.Entrance.id()
    exits[Vocabulary.Keys.Directions.South] = HQ.Cafe.id()
    exits[Vocabulary.Keys.Directions.Southwest] = HQ.Gallery.id()
    exits[Vocabulary.Keys.Directions.West] = HQ.Steps.id()
    exits[Vocabulary.Keys.Directions.Up] = HQ.Steps.id()
    exits

  onScriptsLoaded: ->
    # Tablet
    Tracker.autorun (computation) =>
      return unless tablet = @thingInstances HQ.Items.Tablet.id()
      computation.stop()

      tablet.addAbility new Action
        verb: Vocabulary.Keys.Verbs.Get
        action: =>
          LOI.adventure.scriptHelpers.pickUpItem
            location: @
            item: HQ.Items.Tablet

          LOI.adventure.director.startScript pickUpTablet

      pickUpTablet = @scripts['Retronator.HQ.Lobby.Scripts.PickUpTablet']
