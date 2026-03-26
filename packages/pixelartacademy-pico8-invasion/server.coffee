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
      ,
        id: PAA.Pico8.Cartridges.Invasion.DefenderProjectile.id()
        x: 4
        y: 0
      ,
        id: PAA.Pico8.Cartridges.Invasion.DefenderProjectileExplosion.id()
        x: 4
        y: 1
      ,
        id: PAA.Pico8.Cartridges.Invasion.Invader.id()
        x: 2
        y: 0
      ,
        id: PAA.Pico8.Cartridges.Invasion.InvaderProjectile.id()
        x: 5
        y: 0
      ,
        id: PAA.Pico8.Cartridges.Invasion.InvaderProjectileExplosion.id()
        x: 5
        y: 1
      ,
        id: PAA.Pico8.Cartridges.Invasion.Shield.id()
        x: 6
        y: 0
      ]
      labelImage:
        assets: [
          id: PAA.Pico8.Cartridges.Invasion.Defender.id()
          x: 56
          y: 76
        ,
          id: PAA.Pico8.Cartridges.Invasion.Invader.id()
          x: 16
          y: 24
        ,
          id: PAA.Pico8.Cartridges.Invasion.Invader.id()
          x: 100
          y: 36
        ]
