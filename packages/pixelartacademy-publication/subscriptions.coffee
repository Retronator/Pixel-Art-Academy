AB = Artificial.Base
AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

PAA.Publication.all.publish ->
  PAA.Publication.getPublishingDocuments().find()

PAA.Publication.forReferenceIds.publish (referenceIds) ->
  PAA.Publication.getPublishingDocuments().find
    referenceId: $in: referenceIds
