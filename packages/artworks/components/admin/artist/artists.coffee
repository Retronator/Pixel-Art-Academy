AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Artworks.Components.Admin.Artists extends PAA.Pages.Admin.Components.AdminPage
  constructor: ->
    super
      documentClass: PAA.Artworks.Artist
      adminComponentClass: PAA.Artworks.Components.Admin.Artist
      nameField: 'displayName'
      subscriptionName: 'artworksAllArtists'
      insertMethodName: 'artistInsert'
      singularName: 'artist'
      pluralName: 'artists'
