AE = Artificial.Everywhere
PAA = PixelArtAcademy
LOI = LandsOfIllusions

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class TutorialBitmap.Resource.Pixels extends TutorialBitmap.Resource
  pixels: -> throw new AE.NotImplementedException "A pixels resource has to return a list of pixels."
  ready: -> @pixels()?
