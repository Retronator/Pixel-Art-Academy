AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Publication.Part extends AM.Document
  @id: -> 'PixelArtAcademy.Publication.Part'
  # referenceId: custom ID to be used when referencing the part from code
  # [article]: array of delta operations for the article of this publication part
  #   insert: string or object to be inserted
  #     figure: a collection of visual elements with a caption
  #       layout: array of numbers controlling how many elements per row to show
  #       caption: the text written under the figure
  #       [elements]: array of elements that make the figure
  #         artwork: an artwork from the pixel art database
  #           _id
  #
  #         image: an image without any semantic information
  #           url
  #
  #         video: a video without any semantic information
  #           url
  #
  #   attributes: object with formatting directives
  @Meta
    name: @id()

  # Methods
  @insert = @method 'insert'
  @update = @method 'update'
  @remove = @method 'remove'

  @updateArticle = @method 'updateArticle'

  # Subscriptions
  @all = @subscription 'all'
  @forPublication = @subscription 'forPublicationId'
  @articleForPart = @subscription 'articleForPartId'
