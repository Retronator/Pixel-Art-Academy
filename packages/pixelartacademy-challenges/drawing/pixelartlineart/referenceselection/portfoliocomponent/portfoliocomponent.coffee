AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Challenges.Drawing.PixelArtLineArt.ReferenceSelection.PortfolioComponent extends AM.Component
  @register 'PixelArtAcademy.Challenges.Drawing.PixelArtLineArt.ReferenceSelection.PortfolioComponent'

  references: ->
    remainingDrawLineArtClasses = PAA.Challenges.Drawing.PixelArtLineArt.remainingDrawLineArtClasses()
    
    for drawLineArtClass in remainingDrawLineArtClasses[0...3] by -1
      binderScale = drawLineArtClass.binderScale()
      
      do (binderScale) =>
        scalePercentage = binderScale * 100
        offsetRangePercentage = 100 - scalePercentage
        
        width = Math.floor 52 * binderScale
        height = Math.floor 77 * binderScale
        
        pixelImageOptions:
          source: drawLineArtClass.referenceImageUrl()
          imageSmoothingEnabled: true
          targetSizeFit: AM.PixelImage.TargetSizeFitType.Contain
          targetWidth: => width
          targetHeight: => height
        style:
          bottom: "#{2 + Math.floor Math.random() * 2}rem"
          right: "calc(#{2 + Math.floor Math.random() * 2}rem + #{Math.random() * offsetRangePercentage}%)"
          width: "#{width}rem"
          height: "#{height}rem"
