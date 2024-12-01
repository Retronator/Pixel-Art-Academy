AB = Artificial.Base
AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

PAA.Publication.Part.all.publish ->
  PAA.Publication.Part.getPublishingDocuments().find {},
    fields:
      article: false
      
PAA.Publication.Part.forPublication.publish (publicationId) ->
  check publicationId, Match.DocumentId
  
  return unless publication = PAA.Publication.getPublishingDocuments().findOne publicationId
  
  # Wait until the publication document gets substituted with the fully populated one.
  return unless publication.contents

  partIds = for content in publication.contents then content.part._id
 
  partIds.push publication.coverPart._id if publication.coverPart
  partIds.push publication.tableOfContentsPart._id if publication.tableOfContentsPart

  PAA.Publication.Part.getPublishingDocuments().find _id: $in: partIds,

PAA.Publication.Part.articleForPart.publish (id) ->
  check id, Match.DocumentId

  PAA.Publication.Part.getPublishingDocuments().find id,
    fields:
      article: true
