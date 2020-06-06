AE = Artificial.Everywhere
RA = Retronator.Accounts

RA.Patreon.updateCurrentPledge.method ->
  user = Retronator.requireUser()

  patreonId = user.services?.patreon?.id
  throw new AE.UnauthorizedException "You do not have a Patreon account linked." unless patreonId

  RA.Patreon.updateCurrentPledgeForPatron patreonId
