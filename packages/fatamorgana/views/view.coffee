AE = Artificial.Everywhere
AM = Artificial.Mirage
FM = FataMorgana

class FM.View extends AM.Component
  @id: -> throw new AE.NotImplementedException "Views must provide an id."
  id: -> @constructor.id()

  constructor: ->
    super arguments...

  onCreated: ->
    super arguments...

    @interface = @ancestorComponentOfType FM.Interface

    data = @data()
    @componentData = @interface.getComponentData @

    if dataFields = @constructor.dataFields?()
      for dataField in dataFields
        @[dataField] = data.child(dataField).value

    if dataFields = @constructor.dataFieldsWithDefaults?()
      for dataField, defaultValue of dataFields
        do (dataField, defaultValue) =>
          @[dataField] = new ComputedField =>
            @data().get(dataField) ? defaultValue

    if dataFields = @constructor.componentDataFieldsWithDefaults?()
      for dataField, defaultValue of dataFields
        do (dataField, defaultValue) =>
          @[dataField] = new ComputedField =>
            componentData.get(dataField) ? defaultValue
