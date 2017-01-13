AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.Menu extends AM.Component
  @register 'LandsOfIllusions.Components.Menu'

  constructor: (@options) ->
    super

    @menuVisible = new ReactiveField false

    @menuItems = new @constructor.Items

    @signIn = new LOI.Components.SignIn

    @account = new LOI.Components.Account

    @_transitionDuration = 200

    # Set this variable to override show menu function.
    @customShowMenu = new ReactiveField null

  onCreated: ->
    super

    $(document).on 'keydown.menu', (event) =>
      # Toggle menu on escape.
      if event.which is AC.Keys.escape
        # See if we should handle the menu change ourselves or to delegate.
        if customShowMenuHandler = @customShowMenu()
          customShowMenuHandler()

        else
          if @menuVisible()
            @hideMenu()

          else
            @showMenu()

  onDestroyed: ->
    super

    $(document).off '.menu'

  showMenu: ->
    # Make menu visible and do the fade in.
    @menuVisible true
    @$('.menu-overlay').velocity('stop').velocity
      opacity: [1, 0]
    ,
      duration: @_transitionDuration

  hideMenu: ->
    # Fade out and then make menu not visible.
    @$('.menu-overlay').velocity('stop').velocity
      opacity: [0, 1]
    ,
      duration: @_transitionDuration
      complete: =>
        @menuVisible false

  menuVisibleClass: ->
    'visible' if @menuVisible()

  menuButtonVisibleClass: ->
    'visible' unless @menuVisible()

  # Activates an item and waits for the player to complete interacting with it.
  showModalDialog: (options) ->
    # Wait until dialog has been active and deactivated again.
    dialogWasActivated = false

    LOI.adventure.addModalDialog options.dialog
    options.dialog.activatable.activate()

    Tracker.autorun (computation) =>
      if options.dialog.activatable.activated()
        dialogWasActivated = true

      else if options.dialog.activatable.deactivated() and dialogWasActivated
        computation.stop()
        LOI.adventure.removeModalDialog options.dialog
    
        options.callback?()

  events: ->
    super.concat
      'click .menu-button': @onClickMenuButton

  onClickMenuButton: (event) ->
    @showMenu()
