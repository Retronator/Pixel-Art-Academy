AM = Artificial.Mirage
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Challenges.Drawing.PixelArtLineArt.ReferenceSelection.PortfolioComponent extends AM.Component
  @register 'PixelArtAcademy.Challenges.Drawing.PixelArtLineArt.ReferenceSelection.PortfolioComponent'

  references: ->
    remainingDrawLineArtClasses = PAA.Challenges.Drawing.PixelArtLineArt.remainingDrawLineArtClasses()
    
    for drawLineArtClass in remainingDrawLineArtClasses[0...3] by -1
      pixelImageOptions:
        source: drawLineArtClass.referenceImageUrl()
        imageSmoothingEnabled: true
        targetSizeFit: AM.PixelImage.TargetSizeFitType.Contain
        targetWidth: => 52
        targetHeight: => 77
      style:
        bottom: "#{2 + Math.floor Math.random() * 2}rem"
        right: "#{2 + Math.floor Math.random() * 2}rem"
