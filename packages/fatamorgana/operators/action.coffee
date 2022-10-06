AM = Artificial.Mirage
FM = FataMorgana

class FM.Action extends FM.Operator
  execute: -> throw new AE.NotImplementedException "Action must implement an execution."

  enabled: ->
    # Override to provide reactive logic when this action can be executed.
    @interface.active()
