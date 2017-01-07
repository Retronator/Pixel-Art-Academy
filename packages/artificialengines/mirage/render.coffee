AE = Artificial.Everywhere
AM = Artificial.Mirage

class AM.Render extends BlazeComponent
  @register 'Render'

  renderContext: ->
    component = @currentData()
    return null unless component

    # We use a system of caching the rendered Blaze template, so we don't try to re-render a component (which leads to
    # an error of its own). However, we make sure that we're actually trying to include it in the same parent component.
    # This way we can avoid problems when components are rendered inside #foreach calls.
    if component._blazeTemplate and not component.isDestroyed()
      if component.isRendered() and (component.parentComponent() isnt @)
        console.error "Render component error for", component, "and it is created", component.isCreated(), "rendered", component.isRendered(), "destroyed", component.isDestroyed()
        console.error "The parent chain is:"
        console.error component while component = component.parentComponent()

        throw new AE.InvalidOperationException "We're trying to include a rendered component that we're not a parent of."

      return component._blazeTemplate

    component._blazeTemplate = component.renderComponent? @currentComponent()
