PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Project.Thing extends LOI.Adventure.Thing
  assets: -> throw AE.NotImplementedException "Project must provide an array of asset instances currently active in the project."
