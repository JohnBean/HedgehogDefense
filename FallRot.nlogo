__includes ["libCommon.nls" "libCombatModel.nls"]

extensions [array]
globals[
  x
  y
   
  ;;staging areas
  chStagingX;;the channel bridge
  chStagingY
  chX
  chY
  chShiftX
  chShiftY
  chCrossed
   
  abStagingX
  abStagingY
  abX
  abY
  abShiftX
  abShiftY
  abCrossed
  
  amStagingX
  amStagingY
  amX
  amY
  amShiftX
  amShiftY
  amCrossed
  
  brStagingX;;bracer
  brStagingY
  brX
  brY
  brShiftX
  brShiftY
  brCrossed
  
  peStagingX
  peStagingY
  peX
  peY
  peShiftX
  peShiftY
  peCrossed
  
  nrTicksToNextRetreatline
]

to setup
  __clear-all-and-reset-ticks;clear the screen
  
  setup-Common
  setup-CombatModel
  
  setup-globals;get all the fields set to their starting values 
  setup-patches
  setup-units
end

to setup-globals
  set x array:from-list [50 50 50 50 50 50]
  set y array:from-list [50 50 50 50 50 50]
  
  ;; how the formation looks      10  8   6   4   2   0   1   3   5   7   9
  ;; how the positions are stored 0   1   2   3   4   5   6   7   8   9  10
  set chStagingX array:from-list[135 133 137 131 139 129 141 127 143 125 145]
  set chStagingY array:from-list[490 492 488 494 486 496 484 498 482 500 480]
  set abStagingX array:from-list[185 187 183 189 181 191 179 193 177 195 175]
  set abStagingY array:from-list[458 456 460 454 462 452 464 450 466 448 468]
  set amStagingX array:from-list[366 368 364 370 362 372 360 374 358 376 356]
  set amStagingY array:from-list[342 340 344 338 346 336 348 334 350 332 352]
  set brStagingX array:from-list[526 528 524 530 522 532 520 534 518 536 516]
  set brStagingY array:from-list[364 366 362 368 360 370 358 372 356 374 354]
  set peStagingX array:from-list[596 598 594 600 592 602 590 604 588 606 586]
  set peStagingY array:from-list[352 350 354 348 356 346 358 344 360 342 362]
  set chX 128
  set chY 483
  set abX 173;the position accross the abevile bridge units will move to
  set abY 450
  set amX 357
  set amY 336
  set brX 528
  set brY 342
  set peX 586
  set peY 346
  set chShiftX 2
  set chShiftY 2
  set abShiftX 2;the amount each row of units is shifted in the ranks at the abbevile bridge
  set abShiftY 2
  set amShiftX 2
  set amShiftY 2
  set brShiftX -2
  set brShiftY 2
  set peShiftX 2
  set peShiftY 2
  set abCrossed 0;number of units in the current brigade that have crossed the abbevile bridge
  set amCrossed 0
  set peCrossed 0
  set nrTicksToNextRetreatline 15
end

to setup-patches
 import-drawing "Map.png"
end

to setup-units
  create-units (188) [
    c_writeUnit DefaultUnit
    
    set name "German infantry"
    set allegiance GERMAN
    set size 5
    set heading 225
    set color red

    set state 1
    set destinationX -1
    set destinationY -1
    set destinationNum -1
    set targetBridge 1   

    if(who > 30) [
      set targetBridge 2
    ]
    if(who > 80) [
      set targetBridge 3
    ]
    if(who > 140) [
      set targetBridge 4
    ]
    if(who > 160) [
      set targetBridge 5
    ]
  ]
  
  create-units (24) [
    c_writeUnit DefaultUnit
    
    set name "German tank"
    set allegiance GERMAN
    set size 5
    set heading 225  
    set color red
      
    set state 1
    set destinationX -1
    set destinationY -1
    set destinationNum -1
    set targetBridge 5
    set size 6
  ]  
  
  create-units (116)[
    c_writeUnit DefaultUnit
    
    set name "French infantry"
    set allegiance FRENCH
    set size 10
    set heading 45
    set color blue

    set state 1
    set destinationX -1
    set destinationY -1
    set destinationNum -1
    set stepsTaken 0
  ]
  
  create-units (6) [
    c_writeUnit DefaultUnit
    
    set name "French light"
    set allegiance FRENCH
    set size 10
    set heading 45
    set color blue

    set state 1
    set destinationX -1
    set destinationY -1
    set destinationNum -1
    set stepsTaken 0
  ]
  
  create-units (10) [
    c_writeUnit DefaultUnit

    set name "French armor"
    set allegiance FRENCH
    set size 10
    set heading 45
    set color blue

    set state 1
    set destinationX -1
    set destinationY -1
    set destinationNum -1
    set stepsTaken 0
  ]      
  
  ask units [
    ifelse (allegiance = GERMAN) [
      ifelse (who < 106) [
        setxy (116 + round(2.4 * who)) (533 + round(-1.5 * who))
      ] [
        setxy (116 + round(2.4 * who)) (376 + round(0.4 * (who - 106)))         
      ]
    ] [
      ifelse (who < 278) [
        setxy (110 + round(3.83 * (who - 212))) (481 + round(-2.56 * (who - 212))) + (remainder who 2) * 8
      ] [
        setxy (363 + round(4.06 * (who - 278))) (312 + round(.5 * (who - 278))) + (remainder who 2) * 8     
      ]
    ]
  ]
