AE = Artificial.Everywhere
AM = Artificial.Mummification
AB = Artificial.Base
PAA = PixelArtAcademy
LM = PAA.LearnMode
LOI = LandsOfIllusions

# This is the web app that runs all Retronator websites.
class LM.App extends Artificial.Base.App
  @id: -> 'PixelArtAcademy.LearnMode.App'
  @register @id()
  
  template: -> @constructor.id()
  
  @version: -> '0.21.6'
  
  buildName: -> 'Learn Mode build'

  # Routing helpers for default layouts

  @addPublicPage: (url, pageClass) ->
    AB.Router.addRoute url, LM.Layouts.PublicAccess, pageClass
  
  constructor: ->
    super arguments...
  
    # Instantiate all app packages, which register router URLs.
    new Artificial.Pages
    new LOI.Assets
    new PAA.Pixeltosh
    new PAA.Practice
  
    # We manually add the Learn Mode route without a domain to point to Learn Mode
    # so we can access it without etc.hosts modifications on standalone clients.
    LM.App.addPublicPage '/:parameter1?/:parameter2?/:parameter3?/:parameter4?/:parameter5?', LM.Adventure
  
    AB.Router.initialize()
    
    if Meteor.isDesktop
      # Listen for cheats.
      Desktop.on 'menu', 'unlockPixelArtFundamentals', (event) =>
        LM.PixelArtFundamentals.state 'unlocked', true

# On the server, the component will not be created through rendering so we simply instantiate it here.
if Meteor.isServer
  Meteor.startup ->
    new LM.App()
