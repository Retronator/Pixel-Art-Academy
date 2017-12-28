AM = Artificial.Mirage
AB = Artificial.Base

class Retropolis.City
  constructor: ->
    AB.Router.addRoute 'retropolis.city/', @constructor.Pages.Layout, @constructor.Pages.Home

    @addAcademyOfArtPage 'retropolis.city/academy-of-art', @constructor.Pages.AcademyOfArt.Academy
    @addAcademyOfArtPage 'retropolis.city/academy-of-art/programs', @constructor.Pages.AcademyOfArt.Programs
    @addAcademyOfArtPage 'retropolis.city/academy-of-art/campus-life', @constructor.Pages.AcademyOfArt.CampusLife
    @addAcademyOfArtPage 'retropolis.city/academy-of-art/admissions', @constructor.Pages.AcademyOfArt.Admissions
    @addAcademyOfArtPage 'retropolis.city/academy-of-art/application', @constructor.Pages.AcademyOfArt.Application

  addAcademyOfArtPage: (url, page) ->
    AB.Router.addRoute url, @constructor.Pages.AcademyOfArt.Layout, page
