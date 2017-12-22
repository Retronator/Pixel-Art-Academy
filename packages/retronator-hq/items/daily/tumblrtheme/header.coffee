Retronator =
  HQ:
    Items:
      Daily: {}

# Add to window so it can be accessed from inline scripts.
window.Retronator = Retronator

# On load create the theme.
$ ->
  new Retronator.HQ.Items.Daily.Theme
