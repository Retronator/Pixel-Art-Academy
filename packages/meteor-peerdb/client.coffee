globals = @

class globals.Document extends globals.Document
  @updateAll: ->
    @_updateAll()

share.setupMessages = ->
  # No-op.

globals.Document.instanceDisabled = false
globals.Document.instances = 1
globals.Document.instance = 0

Document = globals.Document
