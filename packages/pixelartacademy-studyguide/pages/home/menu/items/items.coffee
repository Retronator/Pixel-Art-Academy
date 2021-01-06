AE = Artificial.Everywhere
AM = Artificial.Mirage
RA = Retronator.Accounts
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StudyGuide.Pages.Home.Menu.Items extends AM.Component
  @register 'PixelArtAcademy.StudyGuide.Pages.Home.Menu.Items'

  @Screens:
    MainMenu: 'MainMenu'
    UserSelection: 'UserSelection'
    Settings: 'Settings'
    Permissions: 'Permissions'

  constructor: (@menu) ->
    super arguments...

    @currentScreen = new ReactiveField @constructor.Screens.MainMenu

  inMainMenu: ->
    @currentScreen() is @constructor.Screens.MainMenu

  inUserSelection: ->
    @currentScreen() is @constructor.Screens.UserSelection

  inSettings: ->
    @currentScreen() is @constructor.Screens.Settings

  isFullscreen: ->
    AM.Window.isFullscreen()

  graphicsMaximumScale: ->
    LOI.settings.graphics.maximumScale.value()

  inPermissions: ->
    @currentScreen() is @constructor.Screens.Permissions

  permissionsPersistSettings: ->
    @_permissionsValue LOI.settings.persistSettings

  permissionsPersistGameState: ->
    @_permissionsValue LOI.settings.persistGameState

  permissionsPersistLogin: ->
    @_permissionsValue LOI.settings.persistLogin

  _permissionsValue: (consentField) ->
    if consentField.decided() then consentField.allowed() else null

  events: ->
    super(arguments...).concat
      # Main menu
      'click .continue': @onClickContinue
      'click .sign-in': @onClickSignIn
      'click .user-selection': @onClickUserSelection
      'click .account': @onClickAccount
      'click .fullscreen': @onClickFullscreen
      'click .settings': @onClickSettings
      'click .sign-out': @onClickSignOut

      # User selection
      'click .select-user': @onClickSelectUser
      'click .select-character': @onClickSelectCharacter
      'click .user-selection-back-to-menu': @onClickUserSelectionBackToMenu

      # Settings
      'click .graphics-scale .previous-button': @onClickGraphicsScalePreviousButton
      'click .graphics-scale .next-button': @onClickGraphicsScaleNextButton
      'click .permissions': @onClickPermissions
      'click .settings-back-to-menu': @onClickSettingsBackToMenu

      # Permissions
      'click .permissions-persist-settings': @onClickPermissionsPersistSettings
      'click .permissions-persist-game-state': @onClickPermissionsPersistGameState
      'click .permissions-persist-login': @onClickPermissionsPersistLogin
      'click .back-to-settings': @onClickBackToSettings

  # Main menu

  onClickContinue: (event) ->
    @menu.hideMenu()

  onClickSignIn: (event) ->
    @menu.home.signIn()

  onClickUserSelection: (event) ->
    @currentScreen @constructor.Screens.UserSelection

  onClickAccount: (event) ->
    @menu.account.show()

  onClickFullscreen: (event) ->
    if AM.Window.isFullscreen()
      AM.Window.exitFullscreen()

    else
      AM.Window.enterFullscreen()

  onClickSettings: (event) ->
    @currentScreen @constructor.Screens.Settings

    # Store current state of settings.
    @_oldSettings = LOI.settings.toObject()

  onClickSignOut: (event) ->
    # Clear character selection. We use undefined to remove the fields from local storage.
    LOI.switchCharacter undefined

    # Log out the user.
    Meteor.logout()

  # User selection

  onClickSelectUser: (event) ->
    LOI.switchCharacter undefined
    @currentScreen @constructor.Screens.MainMenu

  onClickSelectCharacter: (event) ->
    character = @currentData()
    LOI.switchCharacter character._id
    @currentScreen @constructor.Screens.MainMenu

  onClickUserSelectionBackToMenu: (event) ->
    @currentScreen @constructor.Screens.MainMenu

  # Settings

  onClickGraphicsScalePreviousButton: (event) ->
    currentValue = LOI.settings.graphics.maximumScale.value()
    currentValue--
    currentValue = null if currentValue < 2

    LOI.settings.graphics.minimumScale.value currentValue or 2
    LOI.settings.graphics.maximumScale.value currentValue

  onClickGraphicsScaleNextButton: (event) ->
    currentValue = LOI.settings.graphics.maximumScale.value() or 1
    currentValue++

    LOI.settings.graphics.minimumScale.value currentValue
    LOI.settings.graphics.maximumScale.value currentValue

  onClickPermissions: (event) ->
    @currentScreen @constructor.Screens.Permissions

  onClickSettingsBackToMenu: (event) ->
    returnToMenu = => @currentScreen @constructor.Screens.MainMenu

    if LOI.settings.persistSettings.decided()
      # User already decided if they want to save settings so just return to menu.
      returnToMenu()

    else
      # See if settings have changed and ask to save.
      newSettings = LOI.settings.toObject()

      if EJSON.equals @_oldSettings, newSettings
        # Settings haven't changed, so no need to save.
        returnToMenu()

      else
        # Settings have changed. Ask to save and return to menu when answered.
        LOI.settings.persistSettings.showDialog
          dialogProvider: @menu.layout
          callback: =>
            @currentScreen @constructor.Screens.MainMenu

  # Permissions

  onClickPermissionsPersistSettings: (event) ->
    @_onClickPermissions LOI.settings.persistSettings

  onClickPermissionsPersistGameState: (event) ->
    @_onClickPermissions LOI.settings.persistGameState

  onClickPermissionsPersistLogin: (event) ->
    if LOI.settings.persistLogin.allowed()
      LOI.settings.persistLogin.disallow()

      # Also delete any login info.
      Accounts._autoLoginEnabled = false
      
      RA.clearLoginInformation()

    else
      LOI.settings.persistLogin.showDialog
        dialogProvider: @menu.layout
        callback: (value) =>
          Accounts._autoLoginEnabled = value
          Accounts._enableAutoLogin() if value

  _onClickPermissions: (consentField) ->
    if consentField.allowed()
      consentField.disallow()

    else
      consentField.showDialog
        dialogProvider: @menu.layout

  onClickBackToSettings: (event) ->
    @currentScreen @constructor.Screens.Settings
