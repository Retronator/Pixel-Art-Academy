LOI = LandsOfIllusions

class LOI.Engine.RenderingRegion
  constructor: (@options) ->
    @id = @options.id
    
  getRegionIds: ->
    @options.multipleRegions or [@id]

  matchRegion: (regionOrRegionId) ->
    return unless regionOrRegionId
    
    myRegionIds = @getRegionIds()

    if _.isString regionOrRegionId
      regionId = regionOrRegionId
      otherRegionIds = [regionId]

    else
      region = regionOrRegionId
      otherRegionIds = region.options.multipleRegions or [region.id]
    
    _.intersection(myRegionIds, otherRegionIds).length
