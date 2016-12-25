LOI = LandsOfIllusions

Template.registerHelper 'image', (url) ->
  # See if the component we are in is a thing.
  thing = @ if @ instanceof LOI.Adventure.Thing

  # Check also parent components.
  thing ?= @ancestorComponentWith (component) => component instanceof LOI.Adventure.Thing

  unless thing
    console.warn "Image #{url} is used outside of a thing, so we can't apply a version."
    return url

  # Return the url with version added.
  thing.versionUrl url
