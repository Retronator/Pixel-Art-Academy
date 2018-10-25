AM = Artificial.Mummification
PADB = PixelArtDatabase

class PADB.Article extends AM.Document
  # url: link to the article
  # title: title of the article
  # author: the artist who wrote the article
  #   _id
  #   displayName
  @id: -> 'PixelArtDatabase.Article'

  @Meta
    name: @id()
    fields: =>
      author: Document.ReferenceField PADB.Artist, ['displayName'], false
