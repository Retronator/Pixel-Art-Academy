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
  
  createAssetsProvider: -> # Override to create a new assets provider.

  duplicateAssetsProvider: (assetsProvider, properties) -> # Override to duplicate the provided assets provider.

  deleteAssetsProvider: (assetsProvider, properties) -> # Override to duplicate the provided assets provider.

  nameAssetsProviderInstructions: -> # Override to provide the text used for naming an assets provider.
  nameAssetsProviderInstructionsTranslation: -> # Override to provide the translation governing the text.

  assetsProviderNamePlaceholder: -> # Override to provide placeholder text for the assets provider name.
  assetsProviderNamePlaceholderTranslation: -> # Override to provide the translation governing the placeholder text.

  defaultAssetsProviderName: -> # Override to provide the name displayed for an unnamed assets provider.
  defaultAssetsProviderNameTranslation: -> # Override to provide the translation governing the default name.

  newAssetsProviderPlaceholder: -> # Override to provide placeholder text for creating a new assets provider.
  newAssetsProviderPlaceholderTranslation: -> # Override to provide the translation governing the placeholder text.

  editAssetsProviderInstructions: -> # Override to provide the text used for editing an assets provider.
  editAssetsProviderInstructionsTranslation: -> # Override to provide the translation governing the text.

  duplicateAssetsProviderInstructions: -> # Override to provide the text used for duplicating an assets provider.
  duplicateAssetsProviderInstructionsTranslation: -> # Override to provide the translation governing the text.

  deleteAssetsProviderConfirmation: -> # Override to provide the text used for deleting an assets provider.
  deleteAssetsProviderConfirmationTranslation: -> # Override to provide the translation governing the text.

  assetsProviderLabelCategory: -> # Override to provide the category written on assets provider's label.