end

to Step
  ask units [
    if(any? units with [color = red] and any? units with [color = blue])[
        interact
        dealArtificialDmgToFrench
        decideFrenchRetreat
        move
    ]
  ]
  set CurrentTicks (CurrentTicks + 1)
end

to Steps
  repeat 50 [
    Step 
  ]
end

;run procedure
to go
  Step

  if (CurrentTicks >= 42800) [ ;after a set amount of time stop the simulation
    stop
  ]           
end  

to interact
  let opponent c_nearestEnemy

  if(state = 1 and allegiance = GERMAN)[ ; if brigade is german and ready for orders
    let i 0;; the counter that determines what spot we are currently looking to fill
    let goal -1;; a marker for wether or not this brigade has chosen a spot to fill
    let valid 1;;a check for if the spot we're looking at is valid for this brigade
    ;find the nearest empty waiting spot to fill in at
    repeat 99[
      set valid 1;;assume the spot we're looking at is valid until proven otherwise
      if(goal = -1)[;;if this brigade hasn't chosen a spot yet have them look for one
        ;;what row of the formation are we looking at?
        let row 0
        if(i > 10 and i < 22)[
          set row 1
        ]
        if(i > 21 and i < 33)[
          set row 2
        ]
        if(i > 32 and i < 44)[
          set row 3
        ]
        if(i > 43 and i < 55)[
          set row 4
        ]
        if(i > 54 and i < 66)[
          set row 5
        ]
        if(i > 65 and i < 77)[
          set row 6
        ]
        if(i > 76 and i < 88)[
          set row 7
        ]
        if(i > 87 and i < 99)[
          set row 8
        ]
        ;;this handles units looking to cross the abbevile bridge
        if(targetBridge = 1)[
          ;find the location of this destination by finding the base location and shifting by the row it's in
          let goalX ((array:item chStagingX (i - (11 * row))) + (row * chShiftX))
          let goalY ((array:item chStagingY (i - (11 * row))) + (row * chShiftY))
          let myDistance sqrt((abs(goalX - xcor) * abs(goalX - xcor)) + (abs(goalY - ycor) * abs(goalY - ycor)))
          ;this isn' a valid spot if someone else is going to use it
          if(any? units with[destinationNum = i and targetBridge = 1 and allegiance = GERMAN])[
            set valid 0
          ]
          ;this isn't a valid spot if a closer brigade needs to move toward it
          if(any? units with[targetBridge = 1 and allegiance = GERMAN and (destinationNum > i + 1 or destinationNum = -1) and sqrt((abs(goalX - xcor) * abs(goalX - xcor)) + (abs(goalY - ycor) * abs(goalY - ycor))) < myDistance])[
            set valid 0
          ]
          ;the spot is not valid if it is farther from the bridge than the current destination
          if(i > destinationNum and destinationNum > -1)[
            set valid 0
          ]
          if(valid = 1)[
            ;we are setting this brigade to move to destination i, no others can move here now
            set destinationNum i
            set destinationX goalX
            set destinationY goalY
            set state 2
            set goal 1
          ]
        ]
        ;;this handles units looking to cross the abbevile bridge
        if(targetBridge = 2)[
          ;find the location of this destination by finding the base location and shifting by the row it's in
          let goalX ((array:item abStagingX (i - (11 * row))) + (row * abShiftX))
          let goalY ((array:item abStagingY (i - (11 * row))) + (row * abShiftY))
          let myDistance sqrt((abs(goalX - xcor) * abs(goalX - xcor)) + (abs(goalY - ycor) * abs(goalY - ycor)))
          ;this isn' a valid spot if someone else is going to use it
          if(any? units with[destinationNum = i and targetBridge = 2 and allegiance = GERMAN])[
            set valid 0
          ]
          ;this isn't a valid spot if a closer brigade needs to move toward it
          if(any? units with[targetBridge = 2 and allegiance = GERMAN and (destinationNum > i + 1 or destinationNum = -1) and sqrt((abs(goalX - xcor) * abs(goalX - xcor)) + (abs(goalY - ycor) * abs(goalY - ycor))) < myDistance])[
            set valid 0
          ]
          ;the spot is not valid if it is farther from the bridge than the current destination
          if(i > destinationNum and destinationNum > -1)[
            set valid 0
          ]
          if(valid = 1)[
            ;we are setting this brigade to move to destination i, no others can move here now
            set destinationNum i
            set destinationX goalX
            set destinationY goalY
            set state 2
            set goal 1
          ]
        ]
        ;;this handles units looking to cross the abbevile bridge
        if(targetBridge = 3)[
          ;find the location of this destination by finding the base location and shifting by the row it's in
          let goalX ((array:item amStagingX (i - (11 * row))) + (row * amShiftX))
          let goalY ((array:item amStagingY (i - (11 * row))) + (row * amShiftY))
          let myDistance sqrt((abs(goalX - xcor) * abs(goalX - xcor)) + (abs(goalY - ycor) * abs(goalY - ycor)))
          ;this isn' a valid spot if someone else is going to use it
          if(any? units with[destinationNum = i and targetBridge = 3 and allegiance = GERMAN])[
            set valid 0
          ]
          ;this isn't a valid spot if a closer brigade needs to move toward it
          if(any? units with[targetBridge = 3 and allegiance = GERMAN and (destinationNum > i + 1 or destinationNum = -1) and sqrt((abs(goalX - xcor) * abs(goalX - xcor)) + (abs(goalY - ycor) * abs(goalY - ycor))) < myDistance])[
            set valid 0
          ]
          ;the spot is not valid if it is farther from the bridge than the current destination
          if(i > destinationNum and destinationNum > -1)[
            set valid 0
          ]
          if(valid = 1)[
            ;we are setting this brigade to move to destination i, no others can move here now
            set destinationNum i
            set destinationX goalX
            set destinationY goalY
            set state 2
            set goal 1
          ]
        ]
        if(targetBridge = 4)[
          ;find the location of this destination by finding the base location and shifting by the row it's in
          let goalX ((array:item brStagingX (i - (11 * row))) + (row * brShiftX))
          let goalY ((array:item brStagingY (i - (11 * row))) + (row * brShiftY))
          let myDistance sqrt((abs(goalX - xcor) * abs(goalX - xcor)) + (abs(goalY - ycor) * abs(goalY - ycor)))
          ;this isn' a valid spot if someone else is going to use it
          if(any? units with[destinationNum = i and targetBridge = 4 and allegiance = GERMAN])[
            set valid 0
          ]
          ;this isn't a valid spot if a closer brigade needs to move toward it
          if(any? units with[targetBridge = 4 and allegiance = GERMAN and (destinationNum > i + 1 or destinationNum = -1) and sqrt((abs(goalX - xcor) * abs(goalX - xcor)) + (abs(goalY - ycor) * abs(goalY - ycor))) < myDistance])[
            set valid 0
          ]
          ;the spot is not valid if it is farther from the bridge than the current destination
          if(i > destinationNum and destinationNum > -1)[
            set valid 0
          ]
          if(valid = 1)[
            ;we are setting this brigade to move to destination i, no others can move here now
            set destinationNum i
            set destinationX goalX
            set destinationY goalY
            set state 2
            set goal 1
          ]
        ]
        if(targetBridge = 5)[
          ;find the location of this destination by finding the base location and shifting by the row it's in
          let goalX ((array:item peStagingX (i - (11 * row))) + (row * peShiftX))
          let goalY ((array:item peStagingY (i - (11 * row))) + (row * peShiftY))
          let myDistance sqrt((abs(goalX - xcor) * abs(goalX - xcor)) + (abs(goalY - ycor) * abs(goalY - ycor)))
          ;this isn' a valid spot if someone else is going to use it
          if(any? units with[destinationNum = i and targetBridge = 5 and allegiance = GERMAN])[
            set valid 0
          ]
          ;this isn't a valid spot if a closer brigade needs to move toward it
          if(any? units with[targetBridge = 5 and allegiance = GERMAN and (destinationNum > i + 1 or destinationNum = -1) and sqrt((abs(goalX - xcor) * abs(goalX - xcor)) + (abs(goalY - ycor) * abs(goalY - ycor))) < myDistance])[
            set valid 0
          ]
          ;the spot is not valid if it is farther from the bridge than the current destination
          if(i > destinationNum and destinationNum > -1)[
            set valid 0
          ]
          if(valid = 1)[
            ;we are setting this brigade to move to destination i, no others can move here now
            set destinationNum i
            set destinationX goalX
            set destinationY goalY
            set state 2
            set goal 1
          ]
        ]
      ]
      set i (i + 1);;after we've looked at a spot incriment so we can look at the next one on the next pass
    ]; 99 loop ends here
    
    ;if the bridge is empty and the unit nearest the brigade is ready for orders
    if(destinationNum = 0 and state = 1)[
      if not(any? units with[state = 3 and allegiance = GERMAN and targetBridge = 1])[
      ;set it to crossing the bridge and announce that its space is now available for someone else to take 
        set destinationX (chX)
        set destinationY (chY)
        set state 3
        set destinationNum -1  
      ]
      if not(any? units with[state = 3 and allegiance = GERMAN and targetBridge = 2])[
      ;set it to crossing the bridge and announce that its space is now available for someone else to take 
        set destinationX (abX)
        set destinationY (abY)
        set state 3
        set destinationNum -1  
      ]
      if not(any? units with[state = 3 and allegiance = GERMAN and targetBridge = 3])[
      ;set it to crossing the bridge and announce that its space is now available for someone else to take 
        set destinationX (amX)
        set destinationY (amY)
        set state 3
        set destinationNum -1  
      ]
      if not(any? units with[state = 3 and allegiance = GERMAN and targetBridge = 4])[
      ;set it to crossing the bridge and announce that its space is now available for someone else to take 
        set destinationX (brX)
        set destinationY (brY)
        set state 3
        set destinationNum -1  
      ]
      if not(any? units with[state = 3 and allegiance = GERMAN and targetBridge = 5])[
      ;set it to crossing the bridge and announce that its space is now available for someone else to take 
        set destinationX (peX)
        set destinationY (peY)
        set state 3
        set destinationNum -1  
      ]
    ]
    if(destinationNum = -1 and state = 1 and targetBridge = 1)[
      set destinationX 146
      set destinationY 501
    ]
    if(destinationNum = -1 and state = 1 and targetBridge = 2)[
      set destinationX 200
      set destinationY 480
    ]
    if(destinationNum = -1 and state = 1 and targetBridge = 3)[
      set destinationX 364
      set destinationY 352
    ]
    if(destinationNum = -1 and state = 1 and targetBridge = 4)[
      set destinationX 515
      set destinationY 371
    ]
    if(destinationNum = -1 and state = 1 and targetBridge = 5)[
      set destinationX 601
      set destinationY 364
    ]
  ]      
