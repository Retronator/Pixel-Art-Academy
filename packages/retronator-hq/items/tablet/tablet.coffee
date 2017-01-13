AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Items.Tablet extends LOI.Adventure.Item
  # STATE
  # os: state of the OS
  # apps: an object with available apps and their states
  #   {appId}: the state of the app
  @id: -> 'Retronator.HQ.Items.Tablet'
  @url: -> 'spectrum/*'

  @register @id()
  template: -> @constructor.id()

  @version: -> '0.0.1'

  @fullName: -> "Spectrum tablet"

  @shortName: -> "tablet"

  @description: ->
    "
      It's the latest model of the signature Retronator Spectrum Tablet, used to interact around Retronator HQ.
    "

  @initialize()

  constructor: ->
    super

    @addAbilityToActivateByLookingOrUsing()

    @os = new HQ.Items.Tablet.OS
      tablet: @
      address: @address.child 'os'

    @apps = new LOI.StateInstances
      tablet: @
      address: @address.child 'apps'
      classProvider: HQ.Items.Tablet.OS.App

  destroy: ->
    @_stateUpdateAutorun.stop()
    
  addApp: (appClassOrId, completeCallback) ->
    appId = _.thingId appClassOrId
    appClass = HQ.Items.Tablet.OS.App.getClassForId appId

    console.log "Adding app", appId, appClass if HQ.debug

    # Add app unless it's already been added.
    @stateObject appId, {}

    stateApps = @stateObject().apps
    unless stateApps[appId]
      stateApps[appId] = {}
      LOI.adventure.gameState.updated()

    Tracker.autorun (computation) =>
      return unless app = @apps appId
      computation.stop()

      completeCallback? app

  activatedClass: ->
    'activated' if (@isRendered() and @activating()) or @activated()

  # Since the tablet can also be activated by itself, this tells us if we're the main active item (in which case the url
  # dictates the app) or we've been activated from code, in which case we can only rely on tablet state.
  isMainActiveItem: ->
    LOI.adventure.activeItemId() is @id()

  overlaidClass: ->
    # The tablet is overlaying other items if it's not the main
    # active item, but make sure there is another item set there.
    'overlaid' if LOI.adventure.activeItemId() and not @isMainActiveItem()

  onActivate: (finishedActivatingCallback) ->
    Meteor.setTimeout =>
      finishedActivatingCallback()
    ,
      1000

  onDeactivate: (finishedDeactivatingCallback) ->
    Meteor.setTimeout =>
      finishedDeactivatingCallback()
    ,
      1000
