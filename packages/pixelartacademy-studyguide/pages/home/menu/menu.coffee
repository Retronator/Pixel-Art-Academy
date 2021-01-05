AC = Artificial.Control
AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StudyGuide.Pages.Home.Menu extends AM.Component
  @register 'PixelArtAcademy.StudyGuide.Pages.Home.Menu'

  constructor: (@home) ->
    super arguments...

  onCreated: ->
    super arguments...

    @menuVisible = new ReactiveField false

    @menuItems = new @constructor.Items @

    @signIn = new LOI.Components.SignIn

    @account = new LOI.Components.Account
      dialogProvider: @home.layout
      useUrlRouting: false

    @_transitionDuration = 200

  showMenu: ->
    @home.layout.addModalDialog
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
    @home.layout.removeModalDialog @

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
    'visible' unless @menuVisible()

  events: ->
    super(arguments...).concat
      'click .menu-button': @onClickMenuButton

  onClickMenuButton: (event) ->
    @showMenu()
