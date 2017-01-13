AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Items.Tablet.OS extends AM.Component
  # STATE
  # activeAppId: id of the app that should be opened if no url is provided.
  @register 'Retronator.HQ.Items.Tablet.OS'

  constructor: (@options) ->
    super

    @stateObject = new LOI.StateObject @options

    @activeAppId = @stateObject.field 'activeAppId'

    # If the tablet is not the main active tablet, we shouldn't use the URL
    # to change the app, so we hijack the links and change the app via state.
    FlowRouter.triggers.enter [(context, redirect, stop) =>
      unless @options.tablet.isMainActiveItem()
        # First check if this even is an app url (we assume that if an app is in context).
        tabletUrl = HQ.Items.Tablet.urlParameters().parameter1
        return unless tabletUrl is context.params.parameter1

        appUrl = context.params.parameter2

        appClass = HQ.Items.Tablet.OS.App.getClassForUrl appUrl if appUrl
        return unless appClass

        console.log "We're trying to get to app", appClass.id() if HQ.debug

        # Yes, this is an app, so the link should just change the state.
        @options.tablet.os.state().activeAppId = appClass.id()
        LOI.adventure.gameState.updated()

        # Stay at the same URL.
        redirect location.pathname
    ],
      only: ['LandsOfIllusions.Adventure']

  onCreated: ->
    super

    @currentAppId = new ReactiveField null
    @currentAppUrl = new ReactiveField null
    @currentApp = new ReactiveField null

    @autorun (computation) =>
      # Listen for app changes. If we're the main active item we can rely on the URL, otherwise only on the state.

      appClass = null

      isMainActiveItem = @options.tablet.isMainActiveItem()

      if isMainActiveItem
        # Make sure we're still on the tablet URL.
        tabletUrl = HQ.Items.Tablet.urlParameters().parameter1
        return unless tabletUrl is FlowRouter.getParam 'parameter1'

        appUrl = FlowRouter.getParam 'parameter2'

        console.log "OS is selecting the app from url", appUrl if HQ.debug

        appClass = HQ.Items.Tablet.OS.App.getClassForUrl appUrl if appUrl

      # If we didn't find an app from url, see if we have the ID stored in the state.
      unless appClass
        Tracker.nonreactive =>
          appClass = HQ.Items.Tablet.OS.App.getClassForId @activeAppId()
          
      # Make sure we have this app available.
      appClass = null unless @options.tablet.apps appClass?.id()

      # If we still don't have an app class, start with the menu.
      appClass ?= HQ.Items.Tablet.Apps.Menu

      console.log "Determined class", appClass.id() if HQ.debug

      # Change active app in OS state.
      Tracker.nonreactive =>
        @activeAppId appClass.id()

      @currentAppId appClass.id()

      appClassUrl = appClass.url()
      @currentAppUrl appClassUrl

      currentApp = @currentApp()

      rewriteUrl = =>
        # We don't use URLs when we're not active.
        return unless isMainActiveItem

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

      # Is the current app already the one we want? Then we don't have to create it.
      if currentApp?.constructor.id() is appClass.id()
        rewriteUrl()
        return

      # Nope, it looks like we do need a new app.
      newApp = @options.tablet.apps appClass

      console.log "Spectrum OS switching to app", newApp if HQ.debug

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

    urlParameters = appClass.urlParameters()

    # Change active app in OS state.
    Tracker.nonreactive =>
      @activeAppId appClass.id()
      
    # Route to correct URL.
    FlowRouter.go 'LandsOfIllusions.Adventure', urlParameters
    
  menuApp: ->
    @options.tablet.apps HQ.Items.Tablet.Apps.Menu

  event: ->
    super.concat
      'click .menu-button': @onClickLink

  onClickLink: (event) ->
