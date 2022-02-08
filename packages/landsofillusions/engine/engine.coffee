LOI = LandsOfIllusions

class LOI.Engine
  @RenderLayers =
    # Note: We want the default layer 0 to be indirect because the PMREM generator only captures that one when generating from a scene.
    Indirect: 0
    FinalRender: 1

  @RenderLayerMasks =
    NonEmissive: (1 << @RenderLayers.Indirect) | (1 << @RenderLayers.FinalRender)
    GeometricLight: (1 << @RenderLayers.Indirect) | (1 << @RenderLayers.FinalRender)
