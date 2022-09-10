AE = Artificial.Everywhere
AB = Artificial.Babel
PAA = PixelArtAcademy
LOI = LandsOfIllusions

class PAA.PixelBoy.Apps.Drawing.Portfolio.Asset
  displayName: -> throw new AE.NotImplementedException "You must specify the asset name."

  description: -> '' # Override to provide a description of the asset.

  styleClasses: -> '' # Override to provide a string with class names for styling the asset.

  editorStyleClasses: -> '' # Override to provide a string with class names for styling the surrounding editor.
  
  width: -> throw new AE.NotImplementedException "You must specify the asset width."
  height: -> throw new AE.NotImplementedException "You must specify the asset height."
  
  portfolioComponent: -> throw new AE.NotImplementedException "You must provide a component to render the asset in the portfolio."
  
  urlParameter: -> throw new AE.NotImplementedException "You must provide the URL parameter to identify this asset."

  ready: -> throw new AE.NotImplementedException "You must report when all asset's information is ready to be used."
