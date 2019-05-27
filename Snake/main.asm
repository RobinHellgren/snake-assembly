//[En lista med registerdefinitioner]
.DEF rTemp         = r16
.DEF rStickDirection    = r23
.DEF rZero         = r17
.DEF rTemp2        = r19
.DEF rTemp4        = r20
.DEF rTemp3        = r21
.DEF rInter		   = r22
.DEF rTempBit      = r18
.DEF rADMUXx	   = r24
.DEF rADMUXy	   = r14
.DEF rStickInp	   = r15
.DEF rCount        = r25

//[En lista med konstanter]
.EQU NUM_COLUMNS   = 8
.EQU MAX_LENGTH    = 63 //ursprungligen 25
//[Datasegmentet]
.DSEG
matrix:   .BYTE 8
apple:    .BYTE 1
snake:    .BYTE MAX_LENGTH+1
snakeLengthIndex: .BYTE 1
updateCounter: .BYTE 1
Bout:	  .BYTE 1
Cout:      .BYTE 1
Dout:	  .BYTE 1
currentMovment: .BYTE 1
isGrowing:      .BYTE 1

//[Kodsegmentet]
.CSEG
// Interrupt vector table
.ORG 0x0000
     jmp init // Reset vector
//... fler interrupts
.ORG 0x0020
	 jmp interup
	 nop
