AE = Artificial.Everywhere
AM = Artificial.Mummification
PAA = PixelArtAcademy
LOI = LandsOfIllusions

TutorialBitmap = PAA.Practice.Tutorials.Drawing.Assets.TutorialBitmap

class TutorialBitmap.EphemeralStep extends TutorialBitmap.Step
  @preserveCompleted: -> true
  
  constructor: ->
    super arguments...
    
    @_solved = new ReactiveField false
    
  completed: ->
    return unless super arguments...
  
    @_solved()
  
  hasPixel: -> false
  solve: -> @_solved true
  
  reset: -> @solved false
