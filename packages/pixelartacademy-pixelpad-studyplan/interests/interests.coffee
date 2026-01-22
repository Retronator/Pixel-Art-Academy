AE = Artificial.Everywhere
AB = Artificial.Babel
AM = Artificial.Mirage
LOI = LandsOfIllusions
PAA = PixelArtAcademy
IL = Illustrapedia

StudyPlan = PAA.PixelPad.Apps.StudyPlan

class StudyPlan.Interests extends StudyPlan.BottomPanel
  @id: -> 'PixelArtAcademy.PixelPad.Apps.StudyPlan.Interests'
  @register @id()

  onCreated: ->
    super arguments...
    
    @currentInterests = new ComputedField =>
      IL.Interest.find interest for interest in LOI.adventure.currentInterests()
