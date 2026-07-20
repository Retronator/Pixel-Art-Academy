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
      sortField: 'referenceId'
      nameFunction: (publication) =>
        return publication._id unless publication.referenceId
        parts = publication.referenceId.split('.')
        publicationsPartIndex = _.indexOf parts, 'Publications'
        parts[publicationsPartIndex + 1..].join ' '
      singularName: 'publication'
      pluralName: 'publications'
      
  onCreated: ->
    super arguments...

    PAA.Publication.Part.all.subscribe @
