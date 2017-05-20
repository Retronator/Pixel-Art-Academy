AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Components.Menu extends AM.Component
  @register 'LandsOfIllusions.Components.Menu'
  @url: -> 'menu'

  constructor: (@options) ->
    super

    @menuVisible = new ReactiveField false

    @menuItems = new @constructor.Items

    @signIn = new LOI.Components.SignIn

    @account = new LOI.Components.Account
    
    @mediaplayer = new LOI.Components.MediaPlayer

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

  menuButtonVisibleClass: ->
    'visible' unless @menuVisible()

  events: ->
    super.concat
      'click .menu-button': @onClickMenuButton

  onClickMenuButton: (event) ->
    @showMenu()
