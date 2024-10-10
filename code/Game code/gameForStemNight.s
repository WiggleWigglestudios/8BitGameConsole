
;6522 stuff
PORTB = $6000
PORTA = $6001
PORTC = $0000
PORTCVAL=$0061
DDRB = $6002
DDRA = $6003

E  = %10000000
RW = %01000000
RS = %00100000


SoundPort = $0000			; one byte (output)
JoystickPort = $0001		; one byte (input)

VGARegisters=$0010			;start of VGA addresses
VGAXShiftRegister = $0010	;two bytes (output)
VGAYShiftRegister = $0012	;two bytes (output)
VGATileARegister = $0014	;two bytes (output)
VGATileDRegister = $0016	;one byte (output)
VGAPaletteARegister = $0017 ;one byte (output)
VGAPaletteDRegister = $0018 ;one byte (output)
VGAInteruptRegister = $0019 ;one byte (output)
VGANametableARegister = $001a	;two bytes (output)
VGANametableDRegister = $001c	;one byte (output)
VGASpritePosXY = $001e		;one byte (output) (works as shift register, writing will push the previous write to the next register)
VGASpriteIndex = $001f		;one byte (output)	

VGAPaletteTempValues=$0029	;six bytes

doneWithFrame=$0030

setCursorPositionX=$0033

playerSpriteX=$0035 ;2 bytes
playerSpriteY=$0037 ;2 bytes
playerSubVelX=$0039 ;3 bytes
playerSubVelY=$003C ;3 bytes


BCDOut = $00040
BCDInput = $0041

animationFrame=$0050


animateTilesLoopCount=$0052
animateTilesCurrentTile=$0053
animateTilesMaxFrame=$0054
animateTilesAddress=$0055

colorOffset=$0058

randomNumberPointer=$0060
songCounter=$0062 ;2 bytes
songPointer=$0064 ;2 bytes
songTimer=$0066;1 byte


playerTilePosX=$006C 
playerTilePosY=$006D
playerDecPosX=$006E 
playerDecPosY=$006F
playerPosX=$0070 ;3 bytes
playerPosY=$0073 ;3 bytes
playerVelX=$0076 ;3 bytes
playerVelY=$0079 ;3 bytes
playerSpriteCounter=$007c
playerSprite=$007d
playerSpeed=$007e
playerStatus=$007f ;0000 wmfg w-(1-has won,0-has not won) m-moving (1-moving, 0-still) f-facing (1-right,0-left)  g-grounded (1)
playerCheckPointX=$0080
playerCheckPointY=$0081
playerDeathCounter=$0082

playerSpawnPosX=3 ; should be 3
playerSpawnPosY=27 ;shoulb be 27
jumpStrength=4 ;should be 4


collisionTileValue=$0090
collisionCheckX=$0091 ;2 bytes
collisionCheckY=$0093 ;2 bytes
collisionMapAddress=$0096 ;4 bytes
collisionDistX=$009A	;3 bytes
collisionDistY=$009D	;3 bytes


movingTilesFrameCount=$0200 ;256 bytes long

calculationStackPointer = $0300 
calculationStack = $0301 ;256 bytes long

	.org $8000

reset:
	sei
	stz playerDeathCounter

	lda #0
	sta calculationStackPointer

	jsr resetVGARegisters
	
	jsr resetPlayerPos


	lda #%11111111 ; Set all pins on VIA port B to output
	sta DDRB
	lda #%11111100 ;lcd a7-a5 a/d a4 cs a3 clk a2 din a1 dout  button a0 ; for matrix display use this #%11111110 ; Set top 3 pins on VIA port A to output
	sta DDRA

	jsr resetLCD



	stz songCounter
	lda #2
	sta songCounter+1


	;set it so an inturupt is called at the end of the screen (480/4=120)
	lda #120
	sta VGAInteruptRegister

	;set player speed
	lda #200
	sta playerSpeed
	
	;reset screen
	jsr resetTiles  
	stz colorOffset
	jsr resetPalette
	jsr resetNametable
	jsr setNametable

	jsr transferMovingTilesToRam

printLineOne:
	lda messageLineOne,x
	beq afterPrintLineOne
	jsr print_char
	inx
	jmp printLineOne
afterPrintLineOne:

	ldx #0
	ldy #1
	jsr setCursorPosition
printLineTwo:
	lda messageLineTwo,x
	beq afterPrintLineTwo
	jsr print_char
	inx
	jmp printLineTwo
afterPrintLineTwo:

	jmp frameCode


resetVGARegisters:
	;reset all VGA registers
	lda #0
	sta VGARegisters
	sta VGARegisters+1
	sta VGARegisters+2
	sta VGARegisters+3
	sta VGARegisters+4
	sta VGARegisters+5
	sta VGARegisters+6
	sta VGARegisters+7
	sta VGARegisters+8
	sta VGARegisters+9
	sta VGARegisters+10
	sta VGARegisters+11
	sta VGARegisters+12
	sta VGARegisters+13
	sta VGARegisters+14
	sta VGARegisters+15
	sta VGARegisters+16
	sta animationFrame
	sta playerPosX
	sta playerPosX+1
	sta playerPosX+2
	sta playerPosY
	sta playerPosY+1
	sta playerPosY+2
	sta playerVelX
	sta playerVelX+1
	sta playerVelX+2
	sta playerVelY
	sta playerVelY+1
	sta playerVelY+2
	sta playerSprite
	sta VGASpritePosXY
	sta VGASpritePosXY
	sta VGASpritePosXY
	sta VGASpritePosXY
	sta VGASpritePosXY

	rts


resetPlayerPos:
	
	lda #playerSpawnPosX
	sta playerCheckPointX
	sta playerPosX+1
	clc
	rol playerPosX+1
	rol playerPosX
	clc
	rol playerPosX+1
	rol playerPosX
	clc
	rol playerPosX+1
	rol playerPosX

	lda #playerSpawnPosY
	sta playerCheckPointY
	sta playerPosY+1
	clc
	rol playerPosY+1
	rol playerPosY
	clc
	rol playerPosY+1
	rol playerPosY
	clc
	rol playerPosY+1
	rol playerPosY

	

	stz playerStatus

	rts


