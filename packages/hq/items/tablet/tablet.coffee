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
    
  addApp: (appClassOrId) ->
    appId = _.thingId appClassOrId
    @state().apps[appId] = {}
    @options.adventure.gameState.updated()

  activatedClass: ->
    'activated' if (@isRendered() and @activating()) or @activated()

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
