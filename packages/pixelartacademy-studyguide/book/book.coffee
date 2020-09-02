AB = Artificial.Babel
AM = Artificial.Mummification
LOI = LandsOfIllusions
PAA = PixelArtAcademy

# A Study Guide book is a collection of Study Guide activities.
class PAA.StudyGuide.Book extends AM.Document
  @id: -> 'PixelArtAcademy.StudyGuide.Book'
  # title: the title of the book
  #   _id
  #   translations
  # contents: an array of items that are in this book
  #   order: the position of this item in the contents
  #   activity: an activity document that represents this item
  #     _id
  # design: object with properties that define the book's look
  #   size: the size at which to display the book at
  #     width: the width of the cover in pixels (max 320, the safe width)
  #     height: the height of the cover in pixels (any size)
  #     thickness: the thickness of the book in pixels (min 25)
  #   class: string of the CSS class (or classes) that define the look
  # position: where on the library desk does the book appear on
  #   groupIndex: which pile of books is it on, left to right
  #   groupOrder: where in the pile the book is, top to bottom
  @Meta
    name: @id()
    fields: =>
      title: Document.ReferenceField AB.Translation, ['translations'], false
      contents: [
        activity: Document.ReferenceField PAA.StudyGuide.Activity
      ]

  # Methods
  @insert: @method 'insert'
  @update: @method 'update'
  @remove: @method 'remove'

  @addContentItem: @method 'addContentItem'
  @updateContentItem: @method 'updateContentItem'
  @removeContentItem: @method 'removeContentItem'

  # Subscriptions
  @all: @subscription 'all'
