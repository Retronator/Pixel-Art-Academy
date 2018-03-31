AE = Artificial.Everywhere
RS = Retronator.Store

RS.Vat.ExchangeRate.getUsdToEur.method ->
  handleRate RS.Vat.ExchangeRate.usdToEur

RS.Vat.ExchangeRate.getEurToUsd.method ->
  handleRate RS.Vat.ExchangeRate.eurToUsd

handleRate = (rate) ->
  throw new AE.ExternalException "Exchange rates have not been initialized." unless rate

  rate
