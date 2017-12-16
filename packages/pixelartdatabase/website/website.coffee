AM = Artificial.Mummification
PADB = PixelArtDatabase

class PADB.Website extends AM.Document
  # url: link of the website
  # name: name of the website
  # featuredInRetronatorDaily: boolean if shown on Retronator Daily frontpage
  # preview: image preview of the website frontpage
  #   url: link to the image on our assets server
  @id: -> 'PixelArtDatabase.Website'

  @Meta
    name: @id()

  # Methods

  @insert: @method 'insert'
  @update: @method 'update'
  @renderPreview: @method 'renderPreview'

  # Subscriptions

  @all: @subscription 'all'
