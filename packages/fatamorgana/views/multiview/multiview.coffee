AM = Artificial.Mirage
FM = FataMorgana

class FM.MultiView extends FM.View
  # views: array of components to be rendered
  @id: -> 'FataMorgana.MultiView'
  @register @id()

  # We minimize reactivity by simply iterating over an array of indices.
  # TODO: If we used the type/componentId field, could this be improved even more?
  viewIndices: ->
    multiViewData = @data()
    count = multiViewData.get('views')?.length or 0
    [0...count]
    
  viewData:  ->
    index = @currentData()
    multiViewData = @data()
    multiViewData.child "views.#{index}"
