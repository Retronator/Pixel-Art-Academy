-- invasion
-- work in progress build
cls()
color(10)
rectfill(0,0,128,128)
color(0)
waittostart=true

-- yellow is transparent.
palt(10,true)
palt(0,false)

--reset sprite changes to zero.
poke(0x5f80, 0)

function _init()
        timetomove=5
        timeleft=timetomove
        invasion={{4,8},{5,8}}
        head=2
        tail=1
	movex=1
	movey=0
  direction=1
  nextdirection=nil
  delayeddirection=nil
	eatingleft=0
	score=0
  dead = false
	newfood()
end

function newfood()
	foodx=flr(rnd(15))+1
	foody=flr(rnd(15))+1
end

function wait()
	if (btnp(4) or btnp(5)) then
		waittostart=false
		_init()
	end
end

function moveinvasion()
	--update invasion
	timeleft-=1
	if timeleft==0 then
		timeleft=timetomove

    if nextdirection then
      direction=nextdirection
      nextdirection=delayeddirection
      delayeddirection=null
    end

    if direction==0 then
      movex=-1
      movey=0
    end
    if direction==1 then
      movex=1
      movey=0
    end
    if direction==2 then
      movex=0
      movey=-1
    end
    if direction==3 then
      movex=0
      movey=1
    end

		--move invasion by adding new piece
		invasion[head+1]={}
		invasion[head+1][1]=invasion[head][1]+movex
		invasion[head+1][2]=invasion[head][2]+movey
		head+=1

		--check if head is eating
		if ((invasion[head][1]==foodx) and (invasion[head][2]==foody)) then
			newfood()
			eatingleft=1
			score+=1
		end

		--check if head is out of bounds
		if ((invasion[head][1]<0) or (invasion[head][1]>15) or (invasion[head][2]<0) or (invasion[head][2]>15)) then
			die()
		end

		--check if head is in other part
		for i=tail,(head-1) do
			if ((invasion[i][1]==invasion[head][1]) and (invasion[i][2]==invasion[head][2])) then
				die()
			end
		end

		if eatingleft>0 then
			eatingleft-=1
    else
      if not dead then
			  tail+=1
      end
		end
	end
end

function die()
  dead=true
	waittostart=true
  --report the score to the cartridge
  poke(0x5f81,score)
end

function changedirection()
  newdirection=nil

	if btnp(0) then
    newdirection=0
	end
	if btnp(1) then
    newdirection=1
	end
	if btnp(2) then
    newdirection=2
  end
	if btnp(3) then
    newdirection=3
  end

  if newdirection then
    if nextdirection then
      delayeddirection = newdirection
    else
      if newdirection ~= direction then
        nextdirection=newdirection
      end
    end
  end
end

function _update()
  --sprite update routine
  local updated_pixels_count = peek(0x5f80)
  for i = 0, updated_pixels_count - 1 do
    local x = peek(0x5f81 + i * 3)
    local y = peek(0x5f81 + i * 3 + 1)
    local color = peek(0x5f81 + i * 3 + 2)
    sset(x, y, color)
  end

	if (waittostart) then
		wait()
  else
    changedirection()
		moveinvasion()
	end
end

function _draw()
	--clear
	cls(10)
	color(0)

  if dead or not waittostart then
    --draw invasion
    for i=tail,head do
      x=invasion[i][1]*8
      y=invasion[i][2]*8
      spr(0,x,y)
    end

    --draw food
    spr(1,foodx*8,foody*8)
  end

  --draw score
  if waittostart then
    if dead then
      print("score:",50,50)
      print(score,75,50)
      print("press button to start",22,70)
    else
      print("invasion",54,40)
      print("press button to start",22,60)
      for x=5,7 do
        spr(0,x*8,84)
      end
      spr(1,80,84)
    end
  else

  end
end
