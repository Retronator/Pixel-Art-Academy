AM = Artificial.Mirage
HQ = Retronator.HQ

class HQ.Items.Tablet.Apps.Menu extends HQ.Items.Tablet.OS.App
  @register 'Retronator.HQ.Items.Tablet.Apps.Menu'

  @id: -> 'Retronator.HQ.Items.Tablet.Apps.Menu'
  @url: -> 'menu'

  @fullName: -> "Spectrum OS Menu"
  @shortName: -> "Menu"

  @description: ->
    "
      Spectrum OS is the operating system running the Retronator Spectrum Tablet.
    "

  @showInMenu: -> false

  @initialize()

  apps: ->
    app for app in @options.tablet.apps.values() when app.constructor.showInMenu()

  appUrl: ->
    app = @currentData()
    app.constructor.fullUrl()
