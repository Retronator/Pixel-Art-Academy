PAA = PixelArtAcademy

Document.startup =>
  return if Meteor.settings.startEmpty
  
  PAA.Pico8.Game.documents.upsert slug: 'jungle',
    $set:
      slug: 'jungle'
      cartridge:
        url: '/packages/retronator_pixelartacademy-pico8-jungle/jungle.p8.png'