resetLCD:
	
   lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
   jsr lcd_instruction
   lda #%00001100 ; Display on; cursor on; blink off
   jsr lcd_instruction
   lda #%00000110 ; Increment and shift cursor; shift display
   jsr lcd_instruction
   lda #%00000001 ; Clear display
   jsr lcd_instruction
   lda #%00000010 ; Home
   jsr lcd_instruction



   lda #%00000001 ; Clear display
   jsr lcd_instruction
   lda #%00000010 ; Home
   jsr lcd_instruction
   rts

transferMovingTilesToRam:
	sec
	ldy #0
transferingMovingTilesLoop:
	lda movingTilesFrameCountRom,y
	sta movingTilesFrameCount,y
	iny
	tya
	clc
	adc #0
	beq pastTransferingMovingTiles
	jmp transferingMovingTilesLoop
pastTransferingMovingTiles:
	rts


frameCode:

	lda #0
	cmp playerDeathCounter
	bne pastPlayMusic
	jsr playMusic
	jmp pastDeathSound
pastPlayMusic:
	jsr playerRespawnSound
pastDeathSound:	
	
	jsr playerWaterCollision
	jsr playerMovement
	
	jsr setPlayerSubVel
	jsr playerPhysicsChangingPos
	jsr playerCollisions
	jsr setPlayerSubVel
	jsr playerPhysicsChangingPos
	jsr playerCollisions
	jsr setPlayerSubVel
	jsr playerPhysicsChangingPos
	jsr playerCollisions
	jsr setPlayerSubVel
	jsr playerPhysicsChangingPos
	jsr playerCollisions
	
	jsr playerSpikeCollision
	jsr playerCheckPointCollision

	jsr playerPhysicsForces



	;test to see if sprite can move left (it can)
	;lda playerPosX+1
	;sec
	;sbc #1
	;sta playerPosX+1
	;lda playerPosX
	;sbc #0
	;sta playerPosX


	
	;ldx #0
	;ldy #0
	;jsr setCursorPosition
	;lda collisionTileValue
	;jsr binaryToDecimalPrint
	
	;ldx #0
	;ldy #0
	;jsr setCursorPosition
	;lda songCounter
	;jsr binaryToDecimalPrint
	;ldx #4
	;ldy #0
	;jsr setCursorPosition
	;lda songCounter+1
	;jsr binaryToDecimalPrint
	;ldx #8
	;ldy #0
	;jsr setCursorPosition
	;lda songTimer
	;jsr binaryToDecimalPrint
	;ldx #0
	;ldy #1
	;jsr setCursorPosition
	;lda songBytes
	;jsr binaryToDecimalPrint
	;ldx #4
	;ldy #1
	;jsr setCursorPosition
	;lda songBytes+1
	;jsr binaryToDecimalPrint
	
	;ldx #12
	;ldy #0
	;jsr setCursorPosition
	;lda playerPosY+1
	;jsr binaryToDecimalPrint
	;ldx #8
	;ldy #1
	;jsr setCursorPosition
	;lda playerStatus
	;jsr binaryToDecimalPrint
	

	lda #1
	sta doneWithFrame
	jmp wait

wait:
	lda doneWithFrame
	beq frameCode
	jmp wait






pushCal:
	;phx
	ldx calculationStackPointer
	sta calculationStack,x
	inc calculationStackPointer
	;plx
	rts

pullCal:
	;	phx
	dec calculationStackPointer
	ldx calculationStackPointer
	lda calculationStack,x
	;	plx
	rts




lcd_wait:
   pha
   lda #%00000000 ; Set all pins on VIA port B to input
   sta DDRB
lcdbusy:
   lda #RW
   sta PORTA
   lda #(RW | E)
   sta PORTA
   lda PORTB
   and #%10000000 ; filter out the address bits, leaving the busy flag
   bne lcdbusy    ; branch if not zero
   lda #RW
   sta PORTA
   lda #%11111111 ; Set all pins on VIA port B to output
   sta DDRB
   pla
   rts

lcd_instruction:
   jsr lcd_wait
   sta PORTB
   lda #0         ; Clear RS/RW/E bits - RS=0=instruction register
   sta PORTA
   lda #E         ; Set E bit to send instruction
   sta PORTA
   lda #0         ; Clear RS/RW/E bits
   sta PORTA
   rts

print_char:
   jsr lcd_wait
   sta PORTB
   lda #RS        ; Set RS bit; Clear RW/E bits - RS=1=data register
   sta PORTA
   lda #(RS | E)  ; Set RS + E bit to send instruction
   sta PORTA
   lda #RS        ; Clear E bit
   sta PORTA
   rts



binaryToDecimalPrint:
	sta BCDInput
	lda #0
	sta BCDOut
hundredLoop:
	lda BCDInput
	sec
	sbc #100
	bcc	exitHundredLoop
	sta BCDInput
	inc BCDOut
	jmp hundredLoop
exitHundredLoop:
	lda BCDOut
	clc
	adc #48
	jsr print_char

	lda #0
	sta BCDOut	
tenLoop:
	lda BCDInput
	sec
	sbc #10
	bcc	exitTenLoop
	sta BCDInput
	inc BCDOut
	jmp tenLoop
exitTenLoop:
	lda BCDOut
	clc
	adc #48
	jsr print_char

	lda BCDInput
	clc
	adc #48
	jsr print_char
	rts



setCursorPosition:
	stx setCursorPositionX
	lda #%10000000
	jsr lcd_instruction
	tya
	clc
	adc #0
	beq setCursorLineOne
	jmp setCursorLineTwo
setCursorLineOne:
	txa
	clc
	adc #%10000000
	jsr lcd_instruction
	rts
	
setCursorLineTwo:
	txa
	clc
	adc #%11000000
	jsr lcd_instruction
	rts




playMusic:
	jsr updateSongCounter
	lda songCounter+1
	clc
	adc #<songBytes
	sta songPointer

	lda songCounter
	adc #>songBytes
	sta songPointer+1

	ldy #0
	lda (songPointer),y

	sta SoundPort

	rts

updateSongCounter:
	inc songTimer
	lda songTimer
	cmp #10
	beq songCountUp
	rts
songCountUp:

	stz songTimer

	lda songCounter+1
	clc
	adc #1
	sta songCounter+1

	lda songCounter
	adc #0
	sta songCounter


	lda songBytes+1
	sec
	sbc songCounter+1
	lda songBytes
	sbc songCounter
	bpl pastResetSongCounter
	stz songCounter
	lda #2
	sta songCounter+1
