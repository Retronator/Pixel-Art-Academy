AE = Artificial.Everywhere
AB = Artificial.Base
AM = Artificial.Mirage
LOI = LandsOfIllusions
LM = PixelArtAcademy.LearnMode

class LM.Menu.Items extends LOI.Components.Menu.Items
  @register 'PixelArtAcademy.LearnMode.Menu.Items'
  template: -> 'PixelArtAcademy.LearnMode.Menu.Items'
  
  constructor: ->
    super arguments...
    
    @progress = new LM.Menu.Progress
  
  onCreated: ->
    super arguments...
    
    # On desktop we have to ask the window for its full-screen status.
    if Meteor.isDesktop
      @_isFullscreen = new ReactiveField false

      # Listen to fullscreen changes.
      Desktop.on 'window', 'isFullscreen', (event, isFullscreen) =>
        @_isFullscreen isFullscreen
      
      # Request initial value.
      Desktop.send 'window', 'isFullscreen'
    
  loadVisible: ->
    # Load game in Learn Mode is visible only on the landing page if there are any profiles to load.
    loadGame = LOI.adventure.menu.loadGame
    @options.landingPage and loadGame.isCreated() and loadGame.profiles()
  
  progressVisible: ->
    # Progress is shown when we're not on the landing page.
    not @options.landingPage
    
  isFullscreen: ->
    if Meteor.isDesktop
      @_isFullscreen()
    
    else
      super arguments...
  
  extrasVisible: ->
    # Extras are visible only on the landing page.
    @options.landingPage

  quitToMenuVisible: ->
    # We quit to menu when we're not on the landing page.
    not @options.landingPage
    
  events: ->
    super(arguments...).concat
      # Main menu
      'click .main-menu .progress': @onClickMainMenuProgress
      'click .main-menu .extras': @onClickMainMenuExtras
      'click .main-menu .quit-to-menu': @onClickMainMenuQuitToMenu
      'click .settings .fullscreen': @onClickSettingsFullscreen
      'click .extras .courses': @onClickExtrasCourses
      'click .extras .credits': @onClickExtrasCredits
      'click .extras .back-to-menu': @onClickExtrasBackToMenu

  onClickMainMenuContinue: (event) ->
    LOI.adventure.menu.hideMenu()
  
  onClickMainMenuNew: (event) ->
    LOI.adventure.interface.waiting true

    LOI.adventure.startNewGame().then =>
      LOI.adventure.interface.goToPlay()

  onClickMainMenuProgress: (event) ->
    @progress.show()
  
  onClickMainMenuExtras: (event) ->
    @currentScreen @constructor.Screens.Extras
    
  onClickMainMenuQuitToMenu: (event) ->
    # Check if the profile is being synced.
    if LOI.adventure.profile().hasSyncing()
      @_quitGame()
  
    else
      # Notify the player that they will lose the current game state.
      dialog = new LOI.Components.Dialog
        message: "You will lose your current game progress if you quit without saving."
        buttons: [
          text: "Quit"
          value: true
        ,
          text: "Cancel"
        ]
    
      LOI.adventure.showActivatableModalDialog
        dialog: dialog
        callback: =>
          @_quitGame() if dialog.result
          
  _quitGame: ->
    LOI.adventure.interface.waiting true

    LOI.adventure.menu.hideMenu()
    LOI.adventure.deactivateActiveItem()
    
    Meteor.setTimeout =>
      LOI.adventure.quitGame callback: =>
        LOI.adventure.interface.goToMainMenu()
        
        # Notify that we've handled the quitting sequence.
        true
    ,
      500

  onClickMainMenuQuit: (event) ->
    if Meteor.isDesktop
      Desktop.send 'desktop', 'closeApp'

  onClickMainMenuFullscreen: (event) ->
    if Meteor.isDesktop
      if @_isFullscreen()
        Desktop.send 'window', 'setFullscreen', false
    
      else
        Desktop.send 'window', 'setFullscreen', true
        
    else
      if AM.Window.isFullscreen()
        AM.Window.exitFullscreen()
    
      else
        AM.Window.enterFullscreen()
      
    # Do a late UI resize to accommodate any fullscreen transitions.
    Meteor.setTimeout =>
      LOI.adventure.interface.resize()
    ,
      1000
  
  onClickSettingsFullscreen: (event) ->
    # Act the same as the main menu fullscreen button.
    @onClickMainMenuFullscreen event

  onClickSettingsBackToMenu: (event) ->
    @currentScreen @constructor.Screens.MainMenu
    
  onClickExtrasCourses: (event) ->
    @progress.show()
    
  onClickExtrasCredits: (event) ->
    LM.Menu.Credits.show()
    
  onClickExtrasBackToMenu: (event) ->
    @goToMainMenu()
