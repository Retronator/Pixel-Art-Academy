AB = Artificial.Base
LOI = LandsOfIllusions
PAA = PixelArtAcademy

class PAA.Pixeltosh.Program extends LOI.Adventure.Thing
  @fullName: -> throw new AE.NotImplementedException "A program must provide its name."

  @programSlug: -> throw new AE.NotImplementedException "A program must provide the game slug."
  @projectClass: -> null # Override to provide the project class if this program can be modified.
  
  @iconUrl: -> @versionedUrl "/pixelartacademy/pixeltosh/programs/#{@programSlug()}/icon.png"
  iconUrl: -> @constructor.iconUrl()

  constructor: (@os) ->
    super arguments...
    
  menuItems: -> # Override to supply the data used to display the menu when this program is active.
