AM = Artificial.Mirage
FM = FataMorgana

class FM.View extends AM.Component
  constructor: ->
    super arguments...

  onCreated: ->
    super arguments...

    @interface = @ancestorComponentOfType FM.Interface

    if dataFields = @constructor.dataFields?()
      data = @data()
      
      for dataField in dataFields
        @[dataField] = data.child(dataField).value
