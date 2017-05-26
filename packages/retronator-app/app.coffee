AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
RA = Retronator.Accounts

FlowRouter.wait()

# This is the web app that runs all Retronator websites.
class Retronator.App extends Artificial.Base.App
  @register 'Retronator.App'
  template: -> 'Retronator.App'

  # Routing helpers for default layouts

  @addPublicPage: (url, pageClass) ->
    AB.addRoute url, @Layouts.PublicAccess, pageClass

  @addUserPage: (url, pageClass) ->
    AB.addRoute url, @Layouts.UserAccess, pageClass

  @addAdminPage: (url, pageClass) ->
    AB.addRoute url, @Layouts.AdminAccess, pageClass
    
  constructor: ->
    super

    # Instantiate all app packages, which register router URLs.
    new Artificial.Pages
    new Retronator.Accounts
    new Retronator.Store
    new PixelArtAcademy
    new PixelArtAcademy.LandingPage
    new PixelArtDatabase
    new PixelArtDatabase.PixelDailies

    # Add Lands of Illusions last so it captures all remaining URLs.
    new LOI

    if Meteor.isClient
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

# On the server, the component will not be created through rendering so we simply instantiate it here.
if Meteor.isServer
  Meteor.startup =>
    new Retronator.App()
