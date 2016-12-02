AM = Artificial.Mirage
HQ = Retronator.HQ

class HQ.Items.Tablet.OS extends AM.Component
  # STATE
  # activeAppId: id of the app that should be opened if no url is provided.
  @register 'Retronator.HQ.Items.Tablet.OS'

  constructor: (@options) ->
    super

    @state = new ReactiveField null

  onCreated: ->
    super

    @currentAppId = new ReactiveField null
    @currentAppUrl = new ReactiveField null
    @currentApp = new ReactiveField null

    @autorun (computation) =>
      # Listen for parameter changes.

      # Make sure we're still on the tablet URL.
      tabletUrl = HQ.Items.Tablet.urlParameters().parameter1
      return unless tabletUrl is FlowRouter.getParam 'parameter1'

      appUrl = FlowRouter.getParam 'parameter2'
      
      console.log "OS is selecting the app from url", appUrl if HQ.debug

      if appUrl
        appClass = HQ.Items.Tablet.OS.App.getClassForUrl appUrl

      else
        # If we didn't find an app url, see if we have the ID stored in the state.
        Tracker.nonreactive =>
          state = @state()
          console.log "No url. Trying to load from state", state if HQ.debug
          appClass = HQ.Items.Tablet.OS.App.getClassForId state?.activeAppId
          
      # Make sure we have this app available.
      availableApps = @options.tablet.state().apps
      appClass = null unless availableApps[appClass?.id()]

      # If we still don't have an app class, start with the menu.
      appClass ?= HQ.Items.Tablet.Apps.Menu

      console.log "Determined class", appClass.id() if HQ.debug

      # Change active app in OS state.
      Tracker.nonreactive =>
        @state().activeAppId = appClass.id()

      @currentAppId appClass.id()

      appClassUrl = appClass.url()
      @currentAppUrl appClassUrl

      currentApp = @currentApp()

      rewriteUrl = =>
        # Rewrite the url to match the app. Start with the tablet+app URL.
        urlParameters =
          parameter1: tabletUrl

        urlParameters.parameter2 = appClassUrl if appClassUrl

        # If app URL didn't change also preserve the parameters.
        if appClassUrl is appUrl
          Tracker.nonreactive =>
            _.extend urlParameters,
              parameter3: FlowRouter.getParam 'parameter3'
              parameter4: FlowRouter.getParam 'parameter4'

        # HACK: We delay rewriting because it seems that adventure's routing (probably due to some
        # FlowRouter logic) overwrites this later on (even if we use afterFlush for example).
        Meteor.setTimeout =>
          console.log "Rewriting app url to", urlParameters if HQ.debug
          FlowRouter.go 'LandsOfIllusions.Adventure', urlParameters
        ,
          0

      if currentApp?.constructor.id() is appClass.id()
        rewriteUrl()
        return

      newApp = new appClass
        os: @
        tablet: @options.tablet
        adventure: @options.adventure

      console.log "Made new app instance", newApp if HQ.debug

      startNewApp = =>
        @currentApp newApp
        newApp.activate()
        rewriteUrl()

      if currentApp
        currentApp.deactivate =>
          startNewApp()

      else
        startNewApp()

  goToApp: (appClassOrId) ->
    appClass = if _.isFunction appClassOrId then appClassOrId else HQ.Items.Tablet.OS.App.getClassForId appClassOrId

    urlParameters = appClass.appUrlParameters()

    # Change active app in OS state.
    Tracker.nonreactive =>
      @state().activeAppId = appClass.id()
      @options.adventure.gameState.updated()
      
    # Route to correct URL.
    FlowRouter.go 'LandsOfIllusions.Adventure', urlParameters
    
  menuLink: ->
     HQ.Items.Tablet.Apps.Menu.fullUrl()
