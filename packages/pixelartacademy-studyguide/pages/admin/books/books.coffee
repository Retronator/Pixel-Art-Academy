AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.StudyGuide.Pages.Admin.Books extends Artificial.Mummification.Admin.Components.AdminPage
  @id: -> 'PixelArtAcademy.StudyGuide.Pages.Admin.Books'
  @register @id()

  constructor: ->
    super
      documentClass: PAA.StudyGuide.Book
      adminComponentClass: PAA.StudyGuide.Pages.Admin.Books.Book
      nameField: 'title'
      singularName: 'book'
      pluralName: 'books'

  onCreated: ->
    super arguments...

    PAA.StudyGuide.Activity.initializeAll @
