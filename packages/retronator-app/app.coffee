AE = Artificial.Everywhere
AM = Artificial.Mirage
AT = Artificial.Telepathy
LOI = LandsOfIllusions

FlowRouter.wait()

# This is the web app that runs all Retronator websites.
class Retronator.App extends Artificial.Base.App
  @register 'Retronator.App'
  template: -> 'Retronator.App'

  constructor: ->
    super

    # Instantiate all app packages, which register router URLs.
    new Retronator.Accounts
    new Retronator.Store
    new PixelArtAcademy.LandingPage

    # Add Lands of Illusions last so it captures all remaining URLs.
    new LOI

    BlazeLayout.setRoot '.retronator-app'

    FlowRouter.initialize()
    window.FlowRouter = FlowRouter

    @components = {}

  onRendered: ->
    super

    $('#__blaze-root').remove()

  addComponent: (component) ->
    @components[component.componentName()] = component

  removeComponent: (component) ->
    delete @components[component.componentName()]

  update: (appTime) ->
    for name, component of @components
      component.update? appTime

  draw: (appTime) ->
    for name, component of @components
      component.draw? appTime
