AEt = Artificial.Everything

class AEt.Part extends AEt.Item
  install: (@parent) ->
    # Override to provide part initialization.

  uninstall: ->
    @parent = null
    # Override to do any clean up.
