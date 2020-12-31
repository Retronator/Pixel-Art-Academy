LOI = LandsOfIllusions
HQ = Retronator.HQ

Vocabulary = LOI.Parser.Vocabulary

class HQ.GalleryWest.Artworks extends LOI.Adventure.Item
  @id: -> 'Retronator.HQ.GalleryWest.Artworks'
  @fullName: -> "artworks"
  @descriptiveName: -> "Framed pixel art ![works](look at artworks)."
  @description: ->
    "
      Big and small pixel art works are hanging on the walls of the gallery.
    "

  @initialize()
