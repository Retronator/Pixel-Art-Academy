AM = Artificial.Mirage
PAA = PixelArtAcademy

class PAA.PixelBoy.OS extends AM.Component
  @register 'PixelArtAcademy.PixelBoy.OS'

  constructor: ->
    super
    
    @apps = [
      new PAA.PixelBoy.Apps.Journal
      new PAA.PixelBoy.Apps.Calendar
    ]

    # Create a map for fast retrieval of apps by their url name.
    appsNameMap = _.object ([app.urlName(), app] for app in @apps)

    @currentApp = new ComputedField =>
      appUrlName = FlowRouter.getParam 'app'
      appsNameMap[appUrlName]

  renderCurrentApp: ->
    @currentApp()?.renderComponent(@currentComponent()) or null
