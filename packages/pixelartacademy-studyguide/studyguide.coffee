PAA = PixelArtAcademy

class PAA.StudyGuide
  @Goals: {}
  @Tasks: {}

  constructor: ->
    Retronator.App.addAdminPage '/admin/studyguide', @constructor.Pages.Admin
    Retronator.App.addAdminPage '/admin/studyguide/activities/:activityId?', @constructor.Pages.Admin.Activities
