AB = Artificial.Base
AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.Menu extends AM.Component
  @id: -> 'LandsOfIllusions.Components.Menu'
  @register @id()
  @url: -> 'menu'

  constructor: (@options = {}) ->
    super arguments...

    @visible = new ReactiveField false

    @items = new (@options.itemsClass or @constructor.Items) @

    @signIn = new LOI.Components.SignIn
  
    @saveGame = new LOI.Components.SaveGame
    @loadGame = new LOI.Components.LoadGame
  
    @account = new LOI.Components.Account

    @_transitionDuration = 200

    # Set this variable to override show menu function.
    @customShowMenu = new ReactiveField null

  onCreated: ->
    super arguments...

    $(document).on 'keydown.menu', (event) =>
      return unless LOI.adventure.interface.active() or @visible()
      return if LOI.adventure.currentContext()
      
      # Make sure we're the active modal dialog.
      return unless LOI.adventure.topModalDialog() is @

      # Toggle menu on escape.
      if event.which is AC.Keys.escape
        # See if we should handle the menu change ourselves or to delegate.
        if customShowMenuHandler = @customShowMenu()
          customShowMenuHandler()

        else
          if @visible()
            @hideMenu()

          else
            @showMenu()

  onDestroyed: ->
    super arguments...

    $(document).off '.menu'

  showMenu: ->
    # We add a new routing context to not interfere with main adventure routing.
    AB.Router.addRoutingContext @constructor.id()
    
    LOI.adventure.addModalDialog
      dialog: @
      # We already render the menu ourselves as it only becomes an active dialog when it's visible.
      dontRender: true

    # Make menu visible and do the fade in.
    @visible true
    @$('.menu-overlay').velocity('stop').velocity
      opacity: [1, 0]
    ,
      duration: @_transitionDuration

  hideMenu: ->
    LOI.adventure.removeModalDialog @
    
    # We can return to main adventure routing.
    AB.Router.removeRoutingContext @constructor.id()

    # Fade out and then make menu not visible.
    @$('.menu-overlay').velocity('stop').velocity
      opacity: [0, 1]
    ,
      duration: @_transitionDuration
      complete: =>
        @visible false
        
        # Move back to the main menu so that when we come back, we'll start fresh.
        @items.goToMainMenu()

  display: -> LOI.adventure.interface.display

  visibleClass: ->
    'visible' if @visible()

  toolbarVisible: ->
    'visible' if @customShowMenu() or not @visible()

  audioEnabledClass: ->
    'audio-enabled' if LOI.adventure.audioManager.enabled()

  events: ->
    super(arguments...).concat
      'click .menu-button': @onClickMenuButton
      'click .toggle-audio-button': @onClickToggleAudioButton

  onClickMenuButton: (event) ->
    @showMenu()

  onClickToggleAudioButton: (event) ->
    if LOI.adventure.audioManager.enabled()
      value = LOI.Settings.Audio.Enabled.Off

    else
      value = LOI.Settings.Audio.Enabled.On

    LOI.settings.audio.enabled.value value