end   
       
to move
  ;move to a relay point if unable to find a specific destination
  if(state = 1 and allegiance = GERMAN and destinationNum = -1)[
    facexy destinationX destinationY
    forward curSpeed
  ]
  ;if the nazi brigade is stationary and ready for orders
  if(state = 2 )[;if the unit is moving toward a waiting position go toward it until it's too close to move farther
    ifelse(abs (destinationX - xcor) < curSpeed and abs (destinationY - ycor) < curSpeed)[
      ;if the unit reached its waiting position face the enemies and set its state to ready to move
      setxy destinationX destinationY
      set state 1
      facexy 170 450
    ]
    [
      ;if it hasn't reached its waiting point move toward it at its normal speed
      facexy destinationX destinationY
      forward curSpeed
    ]
  ]

  ;if the french brigade has less than 70% left, it retreats to the first zone
  if(retreatState = 1)[
    if ( stepsTaken = 0 ) [
      rt 180
    ]
    
    ifelse ( stepsTaken = nrTicksToNextRetreatline ) [
      rt 180
    ][
      if ( stepsTaken <  nrTicksToNextRetreatline ) [
        forward curSpeed
      ] 
    ]  
    if not ( stepsTaken > nrTicksToNextRetreatline ) [
       set stepsTaken (stepsTaken + 1)
    ]
  ]
  
  ;if the french brigade has less than 50% left, it retreats to the second zone
  if(retreatState = 2)[
    if ( stepsTaken = nrTicksToNextRetreatline + 1 ) [
      rt 180
    ]
    
    ifelse ( stepsTaken = 2 * nrTicksToNextRetreatline ) [
      rt 180
    ][
      if ( stepsTaken <  2 * nrTicksToNextRetreatline ) [
        forward curSpeed
      ]  
    ]  
    if not ( stepsTaken > 2 * nrTicksToNextRetreatline ) [
       set stepsTaken (stepsTaken + 1)
    ]
    
  ]
  
  ;if the french brigade has less than 30% left, it retreats to the third zone
  if(retreatState = 3)[
    if ( stepsTaken = 2 * nrTicksToNextRetreatline + 1 ) [
      rt 180
    ]
    
    ifelse ( stepsTaken = 3 * nrTicksToNextRetreatline ) [
      rt 180
    ][
      if ( stepsTaken <  3 * nrTicksToNextRetreatline ) [
        forward curSpeed
      ]  
    ]  
    if not ( stepsTaken > 3 * nrTicksToNextRetreatline ) [
       set stepsTaken (stepsTaken + 1)
    ]
    
  ]    

  
  
  if(state = 3 and allegiance = GERMAN)[ ; if german and currently crossing the bridge
    set destinationNum -1
     if(targetBridge = 1)[
        set chCrossed chCrossed + 60
        setxy (array:item chStagingX 0) - ((array:item chStagingX 0 - chX) * (chCrossed /(curInf + curAT + curTanks + curArt))) array:item chStagingY 0 - ((array:item chStagingY 0 - chY) * (chCrossed /(curInf + curAT + curTanks + curArt)))
        forward 1
        if(xcor <= chX and ycor <= chY)[
          set state 4
          set chCrossed 0
          set destinationNum -1
        ]
      ]
      if(targetBridge = 2)[
        set abCrossed abCrossed + 60
        setxy (array:item abStagingX 0) - ((array:item abStagingX 0 - abX) * (abCrossed /(curInf + curAT + curTanks + curArt))) array:item abStagingY 0 - ((array:item abStagingY 0 - abY) * (abCrossed /(curInf + curAT + curTanks + curArt)))
        forward 1
        if(xcor <= abX and ycor <= abY)[
          set state 4
          set abCrossed 0
          set destinationNum -1
        ]
      ] 
      if(targetBridge = 3)[
        set amCrossed amCrossed + 60
        setxy (array:item amStagingX 0) - ((array:item amStagingX 0 - amX) * (amCrossed /(curInf + curAT + curTanks + curArt))) array:item amStagingY 0 - ((array:item amStagingY 0 - amY) * (amCrossed /(curInf + curAT + curTanks + curArt)))
        forward 1
        if(xcor <= amX and ycor <= amY)[
          set state 4
          set amCrossed 0
          set destinationNum -1
        ]
      ]
      if(targetBridge = 4)[
        set brCrossed brCrossed + 60
        setxy (array:item brStagingX 0) - ((array:item brStagingX 0 - brX) * (brCrossed /(curInf + curAT + curTanks + curArt))) array:item brStagingY 0 - ((array:item brStagingY 0 - brY) * (brCrossed /(curInf + curAT + curTanks + curArt)))
        forward 1
        if(xcor <= brX and ycor <= brY)[
          set state 4
          set brCrossed 0
          set destinationNum -1
        ]
      ] 
      if(targetBridge = 5)[
        set peCrossed peCrossed + 60
        setxy (array:item peStagingX 0) - ((array:item peStagingX 0 - peX) * (peCrossed /(curInf + curAT + curTanks + curArt))) array:item peStagingY 0 - ((array:item peStagingY 0 - peY) * (peCrossed /(curInf + curAT + curTanks + curArt)))
        forward 1
        if(xcor <= peX and ycor <= peY)[
          set state 5
          set peCrossed 0
          set destinationNum -1
        ]
      ] 
  ]
  
