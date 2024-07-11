AE = Artificial.Everywhere
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
Pinball = PAA.Pixeltosh.Programs.Pinball

class Pinball.Assets
  class @Asset extends PAA.Practice.Project.Asset.Bitmap
    @restrictedPaletteName: -> LOI.Assets.Palette.SystemPaletteNames.Macintosh
    
    @backgroundColor: -> new THREE.Color '#edddb5'
    
  class @Ball extends @Asset
    @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Ball'
    
    @displayName: -> "Ball"
    
    @description: -> """
      A ball that bounces around the pinball playfield.
      Must be shaped as a circle to indicate a sphere that can roll around.
    """
    
    @fixedDimensions: -> width: 7, height: 7
    
    @imageUrls: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/ball.png'
    
    @initialize()
  
  class @Plunger extends @Asset
    @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Plunger'
    
    @displayName: -> "Plunger"
    
    @description: -> """
      A spring-loaded rod that pushes the ball along the shooter lane.
    """
    
    @fixedDimensions: -> width: 15, height: 30
    
    @imageUrls: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/plunger.png'
    
    @initialize()
  
  class @Playfield extends @Asset
    @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Playfield'
    
    @displayName: -> "Playfield"
    
    @description: -> """
      The pinball machine surface with walls and ball guides.
      Painted parts of your drawing (black or white) will obstruct the ball, unpainted (erased) will let the ball roll freely.
    """

    @fixedDimensions: -> width: 180, height: 200
    
    @imageUrls: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/ballguides.png'
    
    @initialize()

  class @GobbleHole extends @Asset
    @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.GobbleHole'

    @displayName: -> "Gobble hole"

    @description: -> """
      A hole in the playfield that scores points if the ball falls in.
      Use a black outline and any color on the inside.
      You can make it any shape, as big or small as you want.
    """

    @fixedDimensions: -> width: 50, height: 50
  
    @imageUrls: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/gobblehole.png'
    
    @initialize()

  class @BallTrough extends @Asset
    @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.BallTrough'

    @displayName: -> "Ball trough"

    @description: -> """
      A hole that ends the ball without gaining points.
      Like the gobble hole, it can be any shape.
    """

    @fixedDimensions: -> width: 100, height: 50

    @imageUrls: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/balltrough.png'
    
    @initialize()

  class @Bumper extends @Asset
    @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Bumper'

    @displayName: -> "Bumper"

    @description: -> """
      Draw the top of a mushroom-shaped target. It works best as a circle.
    """
    
    @fixedDimensions: -> width: 30, height: 30
    
    @imageUrls: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/bumper.png'
    
    @pixelArtEvaluation: -> true
    
    @initialize()
    
    @properties: ->
      pixelArtScaling: true
      pixelArtEvaluation: {}

  class @Gate extends @Asset
    @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Gate'

    @displayName: -> "Gate"

    @description: -> """
      A flap door or wire barrier that will rotate around the top.
      Draw it in front view, big enough to obstruct the ball.
    """

    @fixedDimensions: -> width: 20, height: 20
    
    @imageUrls: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/gate.png'
    
    @initialize()

  class @Flipper extends @Asset
    @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.Flipper'

    @displayName: -> "Flipper"

    @description: -> """
      The most iconic part of pinball! Draw the left flipper in its resting state.
      It will rotate around the 7th pixel counted diagonally from the top-left corner.
    """

    @fixedDimensions: -> width: 30, height: 30
    
    @imageUrls: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/flipper.png'
    
    @initialize()

  class @SpinningTarget extends @Asset
    @id: -> 'PixelArtAcademy.Pixeltosh.Programs.Pinball.SpinningTarget'

    @displayName: -> "Spinning target"

    @description: -> """
      A metal plate that spins around the center of the drawing when the ball passes through.
    """

    @fixedDimensions: -> width: 20, height: 20
    
    @imageUrls: -> '/pixelartacademy/pixeltosh/programs/pinball/parts/spinningtarget.png'
    
    @initialize()
