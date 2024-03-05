AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Programs.Program extends LOI.Adventure.Thing
  @fullName: -> throw new AE.NotImplementedException "A program must provide its name."

  @programSlug: -> throw new AE.NotImplementedException "A program must provide the game slug."
  @projectClass: -> null # Override to provide the project class if this program can be modified.
