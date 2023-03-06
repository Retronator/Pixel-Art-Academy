AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.Menu extends AM.Component
  @register 'LandsOfIllusions.Components.Menu'
  @url: -> 'menu'

  constructor: (@options = {}) ->
    super arguments...

    @menuVisible = new ReactiveField false

    @menuItems = new (@options.menuItemsClass or @constructor.Items)

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
      return unless LOI.adventure.interface.active() or @menuVisible()
      return if LOI.adventure.currentContext()

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
    super arguments...

    $(document).off '.menu'

  showMenu: ->
    LOI.adventure.addModalDialog
      dialog: @
      # We already render the menu ourselves as it only becomes an active dialog when it's visible.
      dontRender: true

    # Make menu visible and do the fade in.
    @menuVisible true
    @$('.menu-overlay').velocity('stop').velocity
      opacity: [1, 0]
    ,
      duration: @_transitionDuration

  hideMenu: ->
    LOI.adventure.removeModalDialog @

    # Fade out and then make menu not visible.
    @$('.menu-overlay').velocity('stop').velocity
      opacity: [0, 1]
    ,
      duration: @_transitionDuration
      complete: =>
        @menuVisible false

  menuVisibleClass: ->
    'visible' if @menuVisible()

  toolbarVisible: ->
    'visible' if @customShowMenu() or not @menuVisible()

  audioEnabledClass: ->
    'audio-enabled' if LOI.adventure.world.audioManager().enabled()

  events: ->
    super(arguments...).concat
      'click .menu-button': @onClickMenuButton
      'click .toggle-audio-button': @onClickToggleAudioButton

  onClickMenuButton: (event) ->
    @showMenu()

  onClickToggleAudioButton: (event) ->
    if LOI.adventure.world.audioManager().enabled()
      value = LOI.Settings.Audio.Enabled.Off

    else
      value = LOI.Settings.Audio.Enabled.On

    LOI.settings.audio.enabled.value value
