AM = Artificial.Mirage
LOI = LandsOfIllusions
HQ = Retronator.HQ

class HQ.Items.Tablet.OS.App extends AM.Component
  @activatedState:
    Deactivated: 'Deactivated'
    Activating: 'Activating'
    Activated: 'Activated'
    Deactivating: 'Deactivating'

  @_appClassesByUrl = {}
  @_appClassesById = {}

  # The full name is used when there is enough space to display it.
  @fullName: -> throw new Meteor.Error 'unimplemented', "You must specify app's full name."

  # The short name is used in menus and other places with less space, or to refer to it from text.
  @shortName: -> @fullName()

  # The description text displayed when you specifically ask what it is. Default (null) means no description.
  @description: -> null
    
  # Used to choose the icon asset for the menu.
  @iconName: -> @shortName()

  # Does this app show in the app menu?
  @showInMenu: -> true

  @getClassForUrl: (url) ->
    @_appClassesByUrl[url]

  @getClassForId: (id) ->
    @_appClassesById[id]

  @urlParameters: ->
    tabletUrl = HQ.Items.Tablet.urlParameters().parameter1

    urlParameters =
      parameter1: tabletUrl

    appClassUrl = @url()

    urlParameters.parameter2 = appClassUrl if appClassUrl

    urlParameters

  @fullUrl: ->
    FlowRouter.path 'LandsOfIllusions.Adventure', @urlParameters()

  @initialize: ->
    # Store thing class by ID and url.
    @_appClassesById[@id()] = @
    @_appClassesByUrl[@url()] = @

    # Prepare the avatar for this app.
    LOI.Avatar.initialize @

  constructor: (@options) ->
    super

    @avatar = new LOI.Avatar @constructor

    @state = new ReactiveField null

    # An item that can be activated has 4 stages in its lifecycle. You can use this
    # as a reactive variable to depend on the state the item is currently in.
    @activatedState = new ReactiveField @constructor.activatedState.Deactivated

    # Should the home screen button be shown?
    @showHomeScreenButton = new ReactiveField true

  deactivated: -> @activatedState() is @constructor.activatedState.Deactivated
  activating: -> @activatedState() is @constructor.activatedState.Activating
  activated: -> @activatedState() is @constructor.activatedState.Activated
  deactivating: -> @activatedState() is @constructor.activatedState.Deactivating

  activate: (onActivatedCallback) ->
    # The app gets activated (used).
    @activatedState @constructor.activatedState.Activating

    @onActivate =>
      @activatedState @constructor.activatedState.Activated
      onActivatedCallback?()

  deactivate: (onDeactivatedCallback) ->
    # The app gets deactivated.
    @activatedState @constructor.activatedState.Deactivating

    @onDeactivate =>
      @activatedState @constructor.activatedState.Deactivated
      onDeactivatedCallback?()

  onActivate: (finishedActivatingCallback) ->
    # Override to perform any logic when app is activated. Report that you've done the necessary
    # steps by calling the provided callback. By default we just call the callback straight away.
    finishedActivatingCallback()

  onDeactivate: (finishedDeactivatingCallback) ->
    # Override to perform any logic when app is about to be deactivated. Report that you've done the
    # necessary steps by calling the provided callback. By default we just call the callback straight away.
    finishedDeactivatingCallback()
