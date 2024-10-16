AB = Artificial.Babel
AM = Artificial.Mirage

# Component for choosing a country from a dropdown
class AB.Components.RegionSelection extends AM.DataInputComponent
  constructor: ->
    super arguments...

    @type = AM.DataInputComponent.Types.Select
    @allowDeselection = false

  onCreated: ->
    super arguments...

    # Subscribe to all regions and the translations of their names.
    AB.Region.all.subscribe @
    AB.Translation.forNamespace.subscribe @, 'Artificial.Babel.Region.Names'

    # Cache regions with their translations pulled in.
    @regions = new ComputedField =>
      for region in AB.Region.documents.find().fetch()
        region.name.refresh()
        region

    # Cache region name translations.
    @regionNames = new ComputedField =>
      for region in @regions()
        region: region
        name: region.name.translate(AB.languagePreference())?.text

  options: ->
    regionNames = _.sortBy @regionNames(), (regionName) => regionName.name

    if @regionList
      regionNames = _.filter regionNames, (regionName) => regionName.region.code in @regionList
      values = @regionList

    else
      values = (regionName.region.code for regionName in regionNames)

    options = for regionName in regionNames
      value: regionName.region.code
      name: regionName.name

    # Add an empty option if we don't have a match, or if we allow deselection.
    if @allowDeselection or @load() not in values
      options.unshift
        value: ''
        name: ''

    options
