AM = Artificial.Mirage
LOI = LandsOfIllusions
C3 = SanFrancisco.C3

class C3.Design.Terminal.Properties.HideRegions extends AM.Component
  @register 'SanFrancisco.C3.Design.Terminal.Properties.HideRegions'

  onCreated: ->
    super arguments...

    @property = @data()

  regionIds: ->
    property = @data()

    # Mark indices so we know which region ID is being edited.
    regionIds = for regionId in property.regionIds()
      {property, regionId}

    regionIds.push {property}

    regionIds

  class @RegionIdInput extends AM.DataInputComponent
    @register 'SanFrancisco.C3.Design.Terminal.Properties.HideRegions.RegionIdInput'

    constructor: ->
      super arguments...

      @type = AM.DataInputComponent.Types.Select

    options: ->
      options = [
        name: ''
        value: null
      ]

      for regionId in _.keys(LOI.HumanAvatar.Regions).sort()
        options.push
          name: regionId
          value: regionId

      options

    load: ->
      regionId = @data()
      regionId.regionId

    save: (value) ->
      regionId = @data()
      property = regionId.property

      oldRegionId = @load()

      if regionId.regionId
        if value.length
          # We're modifying a condition part.
          property.replaceRegionId oldRegionId, value

        else
          # We're removing the condition part.
          property.removeRegionId oldRegionId

      else
        # We're adding a new condition part.
        property.addRegionId value
