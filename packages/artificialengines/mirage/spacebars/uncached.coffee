Template.registerHelper 'uncached', (url) ->
  "#{url}?#{Random.id()}"
