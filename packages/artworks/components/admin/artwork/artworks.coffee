AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Artworks.Components.Admin.Artworks extends PAA.Pages.Admin.Components.AdminPage
  constructor: ->
    super
      documentClass: PAA.Artworks.Artwork
      adminComponentClass: PAA.Artworks.Components.Admin.Artwork
      nameField: 'title'
      subscriptionName: 'artworksAllArtworks'
      insertMethodName: 'artworkInsert'
      singularName: 'artwork'
      pluralName: 'artworks'
