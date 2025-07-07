PAA = PixelArtAcademy

Document.startup =>
  return if Meteor.settings.startEmpty
  
  PAA.Pico8.Game.documents.upsert slug: 'invasion',
    $set:
      slug: 'invasion'
      cartridge:
        url: '/packages/retronator_pixelartacademy-pico8-invasion/invasion.p8.png'
      assets: [
        id: PAA.Pico8.Cartridges.Invasion.Body.id()
        x: 0
        y: 0
      ,
        id: PAA.Pico8.Cartridges.Invasion.Food.id()
        x: 1
        y: 0
      ]
      labelImage:
        assets: [
          id: PAA.Pico8.Cartridges.Invasion.Body.id()
          x: 40
          y: 84
        ,
          id: PAA.Pico8.Cartridges.Invasion.Body.id()
          x: 48
          y: 84
        ,
          id: PAA.Pico8.Cartridges.Invasion.Body.id()
          x: 56
          y: 84
        ,
          id: PAA.Pico8.Cartridges.Invasion.Food.id()
          x: 80
          y: 84
        ]
