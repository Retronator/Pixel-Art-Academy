LOI = LandsOfIllusions

class LOI.Engine.RenderingRegion
  constructor: (@options) ->
    @id = @options.id

  matchRegion: (region) ->
    myRegionIds = @options.multipleRegions or [@id]
    otherRegionIds = region.options.multipleRegions or [region.id]
    
    _.intersection(myRegionIds, otherRegionIds).length