end 

to dealArtificialDmgToFrench
  ;move to a relay point if unable to find a specific destination
  if(allegiance = FRENCH)[
    set effectiveness (effectiveness - 1)
  ]
end 

to decideFrenchRetreat
  if (effectiveness < 71) and (effectiveness > 50) [
    set retreatState 1 
  ]  
  if (effectiveness < 51) and (effectiveness > 30) [
    set retreatState 2 
  ]  
  if (effectiveness < 31) [
    set retreatState 3 
  ]      
end
@#$#@#$#@
GRAPHICS-WINDOW
435
9
1093
688
-1
-1
1.013
1
4
1
1
1
0
0
0
1
0
639
0
639
1
1
1
ticks
30.0

BUTTON
16
11
83
44
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
277
62
340
95
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
350
11
432
56
NIL
CurrentTicks
0
1
11

BUTTON
80
62
143
95
Step
step
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
157
63
251
96
Step (50)
Steps
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

This section could give a general understanding of what the model is trying to show or explain.

## HOW IT WORKS

This section could explain what rules the agents use to create the overall behavior of the model.

## HOW TO USE IT

This section could explain how to use the model, including a description of each of the items in the interface tab.

## THINGS TO NOTICE

This section could give some ideas of things for the user to notice while running the model.

## THINGS TO TRY

