AE = Artificial.Everywhere
AM = Artificial.Mirage
AB = Artificial.Base
LM = PixelArtAcademy.LearnMode

# This is the web app that runs all Retronator websites.
class LM.App extends Artificial.Base.App
  @register 'PixelArtAcademy.LearnMode.App'
  template: -> 'PixelArtAcademy.LearnMode.App'

  # Routing helpers for default layouts

  @addPublicPage: (url, pageClass) ->
    AB.Router.addRoute url, @Layouts.PublicAccess, pageClass
  
  constructor: ->
    super arguments...
    
    # Instantiate all app packages, which register router URLs.
  
  # Component handlers
  
  onCreated: ->
    super arguments...
    
    # Create pixel scaling display.
    @display = new AM.Display
      safeAreaWidth: 320
      safeAreaHeight: 240
      maxDisplayWidth: 480
      maxDisplayHeight: 640
      minAspectRatio: 1 / 2
      maxAspectRatio: 2
      debug: false
      
    $('html').addClass 'pixelartacademy-learnmode'

# On the server, the component will not be created through rendering so we simply instantiate it here.
if Meteor.isServer
  Meteor.startup ->
    new LM.App()
