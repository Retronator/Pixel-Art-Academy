AB = Artificial.Base
AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

Delta = require 'quill-delta'

PAA.Publication.Part.insert.method ->
  LOI.Authorize.admin()
  
  # Create the new part.
  PAA.Publication.Part.documents.insert {}

PAA.Publication.Part.update.method (partId, data) ->
  check partId, Match.DocumentId
  check data,
    referenceId: Match.OptionalOrNull String

  LOI.Authorize.admin()

  part = PAA.Publication.Part.documents.findOne partId
  throw new AE.ArgumentException "Part does not exist." unless part

  # Update the part with new data.
  PAA.Publication.Part.documents.update partId, $set: data

PAA.Publication.Part.remove.method (partId) ->
  check partId, Match.DocumentId

  LOI.Authorize.admin()

  part = PAA.Publication.Part.documents.findOne partId
  throw new AE.ArgumentException "Part does not exist." unless part

  # Remove the part.
  PAA.Publication.Part.documents.remove partId

PAA.Publication.Part.updateArticle.method (partId, updateDeltaOperations) ->
  check partId, Match.DocumentId
  check updateDeltaOperations, Array
  LOI.Authorize.admin()

  part = PAA.Publication.Part.documents.findOne partId
  throw new AE.ArgumentException "Part does not exist." unless part

  contentDelta = new Delta part.article or [insert: '\n']
  updateDelta = new Delta updateDeltaOperations
  newContentDelta = contentDelta.compose updateDelta

  # Update the text.
  PAA.Publication.Part.documents.update partId,
    $set:
      article: newContentDelta.ops
