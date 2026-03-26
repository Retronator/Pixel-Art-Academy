_.mixin
  # Resolve a function into its return value, or returns itself if it's not a function..
  resolve: (target) ->
    if _.isFunction target then target() else target
