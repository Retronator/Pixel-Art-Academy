HQ = Retronator.HQ

class HQ.Pages
  constructor: ->
    # HQ domain also provides the adventure interface.
    Retronator.App.addPublicPage 'hq.retronator.com/:parameter1?/:parameter2?/:parameter3?/:parameter4?/:parameter5?', HQ.Adventure
