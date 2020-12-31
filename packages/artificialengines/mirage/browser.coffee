AM = Artificial.Mirage
AE = Artificial.Everywhere

# The bounds of your browser window.
class AM.Browser
  @isSafari: ->
    navigator.userAgent.match(/Safari/) and not navigator.userAgent.match(/Chrom/)