This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.

## EXTENDING THE MODEL

This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.

## NETLOGO FEATURES

This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.

## RELATED MODELS

This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.

## CREDITS AND REFERENCES

This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

ant
true
0
Polygon -7500403 true true 136 61 129 46 144 30 119 45 124 60 114 82 97 37 132 10 93 36 111 84 127 105 172 105 189 84 208 35 171 11 202 35 204 37 186 82 177 60 180 44 159 32 170 44 165 60
Polygon -7500403 true true 150 95 135 103 139 117 125 149 137 180 135 196 150 204 166 195 161 180 174 150 158 116 164 102
Polygon -7500403 true true 149 186 128 197 114 232 134 270 149 282 166 270 185 232 171 195 149 186
Polygon -7500403 true true 225 66 230 107 159 122 161 127 234 111 236 106
Polygon -7500403 true true 78 58 99 116 139 123 137 128 95 119
Polygon -7500403 true true 48 103 90 147 129 147 130 151 86 151
Polygon -7500403 true true 65 224 92 171 134 160 135 164 95 175
Polygon -7500403 true true 235 222 210 170 163 162 161 166 208 174
Polygon -7500403 true true 249 107 211 147 168 147 168 150 213 150

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bee
true
0
Polygon -1184463 true false 151 152 137 77 105 67 89 67 66 74 48 85 36 100 24 116 14 134 0 151 15 167 22 182 40 206 58 220 82 226 105 226 134 222
Polygon -16777216 true false 151 150 149 128 149 114 155 98 178 80 197 80 217 81 233 95 242 117 246 141 247 151 245 177 234 195 218 207 206 211 184 211 161 204 151 189 148 171
Polygon -7500403 true true 246 151 241 119 240 96 250 81 261 78 275 87 282 103 277 115 287 121 299 150 286 180 277 189 283 197 281 210 270 222 256 222 243 212 242 192
Polygon -16777216 true false 115 70 129 74 128 223 114 224
Polygon -16777216 true false 89 67 74 71 74 224 89 225 89 67
Polygon -16777216 true false 43 91 31 106 31 195 45 211
Line -1 false 200 144 213 70
Line -1 false 213 70 213 45
Line -1 false 214 45 203 26
Line -1 false 204 26 185 22
Line -1 false 185 22 170 25
Line -1 false 169 26 159 37
Line -1 false 159 37 156 55
Line -1 false 157 55 199 143
Line -1 false 200 141 162 227
Line -1 false 162 227 163 241
Line -1 false 163 241 171 249
Line -1 false 171 249 190 254
Line -1 false 192 253 203 248
Line -1 false 205 249 218 235
Line -1 false 218 235 200 144

