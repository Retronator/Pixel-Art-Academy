AM = Artificial.Mirage
FM = FataMorgana

class FM.Action
  @id: -> throw new AE.NotImplementedException "Action must have an ID."
  id: -> @constructor.id()

  execute: -> throw new AE.NotImplementedException "Action must implement an execution."

  enabled: -> 
    # Override to provide reactive logic when this action can be executed.
    true
