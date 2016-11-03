AE = Artificial.Everywhere
AM = Artificial.Mirage
AT = Artificial.Telepathy
LOI = LandsOfIllusions

FlowRouter.wait()

# This is the web app that runs all Retronator websites.
class Retronator.App extends Artificial.Base.App
  @register 'Retronator.App'

  constructor: ->
    super

    # Instantiate all app packages, which register router URLs.
    new Retronator.Accounts

    # Add Lands of Illusions last so it captures all remaining URLs.
    new LOI

    FlowRouter.initialize()

    window.FlowRouter = FlowRouter