bird1
false
0
Polygon -7500403 true true 2 6 2 39 270 298 297 298 299 271 187 160 279 75 276 22 100 67 31 0

bird2
false
0
Polygon -7500403 true true 2 4 33 4 298 270 298 298 272 298 155 184 117 289 61 295 61 105 0 43

boat1
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 33 230 157 182 150 169 151 157 156
Polygon -7500403 true true 149 55 88 143 103 139 111 136 117 139 126 145 130 147 139 147 146 146 149 55

boat2
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 157 54 175 79 174 96 185 102 178 112 194 124 196 131 190 139 192 146 211 151 216 154 157 154
Polygon -7500403 true true 150 74 146 91 139 99 143 114 141 123 137 126 131 129 132 139 142 136 126 142 119 147 148 147

boat3
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 37 172 45 188 59 202 79 217 109 220 130 218 147 204 156 158 156 161 142 170 123 170 102 169 88 165 62
Polygon -7500403 true true 149 66 142 78 139 96 141 111 146 139 148 147 110 147 113 131 118 106 126 71

box
true
0
Polygon -7500403 true true 45 255 255 255 255 45 45 45

butterfly1
true
0
Polygon -16777216 true false 151 76 138 91 138 284 150 296 162 286 162 91
Polygon -7500403 true true 164 106 184 79 205 61 236 48 259 53 279 86 287 119 289 158 278 177 256 182 164 181
Polygon -7500403 true true 136 110 119 82 110 71 85 61 59 48 36 56 17 88 6 115 2 147 15 178 134 178
Polygon -7500403 true true 46 181 28 227 50 255 77 273 112 283 135 274 135 180
Polygon -7500403 true true 165 185 254 184 272 224 255 251 236 267 191 283 164 276
Line -7500403 true 167 47 159 82
Line -7500403 true 136 47 145 81
Circle -7500403 true true 165 45 8
Circle -7500403 true true 134 45 6
Circle -7500403 true true 133 44 7
Circle -7500403 true true 133 43 8

