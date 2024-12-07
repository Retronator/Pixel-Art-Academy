AB = Artificial.Base
AM = Artificial.Mummification
PAA = PixelArtAcademy

class PAA.Publication extends AM.Document
  @id: -> 'PixelArtAcademy.Publication'
  # lastEditTime: the time the document was last edited
  # referenceId: custom ID to be used when referencing the publication from code
  # coverPart: a publication part document that represents the cover or null if no cover
  #   _id
  #   referenceId
  # tableOfContentsPart: a publication part document that represents the table of contents or null if no contents
  #   _id
  #   referenceId
  # contents: an array of items that are in this book
  #   order: the position of this item in the contents
  #   part: a publication part document that represents this item
  #     _id
  #     referenceId
  # design: object with properties that define the publication's look
  #   size: the size at which to display the book at
  #     width: the width of the cover in pixels (max 300)
  #     height: the height of the cover in pixels (any size)
  #   spreadPagesCount: how many pages are visible at the same time
  #   class: string of the CSS class (or classes) that define the look
  @Meta
    name: @id()
    fields: =>
      coverPart: Document.ReferenceField @Part, ['referenceId']
      tableOfContentsPart: Document.ReferenceField @Part, ['referenceId']
      contents: [
        part: Document.ReferenceField @Part, ['referenceId']
      ]
      
  @enableDatabaseContent()
  
  @databaseContentInformationFields =
    referenceId: 1
    
  # Methods
  @insert = @method 'insert'
  @update = @method 'update'
  @remove = @method 'remove'
  
  @removeCover = @method 'removeCover'
  @removeTableOfContents = @method 'removeTableOfContents'
  
  @addContentItem = @method 'addContentItem'
  @updateContentItem = @method 'updateContentItem'
  @removeContentItem = @method 'removeContentItem'

  # Subscriptions
  @all = @subscription 'all'
  @forReferenceIds = @subscription 'forReferenceIds'

  # Routing
  
  @initializeRouting: ->
    Artificial.Pages.addAdminPage '/admin/publication', @Pages.Admin
    Artificial.Pages.addAdminPage '/admin/publication/parts/:documentId?', @Pages.Admin.Parts
    Artificial.Pages.addAdminPage '/admin/publication/publications/:documentId?', @Pages.Admin.Publications

if Meteor.isServer
  # Export all publications and parts.
  AM.DatabaseContent.addToExport ->
    [
      PAA.Publication.documents.fetch(referenceId: $exists: true)...
      PAA.Publication.Part.documents.fetch(referenceId: $exists: true)...
    ]
