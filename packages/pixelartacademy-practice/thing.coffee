AE = Artificial.Everywhere
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.Practice.Thing extends LOI.Adventure.Thing
  content: -> throw new AE.NotImplementedException "A practice thing must specify which content it represents."

  assets: -> null # Override if the practice thing provides assets directly.
  
  assetsProviders: -> null # Override if the practice thing provides multiple assets providers.

  activeAssetsProvider: -> null # Override to specify which of the assets providers is active.

  activateAssetsProvider: (assetsProvider) -> # Override to specify that an assets provider should be activated.
  
  canDeactivateAssetsProvider: -> # Override when the active assets provider can be deactivated.
  
  deactivateAssetsProvider: -> # Override to specify that the active assets provider should be deactivated.
  
  createNewAssetsProvider: -> # Override to create a new assets provider.
