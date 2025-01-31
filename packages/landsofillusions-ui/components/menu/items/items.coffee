AB = Artificial.Base
AE = Artificial.Everywhere
AM = Artificial.Mirage
AEc = Artificial.Echo
LOI = LandsOfIllusions
Persistence = Artificial.Mummification.Document.Persistence

class LOI.Components.Menu.Items extends LOI.Component
  @id: -> 'LandsOfIllusions.Components.Menu.Items'
  @register @id()

  @Screens =
    MainMenu: 'MainMenu'
    Settings: 'Settings'
    Display: 'Display'
    Audio: 'Audio'
    MusicEffectsSettings: 'MusicEffectsSettings'
    Controls: 'Controls'
    Permissions: 'Permissions'
    Extras: 'Extras'
    
  @Audio = new LOI.Assets.Audio.Namespace @id(),
    variables:
      hover:
        valueType: AEc.ValueTypes.Trigger
        throttle: 35
      click: AEc.ValueTypes.Trigger

  constructor: (@options = {}) ->
    super arguments...

    @currentScreen = new ReactiveField @constructor.Screens.MainMenu

  aboutVisible: ->
    # About is visible on the landing page.
    @options.landingPage

  pressVisible: ->
    # Same as about.
    @aboutVisible()

  smallprintVisible: ->
    # Always shown.
    true

  newVisible: ->
    # New game is visible only on the landing page.
    @options.landingPage

  continueVisible: ->
    # Continue is visible when we're not on the landing page.
    not @options.landingPage

  loadVisible: ->
    # Load game is visible if the profile hasn't been saved yet.
    not LOI.adventure.profile()?.hasSyncing()

  saveVisible: ->
    # Save game is visible when an unsaved profile isn't on the landing page.
    return if LOI.adventure.profile()?.hasSyncing()

    not @options.landingPage

  accountVisible: ->
    # Account is visible for logged in users.
    Retronator.user()

  quitVisible: ->
    # Quit is visible when you are not on the landing page or if you're logged in.
    not @options.landingPage or Retronator.user()

  inMainMenu: ->
    @currentScreen() is @constructor.Screens.MainMenu

  inSettings: ->
    @currentScreen() is @constructor.Screens.Settings
  
  inDisplay: ->
    @currentScreen() is @constructor.Screens.Display
    
  inAudio: ->
    @currentScreen() is @constructor.Screens.Audio
    
  inMusicEffectsSettings: ->
    @currentScreen() is @constructor.Screens.MusicEffectsSettings
  
  inAudioSubmenus: ->
    @inAudio() or @inMusicEffectsSettings()
  
  inControls: ->
    @currentScreen() is @constructor.Screens.Controls

  inPermissions: ->
    @currentScreen() is @constructor.Screens.Permissions
    
  inExtras: ->
    @currentScreen() is @constructor.Screens.Extras
    
  goToMainMenu: ->
    @currentScreen @constructor.Screens.MainMenu

  isFullscreen: ->
    AM.Window.isFullscreen()

  audioEnabled: ->
    LOI.settings.audio.enabled.value()
    
  mainVolume: ->
    LOI.settings.audio.mainVolume.value()
    
  soundVolume: ->
    LOI.settings.audio.soundVolume.value()

  ambientVolume: ->
    LOI.settings.audio.ambientVolume.value()
  
  musicVolume: ->
    LOI.settings.audio.musicVolume.value()

  crtEmulation: ->
    LOI.settings.graphics.crtEmulation.value()

  slowCPUEmulation: ->
    LOI.settings.graphics.slowCPUEmulation.value()

  smoothShading: ->
    LOI.settings.graphics.smoothShading.value()

  graphicsMaximumScale: ->
    LOI.settings.graphics.maximumScale.value()
    
  graphicsScale: ->
    Math.min @graphicsMaximumScale() or 2, LOI.adventure.interface.highestAvailableScale()
  
  canIncreaseGraphicsScale: ->
    @graphicsScale() < LOI.adventure.interface.highestAvailableScale()

  rightClick: ->
    LOI.settings.controls.rightClick.value()
    
  permissionsPersistSettings: ->
    @_permissionsValue LOI.settings.persistSettings

  permissionsPersistGameState: ->
    @_permissionsValue LOI.settings.persistGameState

  permissionsPersistCommandHistory: ->
    @_permissionsValue LOI.settings.persistCommandHistory

  permissionsPersistLogin: ->
    @_permissionsValue LOI.settings.persistLogin

  _permissionsValue: (consentField) ->
    if consentField.decided() then consentField.allowed() else null

  events: ->
    super(arguments...).concat
      'mouseenter .actionable': @onMouseEnterActionable
      'click .actionable': @onClickActionable
      'click .back-to-settings': @onClickBackToSettings

      # Main menu
      'click .main-menu .continue': @onClickMainMenuContinue
      'click .main-menu .new': @onClickMainMenuNew
      'click .main-menu .load': @onClickMainMenuLoad
      'click .main-menu .save': @onClickMainMenuSave
      'click .main-menu .account': @onClickMainMenuAccount
      'click .main-menu .fullscreen': @onClickMainMenuFullscreen
      'click .main-menu .settings': @onClickMainMenuSettings
      'click .main-menu .quit': @onClickMainMenuQuit

      # Settings
      'click .settings .display': @onClickSettingsDisplay
      'click .settings .audio': @onClickSettingsAudio
      'click .settings .controls': @onClickSettingsControls
      'click .settings .permissions': @onClickSettingsPermissions
      'click .settings .back-to-menu': @onClickSettingsBackToMenu
      
      # Display
      'click .display .graphics-scale .previous-button': @onClickDisplayGraphicsScalePreviousButton
      'click .display .graphics-scale .next-button': @onClickDisplayGraphicsScaleNextButton
      'click .display .crt-emulation': @onClickDisplayCRTEmulation
      'click .display .slow-cpu-emulation': @onClickDisplaySlowCPUEmulation
      'click .display .smooth-shading': @onClickDisplaySmoothShading
    
      # Audio
      'click .audio .enabled': @onClickAudioEnabled
      'input .audio .main-volume': @onInputAudioMainVolume
      'input .audio .sound-volume': @onInputAudioSoundVolume
      'input .audio .ambient-volume': @onInputAudioAmbientVolume
      'input .audio .music-volume': @onInputAudioMusicVolume
      
      # Controls
      'click .controls .right-click': @onClickControlsRightClick

      # Permissions
      'click .permissions .persist-settings': @onClickPermissionsPersistSettings
      'click .permissions .persist-game-state': @onClickPermissionsPersistGameState
      'click .permissions .persist-command-history': @onClickPermissionsPersistCommandHistory
      'click .permissions .persist-login': @onClickPermissionsPersistLogin
  
  onMouseEnterActionable: (event) ->
    @audio.hover() unless @_justClicked
    
  onClickActionable: (event) ->
    @audio.click()
    
    @_justClicked = true
    
    Meteor.setTimeout =>
      @_justClicked = false
    ,
      100

  onClickMainMenuContinue: (event) ->
    LOI.adventure.menu.hideMenu()

  onClickMainMenuNew: (event) ->
    # Scroll down to help the player understand they should scroll down to begin.
    LOI.adventure.interface.narrative.scroll()

  onClickMainMenuLoad: (event) ->
    if @options.landingPage
      # On the landing page we can directly load.
      @_loadGame()
  
    else
      # Warn user they will lose progress.
      dialog = new LOI.Components.Dialog
        message: "You will lose current game progress if you load another game."
        buttons: [
          text: "Continue"
          value: true
        ,
          text: "Cancel"
        ]

      LOI.adventure.showActivatableModalDialog
        dialog: dialog
        callback: =>
          @_loadGame() if dialog.result
          
  _loadGame: ->
    LOI.adventure.menu.loadGame.show()

  onClickMainMenuSave: (event) ->
    LOI.adventure.menu.saveGame.show()

  onClickMainMenuAccount: (event) ->
    LOI.adventure.menu.account.show()

  onClickMainMenuFullscreen: (event) ->
    if AM.Window.isFullscreen()
      AM.Window.exitFullscreen()
      LOI.settings.graphics.preferFullscreen.value false

    else
      AM.Window.enterFullscreen()
      LOI.settings.graphics.preferFullscreen.value true

  onClickMainMenuSettings: (event) ->
    @currentScreen @constructor.Screens.Settings

    # Store current state of settings.
    @_oldSettings = LOI.settings.toObject()

  onClickMainMenuQuit: (event) ->
    if Retronator.user()
      LOI.adventure.quitGame()

    else
      # Notify the player that they will lose the current game state.
      dialog = new LOI.Components.Dialog
        message: "You will lose current game progress if you quit."
        buttons: [
          text: "Quit"
          value: true
        ,
          text: "Cancel"
        ]

      LOI.adventure.showActivatableModalDialog
        dialog: dialog
        callback: =>
          LOI.adventure.quitGame() if dialog.result

  onClickSettingsDisplay: (event) ->
    @currentScreen @constructor.Screens.Display
    
  onClickSettingsAudio: (event) ->
    @currentScreen @constructor.Screens.Audio
  
  onClickSettingsControls: (event) ->
    @currentScreen @constructor.Screens.Controls

  onClickAudioEnabled: (event) ->
    switch LOI.settings.audio.enabled.value()
      when LOI.Settings.Audio.Enabled.Off
        # Fullscreen option is only available in the browser.
        if AB.ApplicationEnvironment.isBrowser
          value = LOI.Settings.Audio.Enabled.Fullscreen
          
        else
          value = LOI.Settings.Audio.Enabled.On
        
      when LOI.Settings.Audio.Enabled.Fullscreen
        value = LOI.Settings.Audio.Enabled.On
      
      when LOI.Settings.Audio.Enabled.On
        value = LOI.Settings.Audio.Enabled.Off

    LOI.settings.audio.enabled.value value
    
  onInputAudioMainVolume: (event) ->
    @_changeVolume 'main', event
    
  onInputAudioSoundVolume: (event) ->
    @_changeVolume 'sound', event
    
    # Give audio feedback to indicate loudness of the sounds.
    @audio.click()
  
  onInputAudioAmbientVolume: (event) ->
    @_changeVolume 'ambient', event
    
  onInputAudioMusicVolume: (event) ->
    @_changeVolume 'music', event
    
  _changeVolume: (property, event) ->
    value = parseFloat $(event.target).val()
    LOI.settings.audio["#{property}Volume"].value value
  
  onClickDisplayGraphicsScalePreviousButton: (event) ->
    currentValue = @graphicsScale()
    currentValue--
    currentValue = null if currentValue < 2

    LOI.settings.graphics.maximumScale.value currentValue

  onClickDisplayGraphicsScaleNextButton: (event) ->
    currentValue = if LOI.settings.graphics.maximumScale.value() then @graphicsScale() else 1
    currentValue++

    LOI.settings.graphics.maximumScale.value currentValue

  onClickDisplayCRTEmulation: (event) ->
    crtEmulationValue = LOI.settings.graphics.crtEmulation.value
    crtEmulationValue not crtEmulationValue()
  
  onClickDisplaySlowCPUEmulation: (event) ->
    slowCPUEmulationValue = LOI.settings.graphics.slowCPUEmulation.value
    slowCPUEmulationValue not slowCPUEmulationValue()
    
  onClickDisplaySmoothShading: (event) ->
    smoothShadingValue = LOI.settings.graphics.smoothShading.value
    smoothShadingValue not smoothShadingValue()

  onClickControlsRightClick: (event) ->
    switch LOI.settings.controls.rightClick.value()
      when LOI.Settings.Controls.RightClick.None
        value = LOI.Settings.Controls.RightClick.Eraser
        
      when LOI.Settings.Controls.RightClick.Eraser
        value = LOI.Settings.Controls.RightClick.BackButton
      
      when LOI.Settings.Controls.RightClick.BackButton
        value = LOI.Settings.Controls.RightClick.None

    LOI.settings.controls.rightClick.value value
    
  onClickSettingsPermissions: (event) ->
    @currentScreen @constructor.Screens.Permissions

  onClickSettingsBackToMenu: (event) ->
    if LOI.settings.persistSettings.decided()
      # User already decided if they want to save settings so just return to menu.
      @goToMainMenu()

    else
      # See if settings have changed and ask to save.
      newSettings = LOI.settings.toObject()

      if EJSON.equals @_oldSettings, newSettings
        # Settings haven't changed, so no need to save.
        @goToMainMenu()

      else
        # Settings have changed. Ask to save and return to menu when answered.
        LOI.settings.persistSettings.showDialog =>
          @currentScreen @constructor.Screens.MainMenu

  onClickPermissionsPersistSettings: (event) ->
    @_onClickPermissions LOI.settings.persistSettings

  onClickPermissionsPersistGameState: (event) ->
    @_onClickPermissions LOI.settings.persistGameState

  onClickPermissionsPersistCommandHistory: (event) ->
    @_onClickPermissions LOI.settings.persistCommandHistory

  onClickPermissionsPersistLogin: (event) ->
    if LOI.settings.persistLogin.allowed()
      LOI.settings.persistLogin.disallow()

      # Also delete any login info.
      Accounts._autoLoginEnabled = false
      
      LOI.adventure.clearLoginInformation()

    else
      LOI.settings.persistLogin.showDialog (value) =>
        Accounts._autoLoginEnabled = value
        Accounts._enableAutoLogin() if value

  _onClickPermissions: (consentField) ->
    if consentField.allowed()
      consentField.disallow()

    else
      consentField.showDialog()

  onClickBackToSettings: (event) ->
    @currentScreen @constructor.Screens.Settings
