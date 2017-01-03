Template.registerHelper 'image', (url) ->
  component = BlazeComponent.currentComponent()

  # See if the component we are in is a thing.
  versionedComponent = component if component.version?()

  # Check also parent components.
  versionedComponent ?= component.ancestorComponentWith (ancestorComponent) => ancestorComponent.version?()

  unless versionedComponent
    console.warn "Image #{url} is used outside of a versioned component, so we can't apply a version."
    return url

  # Return the url with version added.
  versionedComponent.versionedUrl url
