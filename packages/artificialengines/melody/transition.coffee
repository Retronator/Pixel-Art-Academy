AMe = Artificial.Melody

class AMe.Transition
  constructor: (@section, options) ->
    _.defaults @, options,
      nextSection: null
      condition: null