pastResetSongCounter:

	rts

resetPalette:
	sei
	lda #0
resetPaletteLoop:
	sta VGAPaletteARegister
	tay
	clc
	adc colorOffset
	sta VGAPaletteDRegister
	tya
	inc
	beq exitResetPaletteLoop 
	jmp resetPaletteLoop
exitResetPaletteLoop:
	lda #0 ;comment this line to make black cycle colors
	sta VGAPaletteARegister
	sta VGAPaletteDRegister
	
	lda #%01001001
	sta VGAPaletteARegister
	lda #%10010000
	sta VGAPaletteDRegister
	cli
	rts



resetTiles:
	sei
	lda #0
	sta VGAPaletteTempValues
	sta VGAPaletteTempValues+1
	ldx #127
resetTilesLoop:
	ldy #63
resetTilesPixelLoop:	
	
	txa
	sta VGAPaletteTempValues+1
	tya
	sta VGAPaletteTempValues
	rol VGAPaletteTempValues
	rol VGAPaletteTempValues

	ror VGAPaletteTempValues+1
	ror VGAPaletteTempValues
	ror VGAPaletteTempValues+1
	ror VGAPaletteTempValues

	lda VGAPaletteTempValues
	sta VGATileARegister
	lda VGAPaletteTempValues+1
	sta VGATileARegister+1

	phy
	

	lda	#<tileSet ;#<font
	sta VGAPaletteTempValues+2
	lda #>tileSet ;#>font
	sta VGAPaletteTempValues+3
	lda VGAPaletteTempValues+2
	clc
	adc VGAPaletteTempValues
	sta VGAPaletteTempValues+2
	lda VGAPaletteTempValues+3
	adc VGAPaletteTempValues+1
	sta VGAPaletteTempValues+3


	ldy #0;
	lda (VGAPaletteTempValues+2),Y

	sta VGATileDRegister
	sta VGATileDRegister
	sta VGATileDRegister
	ply

	dey
	bmi exitResetTilesPixelLoop
	jmp resetTilesPixelLoop
exitResetTilesPixelLoop:
	
	dex
	bmi exitResetTilesLoop
	jmp resetTilesLoop
exitResetTilesLoop:
	cli
	rts



	;replace tile at x,y with a
setTile:
	stx VGANametableARegister
	sty VGANametableARegister+1
	sta VGANametableDRegister
	rts

;replace tile y with tile x
replaceAllTile:
	sei
	stx VGAPaletteTempValues+4
	sty VGAPaletteTempValues+5
	;ldx #127
	ldy #63
setTilesPixelLoop:	
	
	lda VGAPaletteTempValues+4 ;txa
	sta VGAPaletteTempValues+1
	tya
	sta VGAPaletteTempValues
	rol VGAPaletteTempValues
	rol VGAPaletteTempValues

	ror VGAPaletteTempValues+1
	ror VGAPaletteTempValues
	ror VGAPaletteTempValues+1
	ror VGAPaletteTempValues

	lda VGAPaletteTempValues
	sta VGATileARegister
	lda VGAPaletteTempValues+1
	sta VGATileARegister+1

	lda VGAPaletteTempValues+5 ;txa
	sta VGAPaletteTempValues+1
	tya
	sta VGAPaletteTempValues
	rol VGAPaletteTempValues
	rol VGAPaletteTempValues

	ror VGAPaletteTempValues+1
	ror VGAPaletteTempValues
	ror VGAPaletteTempValues+1
	ror VGAPaletteTempValues


	phy
	

	lda	#<tileSet ;#<font
	sta VGAPaletteTempValues+2
	lda #>tileSet ;#>font
	sta VGAPaletteTempValues+3
	lda VGAPaletteTempValues+2
	clc
	adc VGAPaletteTempValues
	sta VGAPaletteTempValues+2
	lda VGAPaletteTempValues+3
	adc VGAPaletteTempValues+1
	sta VGAPaletteTempValues+3


	ldy #0;
	lda (VGAPaletteTempValues+2),Y

	sta VGATileDRegister
	sta VGATileDRegister
	sta VGATileDRegister
	ply

	dey
	bmi setResetTilesPixelLoop
	jmp setTilesPixelLoop
setResetTilesPixelLoop:

	cli
	rts

	



resetNametable:
	sei
	ldx #0
resetNametableLoop:
	ldy #127
resetNametablePixelLoop:	

	
	stx VGANametableARegister
	sty VGANametableARegister+1
	
	lda #0 

	sta VGANametableDRegister
	sta VGANametableDRegister
	sta VGANametableDRegister


	dey
	bmi exitResetNametablePixelLoop
	jmp resetNametablePixelLoop
exitResetNametablePixelLoop:
	
	dex
	beq exitResetNametableLoop
	jmp resetNametableLoop
exitResetNametableLoop:
	cli
	rts




setNametable:
	sei
	
	lda #<map
	sta VGAPaletteTempValues
	lda #>map
	sta VGAPaletteTempValues+1	
	
	;skip first two bytes (x,y resolution)
	lda VGAPaletteTempValues
	clc
	adc #2
	sta VGAPaletteTempValues
	lda #0
	adc VGAPaletteTempValues+1
	sta VGAPaletteTempValues+1

	ldy #1
	lda map,y 
	tay
	dey
	
setNametableYLoop:
	ldx map
	dex
setNametableXLoop:
	
	stx VGANametableARegister
	sty VGANametableARegister+1

	phy
	ldy #0;
	lda (VGAPaletteTempValues),Y
	sta VGANametableDRegister
	ply

	lda VGAPaletteTempValues
	clc
	adc #1
	sta VGAPaletteTempValues
	lda #0
	adc VGAPaletteTempValues+1
	sta VGAPaletteTempValues+1


	dex
	inx
	beq exitSetNametableXLoop
	dex
	jmp setNametableXLoop

exitSetNametableXLoop:

	dey
	iny
	beq exitSetNametableYLoop
	dey
	jmp setNametableYLoop

exitSetNametableYLoop:

	cli
	rts



animateTiles:
	sei
	lda movingTiles
	dec
	sta animateTilesLoopCount
