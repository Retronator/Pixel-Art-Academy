class Artificial.Pages
  constructor: ->
    Retronator.App.addAdminPage '/admin/artificial/babel', Artificial.Babel.Pages.Admin
    Retronator.App.addAdminPage '/admin/artificial/babel/scripts', Artificial.Babel.Pages.Admin.Scripts
    Retronator.App.addAdminPage '/admin/artificial/mummification/databasecontent', Artificial.Mummification.Pages.Admin.DatabaseContent
