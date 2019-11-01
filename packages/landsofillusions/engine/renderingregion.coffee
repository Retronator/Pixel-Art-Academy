LOI = LandsOfIllusions

class LOI.Engine.RenderingRegion
  constructor: (@options) ->
    @id = @options.id
    
  getLandmarksRegionId: ->
    @id
    
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
      otherRegionIds = region.getRegionIds()

    _.intersection(myRegionIds, otherRegionIds).length
