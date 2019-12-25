class Artificial.Pages
  constructor: ->
    Retronator.App.addPublicPage '/artificial/pyramid/interpolation', Artificial.Pyramid.Pages.Interpolation
    Retronator.App.addPublicPage '/artificial/spectrum/color/chromaticity', Artificial.Spectrum.Pages.Color.Chromaticity

    Retronator.App.addAdminPage '/admin/artificial/babel', Artificial.Babel.Pages.Admin
    Retronator.App.addAdminPage '/admin/artificial/babel/scripts', Artificial.Babel.Pages.Admin.Scripts
    Retronator.App.addAdminPage '/admin/artificial/mummification/databasecontent', Artificial.Mummification.Pages.Admin.DatabaseContent