.ORG INT_VECTORS_SIZE
init:

	 //Sätt värden på rADMUXx & rADMUXy
	 ldi rTemp, 0b01100100
	 mov rADMUXx, rTemp
	 ldi rTemp, 0b01100101
	 mov rADMUXy, rTemp	
     // Sätt stackpekaren till högsta minnesadressen
     ldi rTemp, HIGH(RAMEND)
     out SPH, rTemp
     ldi rTemp, LOW(RAMEND)
     out SPL, rTemp
	 //sätt interupt biten till 0
	 ldi rInter, 0b00000000
	 //configuration till timer enheten
	 ldi rTemp, 0b011
	 out TCCR0B, rTemp
	 ldi rTemp, 0b001
	 sts TIMSK0, rTemp
	 sei
	 //configuration till led enheten
	 ldi rTemp, 0b00001111
	 out DDRC, rTemp
	 ldi rTemp, 0b11111111
	 out DDRD, rTemp
	 out DDRB, rTemp
	 ldi rZero, 0
	 ldi rStickDirection, 0
	 //tilldela minne till matrixen
	 ldi XH, HIGH(matrix)
	 ldi XL, LOW(matrix)
	 rcall clearMatrix
	 //creates the snake
	 rcall snakeSet
	 //sets the joystick direction 2
	 ldi rStickDirection,2
	 //Spawn Apple
	 rcall spawnApple

	 //main progam loop
	 loop:
	 rcall stickXInput
	 rcall stickYInput
	 //rcall paintApple
	 rcall paintInit
	 rcall snakeUpdate
	 rcall appleCollision
	 
	 
	 
	 //sts matrix, rStickDirection
	 rcall outputMatrix
	
	 jmp loop
	 //wait for interupt
	 wait:
	 cpi rInter, 0
	 breq wait
	 ret
	 //turn off all the leds
	 dim:
	 out PortC, rZero
	 out PortD, rZero
	 out PortB, rZero
	 ret
	 //reset the matrix pointer
	 resetMatPoint:
	 ldi XH, HIGH(matrix)
	 ldi XL, LOW(matrix)
	 ret

	 //reset the snake pointer
	 resetSnakePoint:
	 ldi YH, HIGH(snake)
	 ldi YL, LOW(snake)
	 ret
	  clearMatrix:
	 //lägg in värden i matrixen
	 ldi rTemp, 0b00000000
	 sts matrix, rTemp
	 sts matrix+1, rTemp
	 sts matrix+2, rTemp
	 sts matrix+3, rTemp
	 sts matrix+4, rTemp
	 sts matrix+5, rTemp
	 sts matrix+6, rTemp
	 sts matrix+7, rTemp
	 ret
	 //output the matrix to the led display
	 outputMatrix:
	 //1
	 ld rTemp, X+
	 ldi rTemp2, 0b1
	 sts Cout, rTemp2
	 
	 ldi rTemp2, 0
	 sts Bout, rTemp2
	 sts Dout, rTemp2
	 

	 bst rTemp, 7
	 bld rTemp2, 6
	 sts Dout, rTemp2
	 
	 bst rTemp, 6
	 bld rTemp2, 7
	 sts Dout, rTemp2
	 
	 bst rTemp, 5
	 bld rTemp2, 0
	 sts Bout, rTemp2
	 
	 bst rTemp, 4
	 bld rTemp2, 1
	 sts Bout, rTemp2

	 bst rTemp, 3
	 bld rTemp2, 2
	 sts Bout, rTemp2

	 bst rTemp, 2
	 bld rTemp2, 3
	 sts Bout, rTemp2

	 bst rTemp, 1
	 bld rTemp2, 4
	 sts Bout, rTemp2

	 bst rTemp, 0
	 bld rTemp2, 5
	 sts Bout, rTemp2

	 lds rTemp2, Dout
	 out PortD, rTemp2

	 lds rTemp2, Bout
	 out PortB, rTemp2

	 lds rTemp2, Cout
	 out PortC, rTemp2
	 
	 rcall wait 
	 rcall dim
	 
	 ldi rInter, 0

	 //2
	 ld rTemp, X+
	 ldi rTemp2, 0b10
	 sts Cout, rTemp2
	 
	 ldi rTemp2, 0
	 sts Bout, rTemp2
	 sts Dout, rTemp2
	 

	 bst rTemp, 7
	 bld rTemp2, 6
	 sts Dout, rTemp2
	 
	 bst rTemp, 6
	 bld rTemp2, 7
	 sts Dout, rTemp2
	 
	 bst rTemp, 5
	 bld rTemp2, 0
	 sts Bout, rTemp2
	 
	 bst rTemp, 4
	 bld rTemp2, 1
	 sts Bout, rTemp2

	 bst rTemp, 3
	 bld rTemp2, 2
	 sts Bout, rTemp2

	 bst rTemp, 2
	 bld rTemp2, 3
	 sts Bout, rTemp2

	 bst rTemp, 1
	 bld rTemp2, 4
	 sts Bout, rTemp2

	 bst rTemp, 0
	 bld rTemp2, 5
	 sts Bout, rTemp2

	 lds rTemp2, Dout
	 out PortD, rTemp2

	 lds rTemp2, Bout
	 out PortB, rTemp2

	 lds rTemp2, Cout
	 out PortC, rTemp2
	 
	 rcall wait 
	 rcall dim
	 
	 ldi rInter, 0
	 
	 //3
	 ld rTemp, X+
	 ldi rTemp2, 0b100
	 sts Cout, rTemp2
	 
	 ldi rTemp2, 0
	 sts Bout, rTemp2
	 sts Dout, rTemp2
	 

	 bst rTemp, 7
	 bld rTemp2, 6
	 sts Dout, rTemp2
	 
	 bst rTemp, 6
	 bld rTemp2, 7
	 sts Dout, rTemp2
	 
	 bst rTemp, 5
	 bld rTemp2, 0
	 sts Bout, rTemp2
	 
	 bst rTemp, 4
	 bld rTemp2, 1
	 sts Bout, rTemp2

	 bst rTemp, 3
	 bld rTemp2, 2
	 sts Bout, rTemp2

	 bst rTemp, 2
	 bld rTemp2, 3
	 sts Bout, rTemp2

	 bst rTemp, 1
	 bld rTemp2, 4
	 sts Bout, rTemp2

	 bst rTemp, 0
	 bld rTemp2, 5
	 sts Bout, rTemp2

	 lds rTemp2, Dout
	 out PortD, rTemp2

	 lds rTemp2, Bout
	 out PortB, rTemp2

	 lds rTemp2, Cout
	 out PortC, rTemp2
	 
	 rcall wait 
	 rcall dim
	 
	 ldi rInter, 0
	 //4
	 ld rTemp, X+
	 ldi rTemp2, 0b0001000
	 sts Cout, rTemp2
	 
	 ldi rTemp2, 0
	 sts Bout, rTemp2
	 sts Dout, rTemp2
	 

	 bst rTemp, 7
	 bld rTemp2, 6
	 sts Dout, rTemp2
	 
	 bst rTemp, 6
	 bld rTemp2, 7
	 sts Dout, rTemp2
	 
	 bst rTemp, 5
	 bld rTemp2, 0
	 sts Bout, rTemp2
	 
	 bst rTemp, 4
	 bld rTemp2, 1
	 sts Bout, rTemp2

	 bst rTemp, 3
	 bld rTemp2, 2
	 sts Bout, rTemp2

	 bst rTemp, 2
	 bld rTemp2, 3
	 sts Bout, rTemp2

	 bst rTemp, 1
	 bld rTemp2, 4
	 sts Bout, rTemp2

	 bst rTemp, 0
	 bld rTemp2, 5
	 sts Bout, rTemp2

	 lds rTemp2, Dout
	 out PortD, rTemp2

	 lds rTemp2, Bout
	 out PortB, rTemp2

	 lds rTemp2, Cout
	 out PortC, rTemp2
	 
	 rcall wait 
	 rcall dim
	 
	 ldi rInter, 0
	 //5
	 ld rTemp, X+
	 ldi rTemp2, 0
	 sts Cout, rTemp2
	 
	 ldi rTemp2, 0
	 sts Bout, rTemp2
	 ldi rTemp2, 4
	 sts Dout, rTemp2
	 

	 bst rTemp, 7
	 bld rTemp2, 6
	 sts Dout, rTemp2
	 
	 bst rTemp, 6
	 bld rTemp2, 7
	 sts Dout, rTemp2
	 
	 bst rTemp, 5
	 bld rTemp2, 0
	 sts Bout, rTemp2
	 
	 bst rTemp, 4
	 bld rTemp2, 1
	 sts Bout, rTemp2

	 bst rTemp, 3
	 bld rTemp2, 2
	 sts Bout, rTemp2

	 bst rTemp, 2
	 bld rTemp2, 3
	 sts Bout, rTemp2

	 bst rTemp, 1
	 bld rTemp2, 4
	 sts Bout, rTemp2

	 bst rTemp, 0
	 bld rTemp2, 5
	 sts Bout, rTemp2

	 lds rTemp2, Dout
	 out PortD, rTemp2

	 lds rTemp2, Bout
	 out PortB, rTemp2

	 lds rTemp2, Cout
	 out PortC, rTemp2
	 
	 rcall wait 
	 rcall dim
	 
	 ldi rInter, 0
	 //6
	 ld rTemp, X+
	 ldi rTemp2, 0
	 sts Cout, rTemp2
	 
	 ldi rTemp2, 0
	 sts Bout, rTemp2
	 ldi rTemp2, 8
	 sts Dout, rTemp2
	 

	 bst rTemp, 7
	 bld rTemp2, 6
	 sts Dout, rTemp2
	 
	 bst rTemp, 6
	 bld rTemp2, 7
	 sts Dout, rTemp2
	 
	 bst rTemp, 5
	 bld rTemp2, 0
	 sts Bout, rTemp2
	 
	 bst rTemp, 4
	 bld rTemp2, 1
	 sts Bout, rTemp2

	 bst rTemp, 3
	 bld rTemp2, 2
	 sts Bout, rTemp2

	 bst rTemp, 2
	 bld rTemp2, 3
	 sts Bout, rTemp2

	 bst rTemp, 1
	 bld rTemp2, 4
	 sts Bout, rTemp2

	 bst rTemp, 0
	 bld rTemp2, 5
	 sts Bout, rTemp2

	 lds rTemp2, Dout
	 out PortD, rTemp2

	 lds rTemp2, Bout
	 out PortB, rTemp2

	 lds rTemp2, Cout
	 out PortC, rTemp2
	 
	 rcall wait 
	 rcall dim
	 
	 ldi rInter, 0
	 //7
	 ld rTemp, X+
	 ldi rTemp2, 0
	 sts Cout, rTemp2
	 
	 ldi rTemp2, 0
	 sts Bout, rTemp2
	 ldi rTemp2, 16
	 sts Dout, rTemp2
	 

	 bst rTemp, 7
	 bld rTemp2, 6
	 sts Dout, rTemp2
	 
	 bst rTemp, 6
	 bld rTemp2, 7
	 sts Dout, rTemp2
	 
	 bst rTemp, 5
	 bld rTemp2, 0
	 sts Bout, rTemp2
	 
	 bst rTemp, 4
	 bld rTemp2, 1
	 sts Bout, rTemp2

	 bst rTemp, 3
	 bld rTemp2, 2
	 sts Bout, rTemp2

	 bst rTemp, 2
	 bld rTemp2, 3
	 sts Bout, rTemp2

	 bst rTemp, 1
	 bld rTemp2, 4
	 sts Bout, rTemp2

	 bst rTemp, 0
	 bld rTemp2, 5
	 sts Bout, rTemp2

	 lds rTemp2, Dout
	 out PortD, rTemp2

	 lds rTemp2, Bout
	 out PortB, rTemp2

	 lds rTemp2, Cout
	 out PortC, rTemp2
	 
	 rcall wait 
	 rcall dim
	 
	 ldi rInter, 0
	 //8
	 ld rTemp, X+
	 ldi rTemp2, 0
	 sts Cout, rTemp2
	 
	 ldi rTemp2, 0
	 sts Bout, rTemp2
	 ldi rTemp2, 32
	 sts Dout, rTemp2
	 

	 bst rTemp, 7
	 bld rTemp2, 6
	 sts Dout, rTemp2
	 
	 bst rTemp, 6
	 bld rTemp2, 7
	 sts Dout, rTemp2
	 
	 bst rTemp, 5
	 bld rTemp2, 0
	 sts Bout, rTemp2
	 
	 bst rTemp, 4
	 bld rTemp2, 1
	 sts Bout, rTemp2

	 bst rTemp, 3
	 bld rTemp2, 2
	 sts Bout, rTemp2

	 bst rTemp, 2
	 bld rTemp2, 3
	 sts Bout, rTemp2

	 bst rTemp, 1
	 bld rTemp2, 4
	 sts Bout, rTemp2

	 bst rTemp, 0
	 bld rTemp2, 5
	 sts Bout, rTemp2

	 lds rTemp2, Dout
	 out PortD, rTemp2

	 lds rTemp2, Bout
	 out PortB, rTemp2

	 lds rTemp2, Cout
	 out PortC, rTemp2
	 
	 rcall wait 
	 rcall dim
	 
	 ldi rInter, 0
	 rcall resetMatPoint
	 ret
	 
	 
	 //interup subrutinen
	 interup:
	 ldi rInter, 0b00000001
	 reti

	 stickYInput:
	 sts ADMUX, rADMUXx
	 ldi rTemp, 0b11000111
	 sts ADCSRA, rTemp

	 stickYLoop:
	 lds rTemp, ADCSRA
	 sbrc rTemp, ADSC
	 jmp stickXLoop
	 lds rTemp, ADCL
	 lds rStickInp, ADCH
	 ldi rTemp, 200
	 cp rStickInp, rTemp
	 brsh YPos
	 ldi rTemp, 50
	 cp rStickInp, rTemp
	 brlo YNeg 
	 ret


	 
	 stickXInput:
	 sts ADMUX, rADMUXy
	 ldi rTemp, 0b11000111
	 sts ADCSRA, rTemp

	 stickXLoop:
	 lds rTemp, ADCSRA
	 sbrc rTemp, ADSC
	 jmp stickYLoop
	 lds rTemp, ADCL
	 lds rStickInp, ADCH
	 
	 ldi rTemp, 200
	 cp rStickInp, rTemp
	 brsh XNeg
	 ldi rTemp, 50
	 cp rStickInp, rTemp
	 brlo XPos
	  
	 ret

	 
	 XPos:
	 ldi rStickDirection , 2
	 ret

	 XNeg:
	 ldi rStickDirection , 4
	 ret

	 YPos:
	 ldi rStickDirection , 1
	 ret

	 YNeg:
	 ldi rStickDirection , 3
	 ret

	 //Sätter startvärden för ormen
	 snakeSet:
	 ldi rTemp, 2
	 sts currentMovment, rTemp
	 ldi rTemp, 2
	 sts snakeLengthIndex, rTemp
	 rcall resetSnakePoint
	 ldi rTemp, 0b00010010
	 ST Y+, rTemp
	 ldi rTemp,0b00100010
	 st Y+, rTemp
	 ldi rTemp,0b00110010
	 st Y+, rTemp
	 rcall resetSnakePoint
	 ret

	 return:
	 ret

	 growSnake:
	 ldi rTemp,0
	 sts isGrowing,rTemp
	 ldi rCount,0
	 lds rTemp, snakeLengthIndex 

	 walkthroughSnake:
	 subi rCount,-1
	 subi YL,-1
	 cp rCount,rTemp
	 brne walkthroughSnake
	 mov rCount,rTemp

	 reverseWalkthroughSnake:
	 subi rCount,1
	 subi YL,1
	 ld rTemp,Y
	 subi YL,-1
	 cpi rCount,0
	 brne reverseWalkthroughSnake
	 rcall resetSnakePoint

	 snakeUpdate:
	 lds rTemp,isGrowing
	 cpi rTemp,1
	 brsh growSnake
	 //cpi rInter, 0
	 //BREQ return
	 lds rTemp, updateCounter
	 subi rTemp, -1
	 sts updateCounter, rTemp
	 lds rTemp, updateCounter
	 cpi rTemp, 100
	 brlo return 	
	 ldi rTemp, 0
	 sts updateCounter, rTemp
	 ldi rCount,0

	 snakeUpdateSwitchBP:
	 subi rCount,-1
	 subi YL,-1
	 ld rTemp2,Y
	 subi YL,1
	 st Y+,rTemp2
	 lds rTemp, snakeLengthIndex
	 cp rCount, rTemp
	 brne snakeUpdateSwitchBP

	 lds rTemp, currentMovment
	 //sub rTemp,rStickDirection
	 cpi	rTemp,1
	 breq currentDirectionUp

	 cpi	rTemp,2
	 breq currentDirectionRight

	 cpi	rTemp,3
	 breq currentDirectionDown

	 cpi	rTemp,4
	 breq currentDirectionLeft
	 
	 currentDirectionUp:
	 cpi rStickDirection,3
	 breq noNewDirection
	 jmp newDirection

	 currentDirectionRight:
	 cpi rStickDirection,4
	 breq noNewDirection
	 jmp newDirection

	 currentDirectionDown:
	 cpi rStickDirection,1
	 breq noNewDirection
	 jmp newDirection

	 currentDirectionLeft:
	 cpi rStickDirection,2
	 breq noNewDirection
	 jmp newDirection

	 newDirection:
	 
	 cpi rStickDirection,1
	 breq newDirectionUP

	 cpi rStickDirection,2
	 breq newDirectionRight

	 cpi rStickDirection,3
	 breq newDirectionDown

	 cpi rStickDirection,4
	 breq newDirectionLeft


	 noNewDirection:
	 cpi rTemp,1
	 breq noNewDirectionUp

	 cpi rTemp,2
	 breq noNewDirectionRight

	 cpi rTemp,3
	 breq noNewDirectionDown

	 cpi rTemp,4
	 breq noNewDirectionLeft

	 noNewDirectionUp:

	 ldi rTemp,1
	 jmp moveSnake

	 noNewDirectionRight:
	 ldi rTemp,-16
	 jmp moveSnake

	 noNewDirectionDown:
	 ldi rTemp,-1
	 jmp moveSnake

	 noNewDirectionLeft:
	 ldi rTemp,16
	 jmp moveSnake


	 moveSnake:
	 ld rTemp2,Y
	 sub rTemp2, rTemp
	 cpi rTemp2, 144
	 BRSH wallWrapX9
	 cpi rTemp2,16
	 BRLO wallWrapX0
	 mov rTemp3,rTemp2
	 andi rTemp3, 0b00001111
	 cpi rTemp3, 9
	 BRSH wallWrapY9
	 cpi rTemp3, 1
	 BRLO wallWrapY0
	 st Y,rTemp2
	 rcall resetSnakePoint
	 ret

	 newDirectionUp:
	 sts currentMovment, rStickDirection
	 ldi rTemp,1
	 jmp moveSnake
	 
	 newDirectionRight:
	 sts currentMovment, rStickDirection
	 ldi rTemp,-16
	 jmp moveSnake

	 newDirectionDown:
	 sts currentMovment, rStickDirection
	 ldi rTemp,-1
	 jmp moveSnake

	 newDirectionLeft:
	 sts currentMovment, rStickDirection
	 ldi rTemp,16
	 jmp moveSnake

	 wallWrapX9:
	 ldi rTemp3, 0b00001111
	 and rTemp2,rTemp3
	 subi rTemp2, -16
	 st Y,rTemp2
	 rcall resetSnakePoint
	 ret

	 wallWrapX0:
	 ldi rTemp3, 0b00001111
	 and rTemp2,rTemp3
	 subi rTemp2, -128
	 st Y,rTemp2
	 rcall resetSnakePoint
	 ret

	 wallWrapY9:
	 andi rTemp2,0b11110000
	 subi rTemp2, -1
	 st Y,rTemp2
	 rcall resetSnakePoint
	 ret

	 wallWrapY0:
	 andi rTemp2,0b11110000
	 subi rTemp2, -8
	 st Y,rTemp2
	 rcall resetSnakePoint
	 ret


	 paintInit:
	 rcall clearMatrix
	 ldi rCount,0
	 push rCount

	 snakePaint:
	 ld rTemp2, Y
	 mov rTemp3,rTemp2
	 ldi rTemp4,0b11110000
	 and rTemp2,rTemp4
	 LSR rTemp2
	 LSR rTemp2
	 LSR rTemp2
	 LSR rTemp2
	 ldi rTemp4,0b00001111
	 and rTemp3,rTemp4
	 
	 ldi rTemp,9
	 ldi rCount,1
	 sub rTemp, rTemp3
	 
	 toggleMatrixrow:
	 cp rCount,rTemp3 
	 breq setBitMatrix
	 adiw X,1
	 subi rCount,-1
	 cp rCount,rTemp3
	 brne toggleMatrixrow
	
	
	 setBitMatrix:
	 ldi rCount,1
	 ld rTemp4,X
	 ldi rTemp3, 0b10000000
	 cp rCount,rTemp2
	 breq orOperationMatrix

	 logicalShiftMatrixBit:
	 lsr rTemp3
	 subi rCount,-1
	 cp rCount,rTemp2
	 brne logicalShiftMatrixBit
	 
	 orOperationMatrix:
	 or rTemp4,rTemp3
	 ST X,rTemp4
	 rcall resetMatPoint
	 

	 adiw Y,1
	 subi rCount,-1
	 lds rTemp,snakeLengthIndex
	 subi rTemp,-1
	 pop rCount
	 subi rCount,-1
	 cp rCount,rTemp
	 push rCount
	 brne snakePaint
	 pop rCount
	 rcall resetSnakePoint

	 //paint apple
	 paintApple:
	 lds rTemp, apple
	 mov rTemp2, rTemp
	 andi rTemp2, 0b00001111
     andi rTemp, 0b11110000
	 lsr rTemp
	 lsr rTemp
	 lsr rTemp
	 lsr rTemp
	 ldi rCount,0

	 appleMatrixRowToggle:
	 subi rCount,-1
	 cp rCount,rTemp2 
	 breq setAppleBitMatrix
	 adiw X,1
	 jmp appleMatrixRowToggle
	 
	 
	 setAppleBitMatrix:
	 ldi rCount,1
	 ld rTemp4,X
	 ldi rTemp3, 0b10000000
	 cp rCount,rTemp
	 breq appleOrOperationMatrix

	 appleLogicalShiftMatrixBit:
	 lsr rTemp3
	 subi rCount,-1
	 cp rCount,rTemp
	 brne appleLogicalShiftMatrixBit
	 
	 appleOrOperationMatrix:
	 or rTemp4,rTemp3
	 ST X,rTemp4
	 rcall resetMatPoint
	 ret

	 spawnApple:
	 ldi rTemp, 0b10000010
	 sts apple,rTemp
	 ret
	 //X coordinate random
	 sts ADMUX, rADMUXx
	 ldi rTemp, 0b11000111
	 sts ADCSRA, rTemp

	 appleXLoop:
	 lds rTemp, ADCSRA
	 sbrc rTemp, ADSC
	 jmp appleXLoop
	 lds rTemp, ADCL
	 mov rTemp2,rTemp
	 mul rTemp,rTemp2
	 mul rTemp,rTemp2
	 mul rTemp,rTemp2
	 mul rTemp,rTemp2
	 mul rTemp,rTemp2
	 andi rTemp,0b0111
	 subi rTemp,-1
	 lsl rTemp
     lsl rTemp
     lsl rTemp
	 lsl rTemp
	 sts apple, rTemp
	 sts matrix,rTemp

	 //Y coordinate random
	 sts ADMUX, rADMUXy
	 ldi rTemp, 0b11000111
	 sts ADCSRA, rTemp

	 appleYLoop:
	 lds rTemp, ADCSRA
	 sbrc rTemp, ADSC
	 jmp appleYLoop
	 lds rTemp, ADCL
	 lds rTemp, ADCL
	 mov rTemp2,rTemp
	 mul rTemp,rTemp2
	 mul rTemp,rTemp2
	 mul rTemp,rTemp2
	 mul rTemp,rTemp2
	 mul rTemp,rTemp2
	 lds rTemp2, apple
	 andi rTemp,0b00000111
	 subi rTemp,-1
	 add rTemp,rTemp2
	 sts apple, rTemp
	   
	 ret


	 appleCollision:
	 rcall resetSnakePoint
	 lds rTemp, apple
	 ldi rCount, 0
	 lds rTemp2,snakeLengthIndex
	 findSnakeHead:
	 subi rCount,-1
	 subi YL,-1
	 cp rCount,rTemp2
	 brne findSnakeHead
	 ld rTemp2,Y
	 cp rTemp2,rTemp
	 brne return2
	 ldi rTemp,0b01101000
	 lds rTemp3,snakeLengthIndex
	 subi rTemp3,-1
	 sts snakeLengthIndex,rTemp3
	 ldi rTemp4,1
	 sts isGrowing,rTemp4
	 sts apple,rTemp
	 return2:
	 rcall resetSnakePoint
	 ret