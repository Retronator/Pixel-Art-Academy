LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.ArtStudio extends LOI.Adventure.Location
  @id: -> 'Retronator.HQ.ArtStudio'
  @url: -> 'retronator/artstudio'
  @region: -> HQ

  @version: -> '0.0.1'

  @fullName: -> "Retronator HQ art studio"
  @shortName: -> "art studio"
  @description: ->
    "
      Fourth floor of the headquarters holds a painting studio.
      Easels are spread throughout the space together with drafting tables surrounding a stand in the middle.
      Stairs continue up into the residence part of the HQ, but it requires keycard access.
    "

  @defaultScriptUrl: -> 'retronator_retronator-hq/floor4/artstudio/artstudio.script'

  @initialize()

  constructor: ->
    super arguments...

    # Elevator button
    @elevatorButton = new HQ.Items.ElevatorButton
      location: @
      floor: 4

  things: -> [
    @constructor.Alexandra
    @constructor.Artworks
    @constructor.StillLifeStand
    PAA.Items.StillLifeItems.Cube.Small.unlessCollected()
    @elevatorButton
  ]

  exits: ->
    HQ.Elevator.addElevatorExit
      floor: 4
    ,
      "#{Vocabulary.Keys.Directions.Down}": HQ.GalleryWest
      "#{Vocabulary.Keys.Directions.Up}": HQ.Residence.Hallway

  # Script

  initializeScript: ->
    @setCallbacks
      EnterContext: (complete) =>
        contextClassName = @ephemeralState 'context'

        LOI.adventure.enterContext HQ.ArtStudio[contextClassName]

        Meteor.setTimeout =>
          LOI.adventure.interface.scroll
            position: 0
            animate: true

        # Note: We don't need to call complete since entering a context will stop this script.

  # Listener

  onCommand: (commandResponse) ->
    return unless artworks = LOI.adventure.getCurrentThing HQ.ArtStudio.Artworks

    commandResponse.onPhrase
      form: [Vocabulary.Keys.Verbs.LookAt, artworks]
      priority: 1
      action: =>
        @startScript label: 'LookAtArtworks'

  onExitAttempt: (exitResponse) ->
    if exitResponse.destinationLocationClass is HQ.Residence.Hallway
      @startScript label: 'PreventGoingToApartment'
      exitResponse.preventExit()
