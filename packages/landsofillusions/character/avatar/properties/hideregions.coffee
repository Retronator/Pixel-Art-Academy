LOI = LandsOfIllusions

class LOI.Character.Avatar.Properties.HideRegions extends LOI.Character.Part.Property
  # node
  #   fields
  #     {regionId}: ID of the region that isn't being rendered when this property is set
  #       value: dummy 'true' value
  constructor: (@options = {}) ->
    super arguments...

    @type = 'hideRegions'

    return unless @options.dataLocation

  regionIds: ->
    hideRegionsNode = @options.dataLocation()
    fields = hideRegionsNode?.data()?.fields or {}
    
    regionId for regionId of fields

  addRegionId: (regionId) ->
    @_updateHideRegionsPart null, regionId

  replaceRegionId: (oldRegionId, newRegionId) ->
    @_updateHideRegionsPart oldRegionId, newRegionId

  removeRegionId: (regionId) ->
    @_updateHideRegionsPart regionId

  _updateHideRegionsPart: (oldRegionId, newRegionId) ->
    hideRegionsNode = @options.dataLocation()

    if hideRegionsNode
      hideRegionsNode newRegionId, true if newRegionId
      hideRegionsNode oldRegionId, null if oldRegionId

    else if newRegionId
      @options.dataLocation
        "#{newRegionId}": true