animateTilesTileLoop:

	lda animateTilesLoopCount
	asl
	asl
	;sec
	;sbc #3
	inc
	tay
	lda movingTiles,y
	asl
	asl
	sta animateTilesCurrentTile

	iny
	lda movingTiles,y
	sta animateTilesMaxFrame
	iny
	lda movingTiles,y
	sta VGANametableARegister
	iny
	lda movingTiles,y
	sta VGANametableARegister+1

	ldy animateTilesCurrentTile
	lda animateTilesLoopCount
	asl
	asl
	tay
	iny
	lda movingTilesFrameCount,y
	inc
	sta movingTilesFrameCount,y
	sec
	sbc animateTilesMaxFrame
	beq resetFrame
	jmp pastResetFrame
resetFrame:
	lda #0
	sta movingTilesFrameCount,y
pastResetFrame:
	
	lda movingTilesFrameCount,y
	dey
	clc
	adc movingTilesFrameCount,y

	sta VGANametableDRegister


	dec animateTilesLoopCount
	lda animateTilesLoopCount
	clc
	adc #1
	beq exitAnimateTilesTileLoop
	jmp animateTilesTileLoop
exitAnimateTilesTileLoop:

	cli
	rts




playerMovement:
	lda JoystickPort
	and #%00000100
	cmp #%00000100
	beq playerMovementRight
	jmp afterPlayerMovementRight
playerMovementRight:
	lda playerVelX+2
	clc
	adc playerSpeed
	sta playerVelX+2
	lda playerVelX+1
	adc #0
	sta playerVelX+1
	lda playerVelX
	adc #0
	sta playerVelX
	;make him face right
	lda playerStatus
	and #%11111101
	ora #%00000010
	sta playerStatus
afterPlayerMovementRight:



	lda JoystickPort
	and #%00100000
	cmp #%00100000
	beq playerMovementLeft
	jmp afterPlayerMovementLeft
playerMovementLeft:
	lda playerVelX+2
	sec
	sbc playerSpeed
	sta playerVelX+2
	lda playerVelX+1
	sbc #0
	sta playerVelX+1
	lda playerVelX
	sbc #0
	sta playerVelX
	;make him face left
	lda playerStatus
	and #%11111101
	sta playerStatus
afterPlayerMovementLeft:



	lda JoystickPort
	and #%00001000
	cmp #%00001000
	;beq playerMovementDown
	jmp afterPlayerMovementDown
playerMovementDown:
	lda playerVelY+2
	clc
	adc playerSpeed
	sta playerVelY+2
	lda playerVelY+1
	adc #0
	sta playerVelY+1
	lda playerVelY
	adc #0
	sta playerVelY
afterPlayerMovementDown:



	;lda JoystickPort
	;and #%00010000
	;cmp #%00010000
	;beq playerMovementJump ;beq playerMovementUp
	
	lda JoystickPort
	and #%00010000
	tax
	lda playerStatus
	tay
	and #1
	sta playerStatus
	txa
	ora playerStatus
	sty playerStatus
	cmp #%00010001
	beq playerMovementJump
	
	jmp afterPlayerMovementUp
playerMovementUp:
	lda playerVelY+2
	sec
	sbc playerSpeed
	sta playerVelY+2
	lda playerVelY+1
	sbc #0
	sta playerVelY+1
	lda playerVelY
	sbc #0
	sta playerVelY
afterPlayerMovementUp:



	lda JoystickPort
	and #%00000010
	tax
	lda playerStatus
	tay
	and #1
	sta playerStatus
	txa
	ora playerStatus
	sty playerStatus
	cmp #%00000011
	beq playerMovementJump
	jmp afterPlayerMovementJump
playerMovementJump:
	
	lda playerStatus
	and #%11111110
	sta playerStatus

	lda playerVelY+2
	sec
	sbc #0
	sta playerVelY+2
	lda playerVelY+1
	sbc #jumpStrength
	sta playerVelY+1
	lda playerVelY
	sbc #0
	sta playerVelY
afterPlayerMovementJump:



	lda JoystickPort
	and #%10000000
	cmp #%10000000
	beq resetVGAButton
	jmp afterResetVGAButton
resetVGAButton:
	jsr resetTiles  
	stz colorOffset
	jsr resetPalette
	jsr resetNametable
	jsr setNametable
afterResetVGAButton:

	lda JoystickPort
	and #%01000000
	cmp #%01000000
	beq rainbowButton
	jmp afterrainbowButton
rainbowButton:
	;lda #1
	;sta colorOffset
	jsr playerRespawn
afterrainbowButton:



	rts



setPlayerSubVel:
	lda playerVelX
	sta playerSubVelX
	lda playerVelX+1
	sta playerSubVelX+1
	lda playerVelX+2
	sta playerSubVelX+2
	
	lda playerSubVelX
	rol
	ror playerSubVelX
	ror playerSubVelX+1
	ror playerSubVelX+2

	lda playerSubVelX
	rol
	ror playerSubVelX
	ror playerSubVelX+1
	ror playerSubVelX+2

	lda playerVelY
	sta playerSubVelY
	lda playerVelY+1
	sta playerSubVelY+1
	lda playerVelY+2
	sta playerSubVelY+2
	
	lda playerSubVelY
	rol
	ror playerSubVelY
	ror playerSubVelY+1
	ror playerSubVelY+2

	lda playerSubVelY
	rol
	ror playerSubVelY
	ror playerSubVelY+1
	ror playerSubVelY+2




	rts


playerPhysicsChangingPos:
	;update x pos
	lda playerPosX+2
	clc
	adc playerSubVelX+2
	sta playerPosX+2

	lda playerPosX+1
	adc playerSubVelX+1
	sta playerPosX+1
	
	lda playerPosX
	adc playerSubVelX
	sta playerPosX

	;update y pos
	lda playerPosY+2
	clc
	adc playerSubVelY+2
	sta playerPosY+2

	lda playerPosY+1
	adc playerSubVelY+1
	sta playerPosY+1
	
	lda playerPosY
	adc playerSubVelY
	sta playerPosY



	;lda #0
	;sec 
	;sbc playerVelX+2
	;lda #0
	;sbc playerVelX+1
	;lda #0
	;sbc playerVelX

	;beq playerNotMoving

	lda playerVelX
	ora playerVelX+1
	ora playerVelX+2
	cmp #0
	beq playerNotMoving



	;lda #255
	;sec 
	;sbc playerVelX+2
	;lda #255
	;sbc playerVelX+1
	;lda #255
	;sbc playerVelX

	lda playerVelX
	and playerVelX+1
	and playerVelX+2
	cmp #255
	beq playerNotMoving
	
	lda playerStatus
	and #%11111011
	ora #%00000100
	sta playerStatus
	



	rts

