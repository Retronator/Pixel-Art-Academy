LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
CopyReference = C1.Challenges.Drawing.PixelArtSoftware.CopyReference
PADB = PixelArtDatabase

assets =
  MSHMNetherWorld:
    dimensions: -> width: 13, height: 16
    imageName: -> 'mshm-netherworld'
    spriteInfo: -> """
      Artwork from [NetherWorld](http://www.netherworldgame.com), WIP

      Artist: Isabel 'Erien' Armentero
    """
    maxClipboardScale: -> 5
    artist:
      name:
        first: 'Isabel'
        last: 'Armentero'
        nickname: 'Erien'
    artwork:
      title: 'Squid'
      completionDate:
        year: 2017

  MSHMDespotDungeons:
    dimensions: -> width: 12, height: 14
    backgroundColor: -> new THREE.Color '#1e1e1e'
    imageName: -> 'mshm-despotdungeons'
    spriteInfo: -> """
      Artwork from [Despot Dungeons](https://realfast.itch.io/despot-dungeons), 2017

      Artist: Hjalte Tagmose
    """
    maxClipboardScale: -> 5
    artist:
      name:
        first: 'Hjalte'
        last: 'Tagmose'
    artwork:
      title: 'Disenfranchised frog'
      completionDate:
        year: 2017

  MSEMDespotDungeons:
    dimensions: -> width: 11, height: 14
    backgroundColor: -> new THREE.Color '#1e1e1e'
    imageName: -> 'msem-despotdungeons'
    spriteInfo: -> """
      Artwork from [Despot Dungeons](https://realfast.itch.io/despot-dungeons), 2017

      Artist: Hjalte Tagmose
    """
    maxClipboardScale: -> 5
    artist:
      name:
        first: 'Hjalte'
        last: 'Tagmose'
    artwork:
      title: 'Ratman'
      completionDate:
        year: 2017

  MSEMLAbbayeDesMorts:
    dimensions: -> width: 15, height: 9
    restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.zxSpectrum
    backgroundColor: ->
      paletteColor:
        ramp: 0
        shade: 0
    imageName: -> 'msem-labbayedesmorts'
    spriteInfo: -> """
      Artwork from [l'Abbaye des Morts](https://www.locomalito.com/abbaye_des_morts.php), 2010

      Artist: Locomalito
    """
    artist:
      name:
        first: 'Juan'
        middle: 'Antonio'
        last: 'Becerra'
      pseudonym: 'Locomalito'
    artwork:
      title: 'Flying skull'
      completionDate:
        year: 2010

  MSVMLuftrauser:
    dimensions: -> width: 16, height: 14
    backgroundColor: -> new THREE.Color '#e5dcae'
    imageName: -> 'msvm-luftrauser'
    spriteInfo: -> """
      Artwork from [LUFTRAUSER](https://www.newgrounds.com/portal/view/573422), 2011

      Artist: Paul 'Pietepiet' Veer
    """
    artist:
      name:
        first: 'Paul'
        last: 'Veer'
        nickname: 'Pietepiet'
    artwork:
      title: 'Rauser'
      completionDate:
        year: 2011

  MSOMMidnightDungeon:
    dimensions: -> width: 6, height: 6
    backgroundColor: -> new THREE.Color '#000'
    imageName: -> 'msom-midnightdungeon'
    spriteInfo: -> """
      Artwork from [Midnight Dungeon](https://pixelartm.itch.io/midnight-dungeon), 2018

      Artist: Miguel 'PixelArtM' Sánchez
    """
    artist:
      name:
        first: 'Miguel'
        last: 'Sánchez'
        nickname: 'PixelArtM'
    artwork:
      title: 'Sword'
      completionDate:
        year: 2018

  MBHMLouBagelsWaffleBar:
    dimensions: -> width: 36, height: 49
    backgroundColor: -> new THREE.Color '#a394d2'
    imageName: -> 'mbhm-loubagelswafflebar'
    spriteInfo: -> """
      Artwork from [Lou Bagel's Waffle Bar](https://www.loubagel.com/arcade/), 2018

      Artist: Chris Taylor
    """
    maxClipboardScale: -> 1.5
    artist:
      name:
        first: 'Chris'
        last: 'Taylor'
    artwork:
      title: 'Bagel chef'
      completionDate:
        year: 2018

  MBHMVVVVVV:
    dimensions: -> width: 10, height: 21
    backgroundColor: -> new THREE.Color '#000'
    imageName: -> 'mbhm-vvvvvv'
    spriteInfo: -> """
      Artwork from [VVVVVV](https://thelettervsixtim.es), 2010

      Artist: Terry Cavanagh
    """
    artist:
      name:
        first: 'Terry'
        last: 'Cavanagh'
    artwork:
      title: 'Captain Viridian'
      completionDate:
        year: 2009

  MBEMSaboteurSiO:
    dimensions: -> width: 32, height: 46
    restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.zxSpectrum
    imageName: -> 'mbem-saboteursio'
    spriteInfo: -> """
      Artwork from [Saboteur SiO](http://www.clivetownsend.com), WIP

      Artist: Ricardo Oyón Rodríguez
    """
    maxClipboardScale: -> 1.5
    artist:
      name:
        first: 'Ricardo'
        middle: 'Oyón'
        last: 'Rodríguez'
    artwork:
      title: 'Bouncer'
      completionDate:
        year: 2018

  MBVMLuftrausers:
    dimensions: -> width: 59, height: 18
    backgroundColor: -> new THREE.Color '#e5ddac'
    imageName: -> 'mbvm-luftrausers'
    spriteInfo: -> """
      Artwork from [LUFTRAUSERS](http://luftrausers.com), 2014

      Artist: Roy Nathan de Groot
    """
    artist:
      name:
        first: 'Roy'
        middle: 'Nathan'
        lastPrefix: 'de'
        last: 'Groot'
    artwork:
      title: 'Boat'
      completionDate:
        year: 2014

  MBOMCityClickers:
    dimensions: -> width: 34, height: 22
    backgroundColor: -> new THREE.Color '#e8cda8'
    imageName: -> 'mbom-cityclickers'
    spriteInfo: -> """
      Artwork from [City Clickers](https://eigen.itch.io/city-clickers), 2017

      Artist: Eigen Lenk
    """
    artist:
      name:
        first: 'Eigen'
        last: 'Lenk'
    artwork:
      title: 'House'
      completionDate:
        year: 2017

  MBOMInventorious:
    dimensions: -> width: 19, height: 22
    backgroundColor: -> new THREE.Color '#250936'
    imageName: -> 'mbom-inventorious'
    spriteInfo: -> """
      Artwork from [Inventorious](https://placeholders.itch.io/inventorious), 2018

      Artist: Mati Ernst
    """
    maxClipboardScale: -> 3.5
    artist:
      name:
        first: 'Mati'
        last: 'Ernst'
    artwork:
      title: 'Necklace'
      completionDate:
        year: 2018

  CSHMCeleste:
    dimensions: -> width: 9, height: 7
    restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.pico8
    backgroundColor: ->
      paletteColor:
        ramp: 0
        shade: 0
    imageName: -> 'cshm-celeste'
    spriteInfo: -> """
      Artwork from [CELESTE Classic](https://mattmakesgames.itch.io/celesteclassic), 2015

      Artist: Noel Berry
    """
    artist:
      name:
        first: 'Noel'
        last: 'Berry'
    artwork:
      title: 'Madeline'
      completionDate:
        year: 2015

  CSEMHookLineAndThinker:
    dimensions: -> width: 7, height: 8
    restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.pico8
    backgroundColor: ->
      paletteColor:
        ramp: 1
        shade: 0
    imageName: -> 'csem-hooklineandthinker'
    spriteInfo: -> """
      Artwork from [Hook, Line and Thinker](https://rhythmlynx.itch.io/hook-line-and-thinker), 2016

      Artist: Connor Halford
    """
    artist:
      name:
        first: 'Connor'
        last: 'Halford'
    artwork:
      title: 'Crab'
      completionDate:
        year: 2016

  CSEMSuperCrateBox:
    dimensions: -> width: 8, height: 7
    imageName: -> 'csem-supercratebox'
    spriteInfo: -> """
      Artwork from [Super Crate Box](http://supercratebox.com), 2010

      Artist: Roy Nathan de Groot
    """
    artist:
      name:
        first: 'Roy'
        middle: 'Nathan'
        lastPrefix: 'de'
        last: 'Groot'
    artwork:
      title: 'Small flying skull'
      completionDate:
        year: 2010

  CSVMFroggi:
    dimensions: -> width: 16, height: 12
    restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.pico8
    backgroundColor: ->
      paletteColor:
        ramp: 0
        shade: 0
    imageName: -> 'csvm-froggi'
    spriteInfo: -> """
      Artwork from [Froggi](https://sophieh.itch.io/froggi), 2018

      Artist: Sophie Houlden
    """
    artist:
      name:
        first: 'Sophie'
        last: 'Houlden'
    artwork:
      title: 'Red sports car'
      completionDate:
        year: 2018

  CSOMTheWakingCloak:
    dimensions: -> width: 16, height: 16
    imageName: -> 'csom-thewakingcloak'
    spriteInfo: -> """
      Artwork from [The Waking Cloak](http://www.thewakingcloak.com), WIP

      Artist: Daniel Müller
    """
    maxClipboardScale: -> 5
    artist:
      name:
        first: 'Daniel'
        last: 'Müller'
    artwork:
      title: 'Staff of Moonlight'
      completionDate:
        year: 2018

  CBHMFez:
    dimensions: -> width: 13, height: 18
    backgroundColor: -> new THREE.Color '#251635'
    imageName: -> 'cbhm-fez'
    spriteInfo: -> """
      Artwork from [FEZ](http://www.fezgame.com), 2012

      Artist: Phil Fish
    """
    maxClipboardScale: -> 4.5
    artist:
      name:
        first: 'Phil'
        last: 'Fish'
    artwork:
      title: 'Gomez'
      completionDate:
        year: 2009

  CBHMOwlboy:
    dimensions: -> width: 19, height: 38
    imageName: -> 'cbhm-owlboy'
    spriteInfo: -> """
      Artwork from [Owlboy](http://www.owlboygame.com), 2016

      Artist: Simon Stafsnes 'Snake' Andersen
    """
    maxClipboardScale: -> 2
    artist:
      name:
        first: 'Simon'
        middle: 'Stafsnes'
        last: 'Andersen'
        nickname: 'Snake'
    artwork:
      title: 'Otus'
      completionDate:
        year: 2008

  CBHMCourierOfTheCrypts:
    dimensions: -> width: 15, height: 19
    imageName: -> 'cbhm-courierofthecrypts'
    spriteInfo: -> """
      Artwork from [Courier of the Crypts](http://www.courierofthecrypts.com), WIP

      Artist: Primož Vovk
    """
    maxClipboardScale: -> 4
    artist:
      name:
        first: 'Primož'
        last: 'Vovk'
    artwork:
      title: 'Courier'
      completionDate:
        year: 2014

  CBHMNYKRA:
    dimensions: -> width: 9, height: 23
    imageName: -> 'cbhm-nykra'
    spriteInfo: -> """
      Artwork from [NYKRA](http://nykra.com), WIP

      Artist: Seth 'ENDESGA' Groom
    """
    maxClipboardScale: -> 3.5
    artist:
      name:
        first: 'Seth'
        last: 'Groom'
        nickname: 'ENDESGA'
    artwork:
      title: 'Keu'
      completionDate:
        year: 2015

  CBEMSuperCrateBox:
    dimensions: -> width: 19, height: 18
    imageName: -> 'cbem-supercratebox'
    spriteInfo: -> """
      Artwork from [Super Crate Box](http://supercratebox.com), 2010

      Artist: Roy Nathan de Groot
    """
    maxClipboardScale: -> 4.5
    artist:
      name:
        first: 'Roy'
        middle: 'Nathan'
        lastPrefix: 'de'
        last: 'Groot'
    artwork:
      title: 'Big green skull'
      completionDate:
        year: 2010

  CBEMIntoTheRift:
    dimensions: -> width: 30, height: 32
    imageName: -> 'cbem-intotherift'
    spriteInfo: -> """
      Artwork from [Into The Rift](http://www.starsoft.com/IntoTheRift/), WIP

     Artist: Weston Tracy
    """
    maxClipboardScale: -> 2.5
    artist:
      name:
        first: 'Weston'
        last: 'Tracy'
    artwork:
      title: 'Archer'
      completionDate:
        year: 2015

  CBEMKingdomNewLands:
    dimensions: -> width: 12, height: 21
    imageName: -> 'cbem-kingdomnewlands'
    spriteInfo: -> """
      Artwork from [Kingdom: New Lands](http://www.kingdomthegame.com), 2015

      Artist: Thomas van den Berg
    """
    maxClipboardScale: -> 3.5
    artist:
      name:
        first: 'Thomas'
        lastPrefix: 'van den'
        last: 'Berg'
    artwork:
      title: 'Greedling'
      completionDate:
        year: 2015

  CBEMDontGiveUpACynicalTale:
    dimensions: -> width: 22, height: 25
    imageName: -> 'cbem-dontgiveupacynicaltale'
    spriteInfo: -> """
      Artwork from [DON'T GIVE UP: A Cynical Tale](https://trisbee.itch.io/dont-give-up-a-cynical-tale), WIP

      Artist: Tristan Barona
    """
    maxClipboardScale: -> 3
    artist:
      name:
        first: 'Tristan'
        last: 'Barona'
    artwork:
      title: 'Ted Tantrums'
      completionDate:
        year: 2017

  CBVMIntoTheBreach:
    dimensions: -> width: 31, height: 31
    imageName: -> 'cbvm-intothebreach'
    spriteInfo: -> """
      Artwork from [Into The Breach](https://subsetgames.com/itb.html), 2018

      Artist: Justin Ma
    """
    maxClipboardScale: -> 2.5
    artist:
      name:
        first: 'Justin'
        last: 'Ma'
    artwork:
      title: 'Rift Walkers Combat Mech'
      completionDate:
        year: 2017

  CBVMHydorah:
    dimensions: -> width: 23, height: 8
    backgroundColor: -> new THREE.Color '#000'
    imageName: -> 'cbvm-hydorah'
    spriteInfo: -> """
      Artwork from [Hydorah](https://www.locomalito.com/hydorah.php), 2010

      Artist: Locomalito
    """
    artist:
      name:
        first: 'Juan'
        middle: 'Antonio'
        last: 'Becerra'
      pseudonym: 'Locomalito'
    artwork:
      title: 'Spaceship'
      completionDate:
        year: 2010

  CBOMVirtuaVerse:
    dimensions: -> width: 31, height: 23
    imageName: -> 'cbom-virtuaverse'
    spriteInfo: -> """
      Artwork from [VirtuaVerse](https://www.facebook.com/virtuaversegame), WIP

      Artist: Ra 'Valenberg' Mei
    """
    artist:
      name:
        first: 'Ra'
        last: 'Mei'
        nickname: 'Valenberg'
    artwork:
      title: 'Pizza Amore'
      completionDate:
        year: 2017

  CBOMThimbleweedPark:
    dimensions: -> width: 32, height: 18
    backgroundColor: -> new THREE.Color '#001e51'
    imageName: -> 'cbom-thimbleweedpark'
    spriteInfo: -> """
      Artwork from [Thimbleweed Park](https://thimbleweedpark.com), 2017

      Artist: Gary Winnick
    """
    artist:
      name:
        first: 'Gary'
        last: 'Winnick'
    artwork:
      title: 'Balloon animal'
      completionDate:
        year: 2014

