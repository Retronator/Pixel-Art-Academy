LOI = LandsOfIllusions
HQ = Retronator.HQ
Blog = Retronator.Blog

class HQ.Cafe.Burra extends HQ.Actors.Burra
  descriptiveName: ->
    justName = "Sarah '![Burra](talk to Burra)' Burrough."

    # See if we've talked to her already.
    if LOI.character()
      talked = HQ.Cafe.BurraListener.CharacterScript.state 'MainQuestion'

    else
      talked = HQ.Cafe.BurraListener.UserScript.state 'MainQuestion'

    return justName if talked

    "#{justName} #{@translations()?.greet}"
