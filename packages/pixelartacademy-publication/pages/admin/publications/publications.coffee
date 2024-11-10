AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Publication.Pages.Admin.Publications extends Artificial.Mummification.Admin.Components.AdminPage
  @id: -> 'PixelArtAcademy.Publication.Pages.Admin.Publications'
  @register @id()

  constructor: ->
    super
      documentClass: PAA.Publication
      adminComponentClass: PAA.Publication.Pages.Admin.Publications.Publication
      nameField: 'referenceId'
      singularName: 'publication'
      pluralName: 'publications'
      
  onCreated: ->
    super arguments...

    PAA.Publication.Part.all.subscribe @