circle
false
0
Circle -7500403 true true 35 35 230

person
false
0
Circle -7500403 true true 155 20 63
Rectangle -7500403 true true 158 79 217 164
Polygon -7500403 true true 158 81 110 129 131 143 158 109 165 110
Polygon -7500403 true true 216 83 267 123 248 143 215 107
Polygon -7500403 true true 167 163 145 234 183 234 183 163
Polygon -7500403 true true 195 163 195 233 227 233 206 159

sheep
false
15
Rectangle -1 true true 90 75 270 225
Circle -1 true true 15 75 150
Rectangle -16777216 true false 81 225 134 286
Rectangle -16777216 true false 180 225 238 285
Circle -16777216 true false 1 88 92

spacecraft
true
0
Polygon -7500403 true true 150 0 180 135 255 255 225 240 150 180 75 240 45 255 120 135

thin-arrow
true
0
Polygon -7500403 true true 150 0 0 150 120 150 120 293 180 293 180 150 300 150

truck-down
false
0
Polygon -7500403 true true 225 30 225 270 120 270 105 210 60 180 45 30 105 60 105 30
Polygon -8630108 true false 195 75 195 120 240 120 240 75
Polygon -8630108 true false 195 225 195 180 240 180 240 225

truck-left
false
0
Polygon -7500403 true true 120 135 225 135 225 210 75 210 75 165 105 165
Polygon -8630108 true false 90 210 105 225 120 210
Polygon -8630108 true false 180 210 195 225 210 210

truck-right
false
0
Polygon -7500403 true true 180 135 75 135 75 210 225 210 225 165 195 165
Polygon -8630108 true false 210 210 195 225 180 210
Polygon -8630108 true false 120 210 105 225 90 210

turtle
true
0
Polygon -7500403 true true 138 75 162 75 165 105 225 105 225 142 195 135 195 187 225 195 225 225 195 217 195 202 105 202 105 217 75 225 75 195 105 187 105 135 75 142 75 105 135 105

