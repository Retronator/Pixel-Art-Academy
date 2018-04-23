LOI = LandsOfIllusions
PAA = PixelArtAcademy
HQ = Retronator.HQ
Blog = Retronator.Blog

class HQ.Cafe.Burra extends HQ.Actors.Burra
  descriptiveName: ->
    justName = "Sarah '![Burra](talk to Burra)' Burrough."

    # See if we've talked to her already.
    talked = HQ.Cafe.BurraListener.UserScript.state 'MainQuestion'

    return justName if talked

    "#{justName} She greets you across the counter."
