AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Assets
  class @Ball extends PAA.Practice.Project.Asset.Bitmap
    @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Ball'
    
    @displayName: -> "Ball"
    
    @description: -> """
        A ball that bounces around the pinball playfield.
      """
    
    @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Macintosh
    
    @initialize()
  
  class @Playfield extends PAA.Practice.Project.Asset.Bitmap
    @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Playfield'
    
    @displayName: -> "Playfield"
    
    @description: -> """
        The pinball table surface with various ball guides and ramps.
      """
    
    @fixedDimensions: -> width: 180, height: 200
    @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Macintosh
    
    @initialize()
