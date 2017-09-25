AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.PixelBoy extends AM.Component
  @register "PixelArtAcademy.PixelBoy"

  @title: (options) ->
    for appClass in @appClasses() when appClass.urlName() is options.app
      return "Pixel Art Academy // #{appClass.displayName()}"

  @appClasses: -> [
    PAA.PixelBoy.Apps.Journal
    PAA.PixelBoy.Apps.Calendar
  ]

  constructor: ->
    @apps = (new appClass for appClass in @constructor.appClasses())

    # Create a map for fast retrieval of apps by their url name.
    appsNameMap = _.fromPairs ([app.urlName(), app] for app in @apps)

    @currentApp = new ComputedField =>
      appUrlName = FlowRouter.getParam 'app'
      appsNameMap[appUrlName]

  onCreated: ->
    super

    @display = new AM.Display
      safeAreaWidth: 350
      safeAreaHeight: 350
      minScale: 2

  renderCurrentApp: ->
    @currentApp()?.renderComponent(@currentComponent()) or null
