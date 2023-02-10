AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LM = PixelArtAcademy.LearnMode

console.log "APP CLASS DEFINITION", Meteor.isServer, Meteor.isCordova, Meteor.isDesktop

onDeviceReady = ->
  console.log "console.log works well", Meteor.isServer, Meteor.isCordova, Meteor.isDesktop
  
if Meteor.isClient
  document.addEventListener "deviceready", onDeviceReady, false

Meteor.startup ->
  console.log "MET START APP", Meteor.isServer, Meteor.isCordova, Meteor.isDesktop
  

# This is the web app that runs all Retronator websites.
class LM.App extends Artificial.Base.App
  @register 'PixelArtAcademy.LearnMode.App'
  template: -> 'PixelArtAcademy.LearnMode.App'

  # Routing helpers for default layouts

  @addPublicPage: (url, pageClass) ->
    AB.Router.addRoute url, @Layouts.PublicAccess, pageClass

  @addUserPage: (url, pageClass) ->
    AB.Router.addRoute url, @Layouts.UserAccess, pageClass

  @addAdminPage: (url, pageClass) ->
    AB.Router.addRoute url, @Layouts.AdminAccess, pageClass
    
  constructor: ->
    super arguments...

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
  
  inTranslationMode: ->
    if Artificial.Babel.inTranslationMode() then "ON" else "OFF"
    
  translations: ->
    Artificial.Babel.Translation.documents.fetch()
    
  events: ->
    super(arguments...).concat
      'click .translation-mode-button': @onClickTranslationMode
      'click .rename-button': @onClickRenameButton
      
  onClickTranslationMode: (event) ->
    Artificial.Babel.inTranslationMode not Artificial.Babel.inTranslationMode()
    
  onClickRenameButton: (event) ->
    return unless translation = @translation "TEST"
    
    Artificial.Babel.Translation.update translation._id, "en-us", Random.id()
  

# On the server, the component will not be created through rendering so we simply instantiate it here.
if Meteor.isServer
  Meteor.startup ->
    new LM.App()
