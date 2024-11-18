AB = Artificial.Babel
AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

PAA.Publication.insert.method ->
  LOI.Authorize.admin()

  # Create the new publication.
  PAA.Publication.documents.insert
    contents: []

PAA.Publication.update.method (publicationId, data) ->
  check publicationId, Match.DocumentId
  check data,
    referenceId: Match.OptionalOrNull String
    'coverPart._id': Match.OptionalOrNull Match.DocumentId
    'tableOfContentsPart._id': Match.OptionalOrNull Match.DocumentId
    'design.size.width': Match.OptionalOrNull Match.IntegerMax 300
    'design.size.height': Match.OptionalOrNull Match.Integer
    'design.spreadPagesCount': Match.OptionalOrNull Match.PositiveInteger
    'design.class': Match.OptionalOrNull String
    'position.groupIndex': Match.OptionalOrNull Match.NonNegativeInteger
    'position.groupOrder': Match.OptionalOrNull Number

  LOI.Authorize.admin()

  publication = PAA.Publication.documents.findOne publicationId
  throw new AE.ArgumentException "Publication does not exist." unless publication

  # Update the publication with new data.
  PAA.Publication.documents.update publicationId, $set: data
  
PAA.Publication.removeCover.method (publicationId) ->
  check publicationId, Match.DocumentId

  LOI.Authorize.admin()

  PAA.Publication.documents.update publicationId,
    $unset:
      coverPart: 1

PAA.Publication.removeTableOfContents.method (publicationId) ->
  check publicationId, Match.DocumentId
  
  LOI.Authorize.admin()
  
  PAA.Publication.documents.update publicationId,
    $unset:
      tableOfContentsPart: 1

PAA.Publication.remove.method (publicationId) ->
  check publicationId, Match.DocumentId

  LOI.Authorize.admin()

  publication = PAA.Publication.documents.findOne publicationId
  throw new AE.ArgumentException "Publication does not exist." unless publication

  # Remove the publication.
  PAA.Publication.documents.remove publicationId

PAA.Publication.addContentItem.method (publicationId, partId) ->
  check publicationId, Match.DocumentId
  check partId, Match.DocumentId

  LOI.Authorize.admin()

  publication = PAA.Publication.documents.findOne publicationId
  throw new AE.ArgumentException "Publication does not exist." unless publication

  activities = _.sortBy publication.contents, 'order'
  order = _.last(activities)?.order or 0

  part = PAA.Publication.Part.documents.findOne partId
  throw new AE.ArgumentException "Part does not exist." unless part

  PAA.Publication.documents.update publicationId,
    $push:
      contents:
        part:
          _id: partId
        order: order

PAA.Publication.updateContentItem.method (publicationId, contentItemIndex, data) ->
  check publicationId, Match.DocumentId
  check contentItemIndex, Match.Integer
  check data,
    order: Match.OptionalOrNull Number
    'part._id': Match.OptionalOrNull Match.DocumentId

  LOI.Authorize.admin()

  publication = PAA.Publication.documents.findOne publicationId
  throw new AE.ArgumentException "Publication does not exist." unless publication
  throw new AE.ArgumentException "Content item does not exist." unless publication.contents[contentItemIndex]

  if partId = data['part._id']
    part = PAA.Publication.Part.documents.findOne partId
    throw new AE.ArgumentException "Part does not exist." unless part

  # Prepend contents field to properties.
  $set = {}

  for property, value of data
    $set["contents.#{contentItemIndex}.#{property}"] = value

  PAA.Publication.documents.update publicationId, {$set}

PAA.Publication.removeContentItem.method (publicationId, contentItemIndex) ->
  check publicationId, Match.DocumentId
  check contentItemIndex, Match.Integer

  LOI.Authorize.admin()

  publication = PAA.Publication.documents.findOne publicationId
  throw new AE.ArgumentException "Publication does not exist." unless publication
  throw new AE.ArgumentException "Content item does not exist." unless publication.contents[contentItemIndex]

  publication.contents.splice contentItemIndex, 1

  PAA.Publication.documents.update publicationId,
    $set: contents: publication.contents
