AB = Artificial.Base
PAA = PixelArtAcademy

class PAA.StudyGuide
  @Goals: {}
  @Tasks: {}

  constructor: ->
    Retronator.App.addAdminPage '/admin/studyguide', @constructor.Pages.Admin
    Retronator.App.addAdminPage '/admin/studyguide/activities/:activityId?', @constructor.Pages.Admin.Activities
    Retronator.App.addAdminPage '/admin/studyguide/books/:documentId?', @constructor.Pages.Admin.Books
    @addStudyGuidePage 'retropolis.city/academy-of-art/study-guide/:pageOrBook?/:activity?', @constructor.Pages.Home

  addStudyGuidePage: (url, page) ->
    AB.Router.addRoute url, @constructor.Pages.Layout, page