wolf
false
0
Rectangle -7500403 true true 15 105 105 165
Rectangle -7500403 true true 45 90 105 105
Polygon -7500403 true true 60 90 83 44 104 90
Polygon -16777216 true false 67 90 82 59 97 89
Rectangle -1 true false 48 93 59 105
Rectangle -16777216 true false 51 96 55 101
Rectangle -16777216 true false 0 121 15 135
Rectangle -16777216 true false 15 136 60 151
Polygon -1 true false 15 136 23 149 31 136
Polygon -1 true false 30 151 37 136 43 151
Rectangle -7500403 true true 105 120 263 195
Rectangle -7500403 true true 108 195 259 201
Rectangle -7500403 true true 114 201 252 210
Rectangle -7500403 true true 120 210 243 214
Rectangle -7500403 true true 115 114 255 120
Rectangle -7500403 true true 128 108 248 114
Rectangle -7500403 true true 150 105 225 108
Rectangle -7500403 true true 132 214 155 270
Rectangle -7500403 true true 110 260 132 270
Rectangle -7500403 true true 210 214 232 270
Rectangle -7500403 true true 189 260 210 270
Line -7500403 true 263 127 281 155
Line -7500403 true 281 155 281 192

wolf-left
false
3
Polygon -6459832 true true 117 97 91 74 66 74 60 85 36 85 38 92 44 97 62 97 81 117 84 134 92 147 109 152 136 144 174 144 174 103 143 103 134 97
Polygon -6459832 true true 87 80 79 55 76 79
Polygon -6459832 true true 81 75 70 58 73 82
Polygon -6459832 true true 99 131 76 152 76 163 96 182 104 182 109 173 102 167 99 173 87 159 104 140
Polygon -6459832 true true 107 138 107 186 98 190 99 196 112 196 115 190
Polygon -6459832 true true 116 140 114 189 105 137
Rectangle -6459832 true true 109 150 114 192
Rectangle -6459832 true true 111 143 116 191
Polygon -6459832 true true 168 106 184 98 205 98 218 115 218 137 186 164 196 176 195 194 178 195 178 183 188 183 169 164 173 144
Polygon -6459832 true true 207 140 200 163 206 175 207 192 193 189 192 177 198 176 185 150
Polygon -6459832 true true 214 134 203 168 192 148
Polygon -6459832 true true 204 151 203 176 193 148
Polygon -6459832 true true 207 103 221 98 236 101 243 115 243 128 256 142 239 143 233 133 225 115 214 114

wolf-right
false
3
Polygon -6459832 true true 170 127 200 93 231 93 237 103 262 103 261 113 253 119 231 119 215 143 213 160 208 173 189 187 169 190 154 190 126 180 106 171 72 171 73 126 122 126 144 123 159 123
Polygon -6459832 true true 201 99 214 69 215 99
Polygon -6459832 true true 207 98 223 71 220 101
Polygon -6459832 true true 184 172 189 234 203 238 203 246 187 247 180 239 171 180
Polygon -6459832 true true 197 174 204 220 218 224 219 234 201 232 195 225 179 179
Polygon -6459832 true true 78 167 95 187 95 208 79 220 92 234 98 235 100 249 81 246 76 241 61 212 65 195 52 170 45 150 44 128 55 121 69 121 81 135
Polygon -6459832 true true 48 143 58 141
Polygon -6459832 true true 46 136 68 137
Polygon -6459832 true true 45 129 35 142 37 159 53 192 47 210 62 238 80 237
Line -16777216 false 74 237 59 213
Line -16777216 false 59 213 59 212
Line -16777216 false 58 211 67 192
Polygon -6459832 true true 38 138 66 149
Polygon -6459832 true true 46 128 33 120 21 118 11 123 3 138 5 160 13 178 9 192 0 199 20 196 25 179 24 161 25 148 45 140
Polygon -6459832 true true 67 122 96 126 63 144

@#$#@#$#@
NetLogo 5.0.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="end-reps" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 160 [go]</go>
    <final>print-final-report</final>
    <timeLimit steps="42801"/>
    <metric>report-boys</metric>
    <metric>report-girls</metric>
    <metric>differenciation</metric>
    <metric>girls-beating-boys</metric>
    <enumeratedValueSet variable="attraction?">
      <value value="false"/>
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="intensity-of-aggression">
      <value value="0.1"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="population">
      <value value="4"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
