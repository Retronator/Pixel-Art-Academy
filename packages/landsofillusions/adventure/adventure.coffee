AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Adventure extends AM.Component
  ready: ->
    console.log "Am I ready? Parser:", @parser.ready(), "Current location:", @currentLocation()?.ready() if LOI.debug
    @parser.ready() and @currentLocation()?.ready()

  initializeGameState: (state) ->
    inventory = {}
    inventory[Retronator.HQ.Items.Wallet.id()] = {}

    locations = {}
    locations[Retronator.HQ.Locations.Elevator.id()] =
      floor: 1

    _.extend state,
      player:
        inventory: inventory
      locations: locations
      initialized: true

  logout: ->
    # Notify game state that it should flush any cached updates.
    @gameState?.updated flush: true

    # Log out the user.
    Meteor.logout()

  showDescription: (thing) ->
    @interface.showDescription thing

  deactivateCurrentItem: ->
    # We simply go back to the URL of the current location since that will deactivate the currently active item.
    @constructor.goToLocation @currentLocation().id()