playerNotMoving:

	lda playerStatus
	and #%11111011
	sta playerStatus


	rts


playerPhysicsForces:
	
	;update x velocity
	lda playerVelX
	rol
	ror playerVelX
	ror playerVelX+1
	ror playerVelX+2

	;update y velocity


	;gravity
	lda playerVelY+2
	clc
	adc #50
	sta playerVelY+2

	lda playerVelY+1
	adc #0
	sta playerVelY+1
	
	lda playerVelY
	adc #0
	sta playerVelY


	;lda playerVelY
	;rol
	;ror playerVelY
	;ror playerVelY+1
	;ror playerVelY+2


	rts


playerUpdateTileDecPos:
	lda playerPosX+1
	sta playerTilePosX
	lda playerPosX+2
	sta playerDecPosX
	lda playerPosX
	ror
	ror playerTilePosX
	ror playerDecPosX
	ror
	ror playerTilePosX
	ror playerDecPosX
	ror
	ror playerTilePosX
	ror playerDecPosX


	lda playerPosY+1
	sta playerTilePosY
	lda playerPosY+2
	sta playerDecPosY
	lda playerPosY
	ror
	ror playerTilePosY
	ror playerDecPosY
	ror
	ror playerTilePosY
	ror playerDecPosY
	ror
	ror playerTilePosY
	ror playerDecPosY

	rts













playerCollisions:
	lda playerStatus
	and #%11111110
	sta playerStatus


	;top left

topLeftCollision:	
	stz	collisionDistX
	stz	collisionDistX+1
	stz	collisionDistX+2

	jsr playerUpdateTileDecPos
	lda playerTilePosX
	sta collisionCheckX
	lda playerTilePosY
	sta collisionCheckY
	jsr checkCollisionMaskTile

	;ldx #0
	;ldy #0
	;jsr setCursorPosition
	;lda collisionTileValue
	;jsr binaryToDecimalPrint

	jsr playerUpdateTileDecPos

	lda #1
	cmp collisionTileValue
	beq topLeft
	jmp pastTopLeft

topLeft:
	lda playerTilePosX
	inc
	sta collisionDistX+1
	asl collisionDistX+1
	rol collisionDistX
	asl collisionDistX+1
	rol collisionDistX
	asl collisionDistX+1
	rol collisionDistX
	lda #0
	sec
	sbc playerPosX+2
	sta collisionDistX+2
	lda collisionDistX+1
	sbc playerPosX+1
	sta collisionDistX+1
	lda collisionDistX
	sbc playerPosX
	sta collisionDistX

	lda playerTilePosY
	inc
	sta collisionDistY+1
	asl collisionDistY+1
	rol collisionDistY
	asl collisionDistY+1
	rol collisionDistY
	asl collisionDistY+1
	rol collisionDistY
	lda #0
	sec
	sbc playerPosY+2
	sta collisionDistY+2
	lda collisionDistY+1
	sbc playerPosY+1
	sta collisionDistY+1
	lda collisionDistY
	sbc playerPosY
	sta collisionDistY



	lda collisionDistX+2
	sec
	sbc collisionDistY+2
	lda collisionDistX+1
	sbc collisionDistY+1
	lda collisionDistX
	sbc collisionDistY
	bcc topLeftXIsLess

topLeftYIsLess:
	stz playerPosY
	stz playerPosY+1
	stz playerPosY+2
	stz playerVelY
	stz playerVelY+1
	stz playerVelY+2
	lda playerTilePosY
	inc 
	sta playerPosY+1
	clc
	rol	playerPosY+1
	rol playerPosY
	clc
	rol	playerPosY+1
	rol playerPosY
	clc
	rol	playerPosY+1
	rol playerPosY

	jmp pastTopLeft

topLeftXIsLess:
	stz playerPosX
	stz playerPosX+1
	stz playerPosX+2
	stz playerVelX
	stz playerVelX+1
	stz playerVelX+2
	lda playerTilePosX
	inc 
	sta playerPosX+1
	clc
	rol	playerPosX+1
	rol playerPosX
	clc
	rol	playerPosX+1
	rol playerPosX
	clc
	rol	playerPosX+1
	rol playerPosX

pastTopLeft:




	;top right



topRightCollision:	
	jsr playerUpdateTileDecPos
	lda playerTilePosX
	sta collisionCheckX
	lda playerTilePosY
	sta collisionCheckY
	inc collisionCheckX
	jsr checkCollisionMaskTile
	
	
	;ldx #4
	;ldy #0
	;jsr setCursorPosition
	;lda collisionTileValue
	;jsr binaryToDecimalPrint

	lda #1
	cmp collisionTileValue
	beq topRight
	jmp pastTopRight

topRight:

	lda playerTilePosX
	sta collisionDistX+1
	asl collisionDistX+1
	rol collisionDistX
	asl collisionDistX+1
	rol collisionDistX
	asl collisionDistX+1
	rol collisionDistX	
	lda playerPosX+2
	sec
	sbc #0
	sta collisionDistX+2
	lda playerPosX+1
	sbc collisionDistX+1
	sta collisionDistX+1
	lda playerPosX
	sbc collisionDistX
	sta collisionDistX


	lda playerTilePosY
	inc
	sta collisionDistY+1
	asl collisionDistY+1
	rol collisionDistY
	asl collisionDistY+1
	rol collisionDistY
	asl collisionDistY+1
	rol collisionDistY
	lda #0
	sec
	sbc playerPosY+2
	sta collisionDistY+2
	lda collisionDistY+1
	sbc playerPosY+1
	sta collisionDistY+1
	lda collisionDistY
	sbc playerPosY
	sta collisionDistY



	lda collisionDistX+2
	sec
	sbc collisionDistY+2
	lda collisionDistX+1
	sbc collisionDistY+1
	lda collisionDistX
	sbc collisionDistY
	bcc topRightXIsLess

