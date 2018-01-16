AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions
RA = Retronator.Accounts

# This is the web app that runs all Retronator websites.
class Retronator.App extends Artificial.Base.App
  @register 'Retronator.App'
  template: -> 'Retronator.App'

  # Routing helpers for default layouts

  @addPublicPage: (url, pageClass) ->
    AB.Router.addRoute url, @Layouts.PublicAccess, pageClass

  @addUserPage: (url, pageClass) ->
    AB.Router.addRoute url, @Layouts.UserAccess, pageClass

  @addAdminPage: (url, pageClass) ->
    AB.Router.addRoute url, @Layouts.AdminAccess, pageClass
    
  constructor: ->
    super

    # Instantiate all app packages, which register router URLs.
    new Artificial.Pages
    new Retronator.Accounts
    new Retronator.Store
    new Retronator.Blog
    new PixelArtAcademy.LandingPage
    new PixelArtDatabase
    new PixelArtDatabase.PixelDailies
    new LOI.Assets
    new LOI.Construct.Pages
    new LOI.World
    new Retropolis.City

    # Add adventure pages last so they capture all remaining URLs.
    new PixelArtAcademy
    new Retronator.HQ.Pages
    new LOI

    AB.Router.initialize()

    @components = {}

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
  Meteor.startup ->
    new Retronator.App()
