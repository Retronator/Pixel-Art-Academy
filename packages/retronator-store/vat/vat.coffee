AB = Artificial.Base
RS = Retronator.Store

class RS.Vat
  @id: -> 'Retronator.Store.Vat'

  @validateVatId: new AB.Method name: "#{@id()}.validateVatId"
