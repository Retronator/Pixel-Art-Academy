unless PixelArtAcademy
  class PixelArtAcademy

AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.PixelBoy extends AM.Component
  @register "LandsOfIllusions.PixelBoy"

  constructor: ->
    @apps = [
      new LOI.PixelBoy.Apps.Journal
      new LOI.PixelBoy.Apps.Calendar
    ]

    # Create a map for fast retrieval of apps by their url name.
    appsNameMap = _.fromPairs ([app.urlName(), app] for app in @apps)

    @currentApp = new ComputedField =>
      appUrlName = FlowRouter.getParam 'app'
      appsNameMap[appUrlName]

  renderCurrentApp: ->
    @currentApp()?.renderComponent(@currentComponent()) or null
