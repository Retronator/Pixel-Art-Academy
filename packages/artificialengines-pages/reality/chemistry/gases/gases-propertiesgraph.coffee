AM = Artificial.Mirage
AS = Artificial.Spectrum
AR = Artificial.Reality

class AR.Pages.Chemistry.Gases extends AR.Pages.Chemistry.Gases
  @register 'Artificial.Reality.Pages.Chemistry.Gases'

  drawPropertiesGraph: ->
    canvas = @$('.properties-graph')[0]
    context = canvas.getContext '2d'

    context.setTransform 1, 0, 0, 1, 0, 0
    context.clearRect 0, 0, canvas.width, canvas.height
