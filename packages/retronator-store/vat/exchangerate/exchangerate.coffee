AB = Artificial.Base
RS = Retronator.Store

class RS.Vat.ExchangeRate
  @id: -> 'RS.Vat.ExchangeRate'
  
  @getUsdToEur: new AB.Method name: "#{@id()}.getUsdToEur"
  @getEurToUsd: new AB.Method name: "#{@id()}.getEurToUsd"
