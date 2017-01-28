AM = Artificial.Mummification
PADB = PixelArtDatabase

class PADB.Article extends AM.Document
  # url: link to the profile
  # title: display name of the artist on the platform
  # author: the artist who wrote the article
  #   _id
  #   displayName
  @id: -> 'PixelArtDatabase.Article'

  @Meta
    name: @id()
    fields: =>
      artist: @ReferenceField PADB.Artist, ['displayName'], false
