AM = Artificial.Mirage
AB = Artificial.Base
LOI = LandsOfIllusions

class LOI.World
  constructor: ->
    @addPage 'landsofillusions.world/', @constructor.Pages.Home

    # Create the main adventure engine url capture.
    Retronator.App.addPublicPage 'landsofillusions.world/:parameter1/:parameter2?/:parameter3?/:parameter4?/:parameter5?', LOI.Adventure

  addPage: (url, page) ->
    AB.Router.addRoute url, @constructor.Pages.Layout, page
