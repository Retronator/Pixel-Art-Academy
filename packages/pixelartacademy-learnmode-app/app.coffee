AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LM = PixelArtAcademy.LearnMode

# This is the web app that runs all Retronator websites.
class LM.App extends Artificial.Base.App
  @id: -> 'PixelArtAcademy.LearnMode.App'
  @register @id()
  
  template: -> @constructor.id()
  
  @version: -> '0.1.0'
  
  buildName: -> 'Learn Mode build'

  # Routing helpers for default layouts

  @addPublicPage: (url, pageClass) ->
    AB.Router.addRoute url, LM.Layouts.PublicAccess, pageClass
  
  constructor: ->
    super arguments...
    
    # We manually add the Learn Mode route without a domain to point to Learn Mode
    # so we can access it without etc.hosts modifications on standalone clients.
    LM.App.addPublicPage '/:parameter1?/:parameter2?/:parameter3?/:parameter4?/:parameter5?', LM.Adventure
  
    AB.Router.initialize()

# On the server, the component will not be created through rendering so we simply instantiate it here.
if Meteor.isServer
  Meteor.startup ->
    new LM.App()
