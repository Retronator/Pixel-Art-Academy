PAA = PixelArtAcademy

Document.startup =>
  return if Meteor.settings.startEmpty
  
  PAA.Pico8.Game.documents.upsert slug: 'invasion',
    $set:
      slug: 'invasion'
      cartridge:
        url: '/packages/retronator_pixelartacademy-pico8-invasion/invasion.p8.png'
      assets: [
        id: PAA.Pico8.Cartridges.Invasion.Defender.id()
        x: 0
        y: 0
      ]
