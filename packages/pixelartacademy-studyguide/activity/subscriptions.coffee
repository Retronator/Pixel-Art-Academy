AB = Artificial.Base
AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

PAA.StudyGuide.Activity.all.publish ->
  PAA.StudyGuide.Activity.documents.find {},
    fields:
      article: false

PAA.StudyGuide.Activity.articleForActivityId.publish (id) ->
  check id, Match.DocumentId

  PAA.StudyGuide.Activity.documents.find id,
    fields:
      article: true
