AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Items.Tablet extends LOI.Adventure.Item
  # STATE
  # os: state of the OS
  # apps: an object with available apps and their states
  #   {appId}: the state of the app
  @register 'Retronator.HQ.Items.Tablet'
  template: -> 'Retronator.HQ.Items.Tablet'

  @id: -> 'Retronator.HQ.Items.Tablet'
  @url: -> 'spectrum/*'

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
      adventure: @options.adventure
      tablet: @

    @apps = new LOI.StateNode
      adventure: @options.adventure
      tablet: @
      classProvider: HQ.Items.Tablet.OS.App

    # Send state updates to the OS and apps.
    @_stateUpdateAutorun = Tracker.autorun =>
      state = @state()
      return unless state

      console.log "%cTablet", 'background: Plum', @, "has received a new state", state, "and we are sending it to the OS", @os, "and apps", @apps if HQ.debug

      @os.state state.os
      @apps.updateState state.apps

  destroy: ->
    @_stateUpdateAutorun.stop()
    
  addApp: (appClassOrId, completeCallback) ->
    appId = _.thingId appClassOrId
    appClass = HQ.Items.Tablet.OS.App.getClassForId appId

    console.log "Adding app", appId, appClass if HQ.debug

    # Add app unless it's already been added.
    stateApps = @state().apps
    unless stateApps[appId]
      stateApps[appId] = appClass.initialState()
      @options.adventure.gameState.updated()

    Tracker.autorun (computation) =>
      return unless app = @apps appId
      computation.stop()

      completeCallback? app

  activatedClass: ->
    'activated' if (@isRendered() and @activating()) or @activated()

  # Since the tablet can also be activated by itself, this tells us if we're the main active item (in which case the url
  # dictates the app) or we've been activated from code, in which case we can only rely on tablet state.
  isMainActiveItem: ->
    @options.adventure.activeItemId() is @id()

  overlaidClass: ->
    # The tablet is overlaying other items if it's not the main
    # active item, but make sure there is another item set there.
    'overlaid' if @options.adventure.activeItemId() and not @isMainActiveItem()

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
