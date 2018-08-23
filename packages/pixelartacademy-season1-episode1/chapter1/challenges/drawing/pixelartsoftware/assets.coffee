LOI = LandsOfIllusions
PAA = PixelArtAcademy
C1 = PixelArtAcademy.Season1.Episode1.Chapter1
CopyReference = C1.Challenges.Drawing.PixelArtSoftware.CopyReference
PADB = PixelArtDatabase

assets =
  MSHMVVVVVV:
    dimensions: -> width: 10, height: 21
    backgroundColor: -> new THREE.Color '#000'
    imageName: -> 'mshm-vvvvvv'
    spriteInfo: -> """
      Artwork from [VVVVVV](https://thelettervsixtim.es), 2010

      Artist: Terry Cavanagh
    """
    artist:
      name:
        first: 'Terry'
        last: 'Cavanagh'
    artwork:
      completionDate:
        year: 2009

  MBHMLouBagelsWaffleBar:
    dimensions: -> width: 36, height: 49
    restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.black
    imageName: -> 'mbhm-loubagelswafflebar'
    spriteInfo: -> """
      Artwork from [Lou Bagel's Waffle Bar](https://loubagel.itch.io/lou-bagel-waffle-bar), 2018

      Artist: Chris Taylor
    """
    maxClipboardScale: -> 1.5
    artist:
      name:
        first: 'Chris'
        last: 'Taylor'
    artwork:
      completionDate:
        year: 2018

  CBEMIntoTheRift:
    dimensions: -> width: 30, height: 32
    imageName: -> 'cbem-intotherift'
    spriteInfo: -> """
      Artwork from [Into The Rift](http://www.starsoft.com/IntoTheRift/) (WIP)

      Artist: Weston Tracy
    """
    maxClipboardScale: -> 2.5
    artist:
      name:
        first: 'Weston'
        last: 'Tracy'
    artwork:
      completionDate:
        year: 2015

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
