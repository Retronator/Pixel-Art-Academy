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
    super arguments...

    # Wire the main admin pages.
    @constructor.addAdminPage '/admin', @constructor.Admin
    @constructor.addAdminPage '/admin/facts', @constructor.Admin.Facts

    # Instantiate all app packages, which register router URLs.
    new Artificial.Pages

    new Retronator.Accounts
    new Retronator.Store
    new Retronator.Blog

    new Illustrapedia

    new PixelArtAcademy.LandingPage
    new PixelArtAcademy.Practice
    new PixelArtAcademy.Pico8
    new PixelArtAcademy.Season1.Episode1.Pages
    new PixelArtAcademy.StudyGuide

    new PixelArtDatabase
    new PixelArtDatabase.PixelDailies

    new LOI
    new LOI.Assets
    new LOI.Construct.Pages

    new Retropolis.City

    # Add adventure pages last so they capture all remaining URLs.
    new PixelArtAcademy
    new Retronator.HQ.Pages
    new LOI.World

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

  endRun: (appTime) ->
    sortedComponents = _.sortBy @components, (component) => component.endRunOrder or 0

    for name, component of sortedComponents
      component.endRun? appTime

# On the server, the component will not be created through rendering so we simply instantiate it here.
if Meteor.isServer
  Meteor.startup ->
    new Retronator.App()
