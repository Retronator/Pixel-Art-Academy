AM = Artificial.Mirage
LOI = LandsOfIllusions

class LOI.Styles.Console extends AM.Component
  @register 'LandsOfIllusions.Styles.Console'

  onCreated: ->
    super

    $('html').addClass('lands-of-illusions-style-console')

  onDestroyed: ->
    super

    $('html').removeClass('lands-of-illusions-style-console')
