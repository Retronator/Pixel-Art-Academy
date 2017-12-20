AM = Artificial.Mummification
PADB = PixelArtDatabase

class PADB.Website extends AM.Document
  # url: link of the website
  # name: name of the website
  @id: -> 'PixelArtDatabase.Website'

  @Meta
    name: @id()

  # Methods

  @insert: @method 'insert'
  @update: @method 'update'

  # Subscriptions

  @all: @subscription 'all'
