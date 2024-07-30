AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

PAA.Music.Tape.all.publish ->
  PAA.Music.Tape.getPublishingDocuments().find()

PAA.Music.Tape.forId.publish (tapeId) ->
  check tapeId, Match.DocumentId
  
  PAA.Music.Tape.getPublishingDocuments().find _id: tapeId
