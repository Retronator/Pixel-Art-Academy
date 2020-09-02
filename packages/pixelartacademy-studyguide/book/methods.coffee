AB = Artificial.Babel
AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

PAA.StudyGuide.Book.insert.method ->
  LOI.Authorize.admin()

  # Create the translation for the book's title.
  titleTranslationId = AB.Translation.documents.insert {}

  # Create the new book.
  PAA.StudyGuide.Book.documents.insert
    title:
      _id: titleTranslationId
    contents: []

PAA.StudyGuide.Book.update.method (bookId, data) ->
  check bookId, Match.DocumentId
  check data,
    'design.size.width': Match.OptionalOrNull Match.IntegerMax 320
    'design.size.height': Match.OptionalOrNull Match.Integer
    'design.size.thickness': Match.OptionalOrNull Match.IntegerMin 25
    'design.class': Match.OptionalOrNull String
    'position.groupIndex': Match.OptionalOrNull Match.NonNegativeInteger
    'position.groupOrder': Match.OptionalOrNull Number

  LOI.Authorize.admin()

  book = PAA.StudyGuide.Book.documents.findOne bookId
  throw new AE.ArgumentException "Book does not exist." unless book

  # Update the book with new data.
  PAA.StudyGuide.Book.documents.update bookId, $set: data

PAA.StudyGuide.Book.remove.method (bookId) ->
  check bookId, Match.DocumentId

  LOI.Authorize.admin()

  book = PAA.StudyGuide.Book.documents.findOne bookId
  throw new AE.ArgumentException "Book does not exist." unless book

  # Remove the book.
  PAA.StudyGuide.Book.documents.remove bookId

  # Clean up the translations.
  Artificial.Babel.Translation.documents.remove book.title._id

PAA.StudyGuide.Book.addContentItem.method (bookId, contentItemIndex) ->
  check bookId, Match.DocumentId
  check contentItemIndex, Match.Integer

  LOI.Authorize.admin()

  book = PAA.StudyGuide.Book.documents.findOne bookId
  throw new AE.ArgumentException "Book does not exist." unless book

  PAA.StudyGuide.Book.documents.update bookId,
    $push: contents: {}

PAA.StudyGuide.Book.updateContentItem.method (bookId, contentItemIndex, data) ->
  check bookId, Match.DocumentId
  check contentItemIndex, Match.Integer
  check data,
    order: Match.OptionalOrNull Number
    'activity._id': Match.OptionalOrNull Match.DocumentId

  LOI.Authorize.admin()

  book = PAA.StudyGuide.Book.documents.findOne bookId
  throw new AE.ArgumentException "Book does not exist." unless book
  throw new AE.ArgumentException "Content item does not exist." unless book.contents[contentItemIndex]

  # Prepend contents field to properties.
  $set = {}

  for property, value of data
    $set["contents.#{contentItemIndex}.#{property}"] = value

  PAA.StudyGuide.Book.documents.update bookId, {$set}

PAA.StudyGuide.Book.removeContentItem.method (bookId, contentItemIndex) ->
  check bookId, Match.DocumentId
  check contentItemIndex, Match.Integer

  LOI.Authorize.admin()

  book = PAA.StudyGuide.Book.documents.findOne bookId
  throw new AE.ArgumentException "Book does not exist." unless book
  throw new AE.ArgumentException "Content item does not exist." unless book.contents[contentItemIndex]

  book.contents.splice contentItemIndex, 1

  PAA.StudyGuide.Book.documents.update bookId,
    $set: contents: book.contents
