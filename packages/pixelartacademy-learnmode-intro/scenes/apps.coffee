LOI = LandsOfIllusions
PAA = PixelArtAcademy
LM = PixelArtAcademy.LearnMode

class LM.Intro.Apps extends LOI.Adventure.Scene
  @id: -> 'PixelArtAcademy.LearnMode.Intro.Apps'

  @location: -> PAA.PixelPad.Apps

  @initialize()
  
  things: -> [
    PAA.PixelPad.Apps.Drawing if PAA.Learning.Goal.getAdventureInstanceForId(LM.Intro.Tutorial.Goals.ToDoTasks.id())?.completed()
    PAA.PixelPad.Apps.Pico8 if LM.Intro.pico8Enabled()
  ]
