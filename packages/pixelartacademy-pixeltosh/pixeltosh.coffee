AM = Artificial.Mummification
AB = Artificial.Base
PAA = PixelArtAcademy

class PAA.Pixeltosh
  constructor: ->
    AB.Router.addRoute '/pixeltosh/:programSlug?/:projectId?', PAA.LearnMode.Layouts.PublicAccess, @constructor.Pages.Pixeltosh
