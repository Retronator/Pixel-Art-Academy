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
  partIds = for content in publication.contents then content.part._id
 
  partIds.push publication.coverPart._id if publication.coverPart

  PAA.Publication.Part.getPublishingDocuments().find _id: $in: partIds,

PAA.Publication.Part.articleForPart.publish (id) ->
  check id, Match.DocumentId

  PAA.Publication.Part.getPublishingDocuments().find id,
    fields:
      article: true
