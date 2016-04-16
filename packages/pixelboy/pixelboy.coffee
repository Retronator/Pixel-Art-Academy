AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.PixelBoy extends AM.Component
  @register "PixelArtAcademy.PixelBoy"

  constructor: ->
    @apps = [
      new PAA.PixelBoy.Apps.Journal
      new PAA.PixelBoy.Apps.Calendar
    ]

    # Create a map for fast retrieval of apps by their url name.
    appsNameMap = _.object ([app.urlName(), app] for app in @apps)

    @currentApp = new ComputedField =>
      appUrlName = FlowRouter.getParam 'app'
      appsNameMap[appUrlName]

  onCreated: ->


  renderCurrentApp: ->
    @currentApp()?.renderComponent(@currentComponent()) or null
