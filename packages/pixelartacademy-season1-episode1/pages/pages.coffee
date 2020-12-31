E1 = PixelArtAcademy.Season1.Episode1

class E1.Pages
  constructor: ->
    Retronator.App.addAdminPage '/admin/pixelartacademy/episode1', @constructor.Admin
    Retronator.App.addAdminPage '/admin/pixelartacademy/episode1/admissions', @constructor.Admin.Admissions
    Retronator.App.addAdminPage '/admin/pixelartacademy/episode1/studygroups', @constructor.Admin.StudyGroups
