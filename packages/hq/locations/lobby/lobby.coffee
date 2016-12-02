LOI = LandsOfIllusions
HQ = Retronator.HQ
PAA = PixelArtAcademy

Vocabulary = LOI.Adventure.Parser.Vocabulary

Action = LOI.Adventure.Ability.Action
Talking = LOI.Adventure.Ability.Talking

class HQ.Locations.Lobby extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.Locations.Lobby'
  @url: -> 'retronator/lobby'
  @scriptUrls: -> [
    'retronator_hq/locations/lobby/tablet.script'
  ]

  @fullName: -> "Retronator HQ lobby"
  @shortName: -> "lobby"
  @description: ->
    "
      You are in a comfortable lobby like hall. There is a big screen on the wall displaying all supporters of
      Retronator. Underneath is a shelf with an array of tablets. The sign says: _GET TABLET_ to explore Retronator HQ.
    "
  
  @initialize()

  constructor: ->
    super

  initialState: ->
    apps = {}
    apps[HQ.Items.Tablet.Apps.Welcome.id()] = {}
    apps[HQ.Items.Tablet.Apps.Menu.id()] = {}
    apps[HQ.Items.Tablet.Apps.Manual.id()] = {}

    things = {}
    things[HQ.Locations.Lobby.Display.id()] = displayOrder: 1
    things[HQ.Items.Tablet.id()] =
      displayOrder: 2
      apps:
        apps
      os:
        activeAppId: HQ.Items.Tablet.Apps.Welcome.id()

    exits = {}
    exits[Vocabulary.Keys.Directions.East] = HQ.Locations.Entrance.id()
    exits[Vocabulary.Keys.Directions.Out] = HQ.Locations.Entrance.id()
    exits[Vocabulary.Keys.Directions.South] = HQ.Locations.Reception.id()

    _.merge {}, super,
      things: things
      exits: exits

  onScriptsLoaded: ->
    # Tablet
    Tracker.autorun (computation) =>
      return unless tablet = @things HQ.Items.Tablet.id()
      computation.stop()

      tablet.addAbility new Action
        verb: Vocabulary.Keys.Verbs.Get
        action: =>
          @options.adventure.scriptHelpers.pickUpItem
            location: @
            item: HQ.Items.Tablet

          @director().startScript pickUpTablet

      pickUpTablet = @scripts['Retronator.HQ.Locations.Lobby.Scripts.PickUpTablet']
