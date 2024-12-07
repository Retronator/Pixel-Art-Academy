AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Publication.Part extends AM.Document
  @id: -> 'PixelArtAcademy.Publication.Part'
  # lastEditTime: the time the document was last edited
  # referenceId: custom ID to be used when referencing the part from code
  # title: the title of the part (as it appears in the table of contents) or null if not named
  # design: object with properties that define the part's look
  #   class: string of the CSS class (or classes) that define the look
  # [article]: array of delta operations for the article of this publication part
  #   insert: string or object to be inserted
  #     figure: a collection of visual elements with a caption
  #       layout: array of numbers controlling how many elements per row to show
  #       caption: the text written under the figure
  #       class: string of the CSS class (or classes) that define the look of the figure
  #       [elements]: array of elements that make the figure
  #         artwork: an artwork from the pixel art database
  #           _id
  #
  #         image: an image without any semantic information
  #           url
  #           credit: ad-hoc text crediting the image source
  #
  #         video: a video without any semantic information
  #           url
  #           credit: ad-hoc text crediting the video source
  #
  #   attributes: object with formatting directives
  @Meta
    name: @id()
    
  @enableDatabaseContent()

  # Methods
  @insert = @method 'insert'
  @update = @method 'update'
  @remove = @method 'remove'
  
  @removeTitle = @method 'removeTitle'

  @updateArticle = @method 'updateArticle'

  # Subscriptions
  @all = @subscription 'all'
  @forPublication = @subscription 'forPublication'
  @articleForPart = @subscription 'articleForPart'
