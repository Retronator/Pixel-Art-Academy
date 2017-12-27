AM = Artificial.Mirage
AB = Artificial.Base

class Retropolis.City
  constructor: ->
    AB.Router.addRoute 'retropolis.city/', @constructor.Pages.Layout, @constructor.Pages.Home

    @addAcademyOfArtPage 'retropolis.city/academy-of-art', @constructor.Pages.AcademyOfArt.Home

  addAcademyOfArtPage: (url, page) ->
    AB.Router.addRoute url, @constructor.Pages.AcademyOfArt.Layout, page
