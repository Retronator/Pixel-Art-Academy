Template.registerHelper 'image', (url) ->
  # TODO: Add versioning.

  version = Random.id()

  # Return the url with version added.
  "#{url}?#{version}"
