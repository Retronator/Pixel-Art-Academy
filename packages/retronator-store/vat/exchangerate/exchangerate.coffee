AB = Artificial.Base
RS = Retronator.Store

class RS.Vat.ExchangeRate
  @id: -> 'Retronator.Store.Vat.ExchangeRate'
  
  @getUsdToEur: new AB.Method name: "#{@id()}.getUsdToEur"
  @getEurToUsd: new AB.Method name: "#{@id()}.getEurToUsd"
