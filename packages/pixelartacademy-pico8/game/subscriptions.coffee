AE = Artificial.Everywhere
LOI = LandsOfIllusions
PAA = PixelArtAcademy

PAA.Pico8.Game.all.publish ->
  PAA.Pico8.Game.getPublishingDocuments().find()

PAA.Pico8.Game.forSlug.publish (slug) ->
  check slug, String

  PAA.Pico8.Game.getPublishingDocuments().find {slug}