for assetId, asset of assets
  do (assetId, asset) ->
    class CopyReference[assetId] extends CopyReference
      @id: -> "PixelArtAcademy.Season1.Episode1.Chapter1.Challenges.Drawing.PixelArtSoftware.CopyReference.#{assetId}"
      @fixedDimensions: asset.dimensions
      @backgroundColor: asset.backgroundColor or -> null
      # Note: we don't override restrictedPaletteName since we expect the function to exist.
      @restrictedPaletteName: asset.restrictedPaletteName or -> null
      @imageName: asset.imageName
      @spriteInfo: asset.spriteInfo
      @maxClipboardScale: asset.maxClipboardScale
      @initialize()

    # On the server also create PADB entries.
    if Meteor.isServer
      Document.startup =>
        referenceUrl = "/pixelartacademy/season1/episode1/chapter1/challenges/drawing/pixelartsoftware/#{asset.imageName()}-reference.png"

        unless PADB.Artwork.forUrl.query(referenceUrl).count()
          artwork = _.extend {}, asset.artwork,
            type: PADB.Artwork.Types.Image
            image:
              url: "/pixelartacademy/season1/episode1/chapter1/challenges/drawing/pixelartsoftware/#{asset.imageName()}.png"
            representations: [
              type: PADB.Artwork.RepresentationTypes.Image
              url: referenceUrl
            ]
            
          PADB.create
            artist: asset.artist
            artworks: [artwork]
