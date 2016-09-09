AM = Artificial.Mirage

class AM.Render extends BlazeComponent
  @register 'Render'

  renderContext: ->
    component = @currentData()
    component?.renderComponent?(@currentComponent()) or null