topRightYIsLess:
	stz playerPosY
	stz playerPosY+1
	stz playerPosY+2
	stz playerVelY
	stz playerVelY+1
	stz playerVelY+2
	lda playerTilePosY
	inc 
	sta playerPosY+1
	clc
	rol	playerPosY+1
	rol playerPosY
	clc
	rol	playerPosY+1
	rol playerPosY
	clc
	rol	playerPosY+1
	rol playerPosY

	jmp pastTopRight

topRightXIsLess:
	stz playerPosX
	stz playerPosX+1
	stz playerPosX+2
	stz playerVelX
	stz playerVelX+1
	stz playerVelX+2
	lda playerTilePosX
	sta playerPosX+1
	clc
	rol	playerPosX+1
	rol playerPosX
	clc
	rol	playerPosX+1
	rol playerPosX
	clc
	rol	playerPosX+1
	rol playerPosX

pastTopRight:




	;bottom Left



bottomLeftCollision:	
	jsr playerUpdateTileDecPos
	lda playerTilePosX
	sta collisionCheckX
	lda playerTilePosY
	sta collisionCheckY
	inc collisionCheckY
	jsr checkCollisionMaskTile
	
	
	;ldx #0
	;ldy #1
	;jsr setCursorPosition
	;lda collisionTileValue
	;jsr binaryToDecimalPrint

	lda #1
	cmp collisionTileValue
	beq bottomLeft
	jmp pastBottomLeft

bottomLeft:

	lda playerTilePosX
	inc
	sta collisionDistX+1
	asl collisionDistX+1
	rol collisionDistX
	asl collisionDistX+1
	rol collisionDistX
	asl collisionDistX+1
	rol collisionDistX
	lda #0
	sec
	sbc playerPosX+2
	sta collisionDistX+2
	lda collisionDistX+1
	sbc playerPosX+1
	sta collisionDistX+1
	lda collisionDistX
	sbc playerPosX
	sta collisionDistX

	

	
	lda playerTilePosY
	sta collisionDistY+1
	asl collisionDistY+1
	rol collisionDistY
	asl collisionDistY+1
	rol collisionDistY
	asl collisionDistY+1
	rol collisionDistY	
	lda playerPosY+2	
	sec
	sbc #0
	sta collisionDistY+2
	lda playerPosY+1
	sbc collisionDistY+1
	sta collisionDistY+1
	lda playerPosY
	sbc collisionDistY
	sta collisionDistY

	lda collisionDistX+2
	sec
	sbc collisionDistY+2
	lda collisionDistX+1
	sbc collisionDistY+1
	lda collisionDistX
	sbc collisionDistY
	bcc bottomLeftXIsLess

bottomLeftYIsLess:
	stz playerPosY
	stz playerPosY+1
	stz playerPosY+2
	stz playerVelY
	stz playerVelY+1
	stz playerVelY+2
	lda playerTilePosY 
	sta playerPosY+1
	clc
	rol	playerPosY+1
	rol playerPosY
	clc
	rol	playerPosY+1
	rol playerPosY
	clc
	rol	playerPosY+1
	rol playerPosY
	
	lda playerStatus
	ora #1
	sta playerStatus

	jmp pastBottomLeft

bottomLeftXIsLess:
	stz playerPosX
	stz playerPosX+1
	stz playerPosX+2
	stz playerVelX
	stz playerVelX+1
	stz playerVelX+2
	lda playerTilePosX
	inc
	sta playerPosX+1
	clc
	rol	playerPosX+1
	rol playerPosX
	clc
	rol	playerPosX+1
	rol playerPosX
	clc
	rol	playerPosX+1
	rol playerPosX

pastBottomLeft:




	;bottom right



bottomRightCollision:	
	jsr playerUpdateTileDecPos
	lda playerTilePosX
	sta collisionCheckX
	lda playerTilePosY
	sta collisionCheckY
	inc collisionCheckX
	inc collisionCheckY
	jsr checkCollisionMaskTile

	
	;ldx #4
	;ldy #1
	;jsr setCursorPosition
	;lda collisionTileValue
	;jsr binaryToDecimalPrint

	lda #1
	cmp collisionTileValue
	beq bottomRight
	jmp pastBottomRight

bottomRight:



	
	lda playerTilePosX
	sta collisionDistX+1
	asl collisionDistX+1
	rol collisionDistX
	asl collisionDistX+1
	rol collisionDistX
	asl collisionDistX+1
	rol collisionDistX	
	lda playerPosX+2
	sec
	sbc #0
	sta collisionDistX+2
	lda playerPosX+1
	sbc collisionDistX+1
	sta collisionDistX+1
	lda playerPosX
	sbc collisionDistX
	sta collisionDistX



	
	
	lda playerTilePosY
	sta collisionDistY+1
	asl collisionDistY+1
	rol collisionDistY
	asl collisionDistY+1
	rol collisionDistY
	asl collisionDistY+1
	rol collisionDistY	
	lda playerPosY+2	
	sec
	sbc #0
	sta collisionDistY+2
	lda playerPosY+1
	sbc collisionDistY+1
	sta collisionDistY+1
	lda playerPosY
	sbc collisionDistY
	sta collisionDistY


	lda collisionDistX+2
	sec
	sbc collisionDistY+2
	lda collisionDistX+1
	sbc collisionDistY+1
	lda collisionDistX
	sbc collisionDistY
	bcc bottomRightXIsLess

bottomRightYIsLess:
	stz playerPosY
	stz playerPosY+1
	stz playerPosY+2
	stz playerVelY
	stz playerVelY+1
	stz playerVelY+2
	lda playerTilePosY 
	sta playerPosY+1
	clc
	rol	playerPosY+1
	rol playerPosY
	clc
	rol	playerPosY+1
	rol playerPosY
	clc
	rol	playerPosY+1
	rol playerPosY
		
	lda playerStatus
	ora #1
	sta playerStatus

	jmp pastBottomRight

bottomRightXIsLess:
	stz playerPosX
	stz playerPosX+1
	stz playerPosX+2
	stz playerVelX
	stz playerVelX+1
	stz playerVelX+2
	lda playerTilePosX
	sta playerPosX+1
	clc
	rol	playerPosX+1
	rol playerPosX
	clc
	rol	playerPosX+1
	rol playerPosX
	clc
	rol	playerPosX+1
	rol playerPosX

