AM = Artificial.Mirage
FM = FataMorgana

class FM.View extends AM.Component
  constructor: ->
    super arguments...

  onCreated: ->
    super arguments...

    @interface = @ancestorComponentOfType FM.Interface