pastBottomRight:








	rts







playerSpikeCollision:
	lda playerPosX+2
	clc
	adc #%10000000
	sta playerPosX+2
	lda playerPosX+1
	adc #%00000011
	sta playerPosX+1
	lda playerPosX
	adc #0
	sta playerPosX

	lda playerPosY+2
	clc
	adc #%10000000
	sta playerPosY+2
	lda playerPosY+1
	adc #%00000011
	sta playerPosY+1
	lda playerPosY
	adc #0
	sta playerPosY


	jsr playerUpdateTileDecPos


	
	lda playerPosX+2
	sec
	sbc #%10000000
	sta playerPosX+2
	lda playerPosX+1
	sbc #%00000011
	sta playerPosX+1
	lda playerPosX
	sbc #0
	sta playerPosX

	lda playerPosY+2
	sec
	sbc #%10000000
	sta playerPosY+2
	lda playerPosY+1
	sbc #%00000011
	sta playerPosY+1
	lda playerPosY
	sbc #0
	sta playerPosY






	lda playerTilePosX
	sta collisionCheckX
	lda playerTilePosY
	sta collisionCheckY
	jsr checkCollisionMaskTile

	jsr playerUpdateTileDecPos

	lda #4
	cmp collisionTileValue
	bne topRightSpike
	jsr playerRespawn
	rts
topRightSpike:

	rts



playerWaterCollision:

	lda playerPosX+2
	clc
	adc #%10000000
	sta playerPosX+2
	lda playerPosX+1
	adc #%00000011
	sta playerPosX+1
	lda playerPosX
	adc #0
	sta playerPosX

	lda playerPosY+2
	clc
	adc #%10000000
	sta playerPosY+2
	lda playerPosY+1
	adc #%00000011
	sta playerPosY+1
	lda playerPosY
	adc #0
	sta playerPosY


	jsr playerUpdateTileDecPos


	
	lda playerPosX+2
	sec
	sbc #%10000000
	sta playerPosX+2
	lda playerPosX+1
	sbc #%00000011
	sta playerPosX+1
	lda playerPosX
	sbc #0
	sta playerPosX

	lda playerPosY+2
	sec
	sbc #%10000000
	sta playerPosY+2
	lda playerPosY+1
	sbc #%00000011
	sta playerPosY+1
	lda playerPosY
	sbc #0
	sta playerPosY






	lda playerTilePosX
	sta collisionCheckX
	lda playerTilePosY
	sta collisionCheckY
	jsr checkCollisionMaskTile

	jsr playerUpdateTileDecPos

	lda #2
	cmp collisionTileValue
	bne notTouchingWater
	
	lda #150
	sta playerSpeed

	;water gravity
	lda playerVelY+2
	sec
	sbc #60
	sta playerVelY+2

	lda playerVelY+1
	sbc #0
	sta playerVelY+1
	
	lda playerVelY
	sbc #0
	sta playerVelY

	lda playerStatus
	and #%11111110
	ora #%00000001
	sta playerStatus


	rts
notTouchingWater:
	lda #200
	sta playerSpeed
	rts


playerCheckPointCollision:
topLeftCheckPoint:
	jsr playerUpdateTileDecPos
	lda playerTilePosX
	sta collisionCheckX
	lda playerTilePosY
	sta collisionCheckY
	jsr checkCollisionMaskTile


	lda #8
	cmp collisionTileValue
	bne topRightCheckPoint
	
	lda playerTilePosX
	sta playerCheckPointX
	lda playerTilePosY
	sta playerCheckPointY

	lda #30
	ldx playerTilePosX
	ldy playerTilePosY
	jsr setTile


	rts
topRightCheckPoint:
	jsr playerUpdateTileDecPos
	inc playerTilePosX
	lda playerTilePosX
	sta collisionCheckX
	lda playerTilePosY
	sta collisionCheckY
	jsr checkCollisionMaskTile


	lda #8
	cmp collisionTileValue
	bne bottomLeftCheckPoint
	
	lda playerTilePosX
	sta playerCheckPointX
	lda playerTilePosY
	sta playerCheckPointY
	
	lda #30
	ldx playerTilePosX
	ldy playerTilePosY
	jsr setTile

	rts
bottomLeftCheckPoint:
	jsr playerUpdateTileDecPos
	lda playerTilePosX
	sta collisionCheckX
	inc playerTilePosY
	lda playerTilePosY
	sta collisionCheckY
	jsr checkCollisionMaskTile


	lda #8
	cmp collisionTileValue
	bne bottomRightCheckPoint
	
	lda playerTilePosX
	sta playerCheckPointX
	lda playerTilePosY
	sta playerCheckPointY
	
	lda #30
	ldx playerTilePosX
	ldy playerTilePosY
	jsr setTile

	rts

bottomRightCheckPoint:

	jsr playerUpdateTileDecPos
	inc playerTilePosX
	lda playerTilePosX
	sta collisionCheckX
	inc playerTilePosY
	lda playerTilePosY
	sta collisionCheckY
	jsr checkCollisionMaskTile


	lda #8
	cmp collisionTileValue
	bne afterBottomRightCheckPoint
	
	lda playerTilePosX
	sta playerCheckPointX
	lda playerTilePosY
	sta playerCheckPointY
	
	lda #30
	ldx playerTilePosX
	ldy playerTilePosY
	jsr setTile

	rts
afterBottomRightCheckPoint:

	rts



playerRespawn:
	lda #1
	sta colorOffset
	
	stz playerPosX
	stz playerPosX+1
	stz playerPosX+2
	stz playerPosY
	stz playerPosY+1
	stz playerPosY+2

	stz playerVelX
	stz playerVelX+1
	stz playerVelX+2
	stz playerVelY
	stz playerVelY+1
	stz playerVelY+2
	
	lda playerCheckPointX
	sta playerPosX+1
	
	asl playerPosX+1
	rol playerPosX
	asl playerPosX+1
	rol playerPosX
	asl playerPosX+1
	rol playerPosX

	lda playerCheckPointY
	sta playerPosY+1
	
	asl playerPosY+1
	rol playerPosY
	asl playerPosY+1
	rol playerPosY
	asl playerPosY+1
	rol playerPosY

	lda #60
	sta playerDeathCounter

	rts

playerRespawnSound:
	dec playerDeathCounter

	inc randomNumberPointer
	lda randomNumberPointer
	tay
	lda randomNumbers,y
	sta SoundPort

	rts

;given a pixel position it will return if the block is transparent 0 or solid 1
checkCollisionMaskPixel:	
	lda playerPosX	;collisionCheckX
	sta collisionMapAddress
	lda playerPosX+1	;collisionCheckX+1
	sta collisionMapAddress+1


	ror collisionMapAddress
	ror collisionMapAddress+1
	ror collisionMapAddress
	ror collisionMapAddress+1
	ror collisionMapAddress
	ror collisionMapAddress+1
	lda collisionMapAddress+1
	and #%00111111
	sta collisionMapAddress+1

	lda playerPosY	;collisionCheckY
	sta collisionMapAddress+2
	lda playerPosY+1	;collisionCheckY+1
	sta collisionMapAddress+3
	
	rol collisionMapAddress+3
	rol collisionMapAddress+2
	rol collisionMapAddress+3
	rol collisionMapAddress+2
	rol collisionMapAddress+3
	rol collisionMapAddress+2
	
	lda collisionMapAddress+3
	and #%11000000
	sta collisionMapAddress+3
	lda collisionMapAddress+2
	and #%00000111
	sta collisionMapAddress+2
	
	lda collisionMapAddress+3
	ora collisionMapAddress+1
	sta collisionMapAddress
	lda collisionMapAddress+2
	sta collisionMapAddress+1

		
	lda #<collisionMap
	clc
	adc collisionMapAddress
	sta collisionMapAddress

	lda #>collisionMap
	adc collisionMapAddress+1
	sta collisionMapAddress+1
	


	;ldx collisionMapAddress
	;lda collisionMapAddress+1
	;sta collisionMapAddress
	;stx collisionMapAddress+1

	ldy #0
	lda (collisionMapAddress),y
	sta collisionTileValue



	rts



;given a tile position it will return if the block is transparent 0 or solid 1
checkCollisionMaskTile:	
	rol collisionCheckX
	rol collisionCheckX

	ror collisionCheckY
	ror collisionCheckX
	ror collisionCheckY
	ror collisionCheckX

	lda collisionCheckX
	sta collisionMapAddress
	lda collisionCheckY
	and #%00000111
	sta collisionMapAddress+1
		
		
	lda #<collisionMap
	clc
	adc collisionMapAddress
	sta collisionMapAddress

	lda #>collisionMap
	adc collisionMapAddress+1
	sta collisionMapAddress+1

	;ldx collisionMapAddress
	;lda collisionMapAddress+1
	;sta collisionMapAddress
	;stx collisionMapAddress+1

	ldy #0
	lda (collisionMapAddress),y
	sta collisionTileValue



	rts





playerBottomOfScreenCollision:
	sec
	lda playerPosY+2
	sbc #0
	lda playerPosY+1
	sbc #224
	lda playerPosY
	sbc #0

	bcs hitFloor
	jmp pastHitFloor
hitFloor:
	stz playerPosY+2
	stz playerPosY
	lda #224
	sta playerPosY+1

	lda playerVelY
	rol
	bcs pastHitFloor

	stz playerVelY
	stz playerVelY+1
	stz playerVelY+2
pastHitFloor:
	rts 








setPlayerSprite:
	
	lda playerPosX+1
	sec
	sbc #3
	sta playerSpriteX+1
	lda playerPosX
	sbc #0
	sta playerSpriteX
	
	lda playerPosY+1
	sec
	sbc #1
	sta playerSpriteY+1
	lda playerPosY
	sbc #0
	sta playerSpriteY


	lda	playerSpriteY
	sta VGASpritePosXY
	lda playerSpriteY+1
	sta VGASpritePosXY
	lda playerSpriteX
	sta VGASpritePosXY
	lda playerSpriteX+1
	sta VGASpritePosXY

	lda playerSpriteCounter
	inc
	and #%00011111
	sta playerSpriteCounter
	lsr
	lsr
	lsr
	sta playerSprite

	lda playerStatus
	and #%00000100 ;isolate is moving
	cmp #%00000100 
	beq playerSpriteMoving

playerSpriteNotMoving:
	stz playerSprite

playerSpriteMoving:


	lda playerStatus
	and #%00000010 ;isolate facing
	eor #%00000010
	asl
	ora playerSprite
	sta playerSprite

	lda playerSprite
	sta VGASpriteIndex
	rts
	
messageLineOne:
	.asciiz "Made by:";"Waddle's Underg-" 
messageLineTwo:
	.asciiz "Breck Massey";"-round Adventure" 
	;Dangerous Duck: Cave Crusade
	;Waddle's Underground Adventure'


font:
	.incbin "font.bin"

map:
	.incbin "map.bin"

collisionMap:
	.incbin "collision.bin"

movingTiles:
	.incbin "mapMovingTiles.bin"

movingTilesFrameCountRom:
	.incbin "frameCountBytes.bin"

palette:
	.incbin "testPalette.bin"

tileSet:
	.incbin "tileSet.bin"

sinWaveTableHigh:
	.incbin "sinTableHigh.bin"

sinWaveTableLow:
	.incbin "sinTableLow.bin"

randomNumbers:
	.incbin "randomNumbers.bin"

songBytes:
	.incbin "testMusic1.bin"

nmi:

irq:
	phx
	phy
	pha


	inc randomNumberPointer

	jsr setPlayerSprite




	;animating certain tiles such as water ever 10 frames (6 times per second)
	inc animationFrame
	lda animationFrame
	sec
	sbc #10
	beq resetanimationFrame
	jmp pastResetanimationFrame
resetanimationFrame:
	stz animationFrame
	jsr animateTiles
pastResetanimationFrame:

	lda colorOffset
	beq afterPalletEffect
	jsr resetPalette
	lda colorOffset
	clc
	adc #5
	sta colorOffset
	bne afterPalletEffect
	stz colorOffset
	jsr resetPalette

afterPalletEffect:

	stz doneWithFrame

	pla
	ply
	plx

	rti

  .org $fffa
  .word nmi
  .word reset
  .word irq