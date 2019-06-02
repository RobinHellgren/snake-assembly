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
appleRand:		.BYTE 1

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

	 //Set values for the configuration of rADMUXx & rADMUXy
	 ldi rTemp, 0b01100100
	 mov rADMUXx, rTemp
	 ldi rTemp, 0b01100101
	 mov rADMUXy, rTemp	
     // Configure the stackpointer
     ldi rTemp, HIGH(RAMEND)
     out SPH, rTemp
     ldi rTemp, LOW(RAMEND)
     out SPL, rTemp
	 //set the interupt bit to 0
	 ldi rInter, 0b00000000
	 //configuration tp the timer unit
	 ldi rTemp, 0b011
	 out TCCR0B, rTemp
	 ldi rTemp, 0b001
	 sts TIMSK0, rTemp
	 sei
	 //configuration to led unit
	 ldi rTemp, 0b00001111
	 out DDRC, rTemp
	 ldi rTemp, 0b11111111
	 out DDRD, rTemp
	 out DDRB, rTemp
	 ldi rZero, 0
	 ldi rStickDirection, 0
	 //assign memory to the matrix representing the led screen
	 ldi XH, HIGH(matrix)
	 ldi XL, LOW(matrix)
	 rcall clearMatrix
	 //creates the snake
	 rcall snakeSet
	 //sets the joystick direction to 2 for the initial movement
	 ldi rStickDirection,2
	 //Spawn the Apple
	 ldi rTemp,0b01100110
	 sts appleRand,rTemp
	 rcall spawnApple

	 //main progam loop
	 loop:
	 //gather the input from the joystick
	 rcall stickXInput
	 rcall stickYInput
	 //paint the objects to the matrix
	 rcall paintInit
	 //Update the state of the snake
	 rcall snakeUpdateCheck
	 //Output the matrix to the led screen
	 rcall outputMatrix
	 //repeat the main program loop
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
	 //clear the matrix
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
	 fillMatrix:
	 //fill the matrix
	 ldi rTemp, 0b11111111
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
	 //row 1 - translation to the output ports
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

	 //Output the translated values
	 lds rTemp2, Dout
	 out PortD, rTemp2

	 lds rTemp2, Bout
	 out PortB, rTemp2

	 lds rTemp2, Cout
	 out PortC, rTemp2
	 //wait for a interupt
	 rcall wait 
	 //turn off all the leds
	 rcall dim
	 //reset the interupt variable
	 ldi rInter, 0

	 //row 2 - translation to the output ports
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
	 
	 //row 3 - translation to the output ports
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
	 
	 //row 4 - translation to the output ports
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
	 
	 //row 5 - translation to the output ports
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
	 
	 //row 6 - translation to the output ports
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
	 
	 //row 7 - translation to the output ports
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
	 
	 //row 8 - translation to the output ports
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
	 //reset the matrix pointer
	 rcall resetMatPoint
	 ret
	 
	 
	 //the interup subrutine
	 interup:
	 ldi rInter, 0b00000001
	 reti
	 //Gather input from the Y axis of the joystick
	 stickYInput:
	 //configure the AD unit
	 sts ADMUX, rADMUXx
	 ldi rTemp, 0b11000111
	 sts ADCSRA, rTemp
	 //loop untill the AD convertion is finished
	 stickYLoop:
	 lds rTemp, ADCSRA
	 sbrc rTemp, ADSC
	 jmp stickXLoop
	 //get the value from the AD converter
	 lds rTemp, ADCL
	 lds rStickInp, ADCH
	 //check if the input is over the thresholds for either direction
	 ldi rTemp, 200
	 cp rStickInp, rTemp
	 brsh YPos
	 ldi rTemp, 50
	 cp rStickInp, rTemp
	 mov rTemp4,rTemp
	 brlo YNeg 
	 ret


	 //Gather the input from the X-axis
	 stickXInput:
	 //configure the AD converter
	 sts ADMUX, rADMUXy
	 ldi rTemp, 0b11000111
	 sts ADCSRA, rTemp
	 //wait untill the converter is finished
	 stickXLoop:
	 lds rTemp, ADCSRA
	 sbrc rTemp, ADSC
	 jmp stickYLoop
	 //get the input from the joystick
	 lds rTemp, ADCL
	 lds rStickInp, ADCH
	
	 //check in the input exceeds the thresholds and branch if they do
	 ldi rTemp, 200
	 cp rStickInp, rTemp
	 brsh XNeg
	 ldi rTemp, 50
	 cp rStickInp, rTemp
	 brlo XPos
	  
	 ret

	 addToAppleRand:
	 lds rTemp,appleRand
	 add rTemp, rStickInp
	 sts appleRand, rTemp
	 ret

	 //Change the direction to positive X
	 XPos:
	 ldi rStickDirection , 2
	 rcall addToAppleRand
	 ret
	 //Change the direction to negative X
	 XNeg:
	 ldi rStickDirection , 4
	 rcall addToAppleRand
	 ret
	 //Change the direction to positive Y
	 YPos:
	 ldi rStickDirection , 1
	 rcall addToAppleRand
	 ret
	 //Change the direction to negative Y
	 YNeg:
	 ldi rStickDirection , 3
	 rcall addToAppleRand
	 ret

	 //Sets initial values for the snake
	 snakeSet:
	 ldi rTemp,0
	 sts isGrowing,rTemp
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
	 //This part of the code is called up on if the isGrowing variabel is set to 1 extending the aray by one and then
	 //updating the all the bodyparts of the snake the coordinates of the next body part so that the body can grow corectly
	 ldi rCount,0
	 sts isGrowing,rCount
	 lds rTemp, snakeLengthIndex
	 subi rTemp,-1
	 sts snakeLengthIndex,rTemp

	 walkthroughSnake:
	 subi rCount,-1
	 subi YL,-1
	 cp rCount,rTemp
	 brne walkthroughSnake

	 reverseWalkthroughSnake:
	 subi rCount,1
	 subi YL,1
	 ld rTemp,Y
	 subi YL,-1
	 subi rCount,-1
	 st Y, rTemp
	 subi rCount,1
	 subi YL,1
	 cpi rCount,0
	 brne reverseWalkthroughSnake
	 rcall resetSnakePoint
	 jmp snakeUpdate //When the snake is grown the code jumps back to snakeUpdate

	 snakeUpdateCheck:
	 //updates and checks the updateCounter to see if its time to update the positions of the snake body, if not returning to the main loop
	 lds rTemp, updateCounter
	 subi rTemp, -1
	 sts updateCounter, rTemp
	 lds rTemp, updateCounter
	 cpi rTemp, 100
	 brlo return

	 snakeUpdate:
	 //Checks if the snake should grow if so jumping to growSnake if not setting the the initial values for snakeUpdateSwitchBP
	 lds rTemp,isGrowing
	 cpi rTemp,0
	 brne growSnake 	
	 ldi rTemp, 0
	 sts updateCounter, rTemp
	 ldi rCount,0

	 snakeUpdateSwitchBP:
	 //Runs throung the whole body of the snake giving eack bodypart the value of the next in the array untill reaching the last bodypart before the head
	 subi rCount,-1
	 subi YL,-1
	 ld rTemp2,Y
	 subi YL,1
	 st Y+,rTemp2
	 lds rTemp, snakeLengthIndex
	 cp rCount, rTemp
	 brne snakeUpdateSwitchBP
	 //when the head is reached the head will move one step in the direction indicated by the joystick
	 //or if no need direction is indicated cotinuing in the same direction as in previus update

	 lds rTemp, currentMovment
	 
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
	 //called upon i ther is no new input from the joystick then seting the value the should be subtracted from the coordinates to give the snake head it's new possition
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
	 //updates the snakes heads position to the correct coordinates by loading the current coordinates and updating the based on the value set earlier eigthe in noNewDirection or newDirection
	 //here the code also checks if the head has moved outside of the ledmatrix and if so loads the correct wallWrap subroutine to move the head to the opposit side if the ledmatrix
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

	 checkCollisions:
	 //calls upon the Collision subroutines before returning to the main loop
	 rcall appleCollision
	 rcall snakeCollision
	 ret

	 newDirectionUp:
	 //called upon i there is new input from the joystick then seting the value the should be subtracted from the coordinates to give the snake head it's new possition
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
	 //This part of the code calls upon the subroutine clearMatrix and resets the counter to 0 and saves it to the stack before continuing
	 rcall clearMatrix
	 ldi rCount,0
	 push rCount

	 snakePaint:
	 //Here the diffrent parts of the snake is read and split up into two regestrys one for the x coordinate and one for the y coordinate.
	 //After whick the 4 least significant bits is removed from the x coordinate and the 4 most significant bits are removed from  the y coordinates.
	 //The x coordinate being the 4 most significant bits needs to be logicaly shifted to the right until they become the 4 least significant bits so it gives us the coorect value.
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
	 ldi rCount,1 //This is why we need to save rCount to the stack
	 sub rTemp, rTemp3
	 
	 toggleMatrixrow:
	 //This part of the code selects the correct row
	 cp rCount,rTemp3 
	 breq setBitMatrix
	 adiw X,1
	 subi rCount,-1
	 cp rCount,rTemp3
	 brne toggleMatrixrow
	
	
	 setBitMatrix:
	 //sets the initial values needed for logicalShiftMatrixBit
	 ldi rCount,1
	 ld rTemp4,X
	 ldi rTemp3, 0b10000000
	 cp rCount,rTemp2
	 breq orOperationMatrix

	 logicalShiftMatrixBit:
	 //sets sets the right bit in the row of the matrix to 1 by shifting a 1 throuh a byte starting at the most significant bits until its i the correct position
	 lsr rTemp3
	 subi rCount,-1
	 cp rCount,rTemp2
	 brne logicalShiftMatrixBit
	 
	 orOperationMatrix:
	 //makes an or operation with prevously loades values from the row and the bit we wish to set to one
	 or rTemp4,rTemp3
	 ST X,rTemp4
	 rcall resetMatPoint
	 
	 //The pointer is then moved one step  to look at the next part of the snake body, checking if the is the head if not this loop is repeated
	 //otherwise the snake pointer is reset and the apple will be loaded into the matrix 
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

	 //paintApple works in a similar way as the snakePaint does except for just being a single byte instead of an array of bytes
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
	 //this takes the value prevusly generated and stored in appleRand and sets the new position of the apple
	 lds rTemp, appleRand
	 mov rTemp2,rTemp
	 andi rTemp,0b01110000
	 andi rTemp2,0b00000111
	 subi rTemp,-16
	 subi rTemp2,-1
	 or rTemp,rTemp2
	 sts apple,rTemp
	 ret


	 appleCollision:
	 //Sets the initial values needed for finding the head of the snake which is the last position of the snake array
	 rcall resetSnakePoint
	 lds rTemp, apple
	 ldi rCount, 0
	 lds rTemp2,snakeLengthIndex

	 findSnakeHead:
	 //moves the snake pointer to the head of the snake and the compares it's coordinates the apples coordinate if
	 //they are the same the variable isGrowing is set to 1 and a new apple is spawned before returning to the main loop.
	 //If the coordinates doesent the códe returns to the main loop without changing any values
	 subi rCount,-1
	 subi YL,-1
	 cp rCount,rTemp2
	 brne findSnakeHead
	 ld rTemp2,Y
	 cp rTemp2,rTemp
	 brne return2
	 ldi rTemp4,0b00000001
	 sts isGrowing,rTemp4
	 rcall spawnApple

	 return2:
	 rcall resetSnakePoint
	 ret

	 snakeCollision:
	 //works in a similar manner as the appleCollision except for that it compares the heads coordinates to the rest of the body
	 lds rTemp, snakeLengthIndex
	 ldi rCount,0

	 findSnakeHeadCollision:
	 subi rCount,-1
	 subi YL,-1
	 cp rCount,rTemp
	 brne findSnakeHeadCollision
	 ld rTemp,Y
	 rcall resetSnakePoint

	 ldi rCount,0
	 lds rTemp2,snakeLengthIndex

	 compareSnakeheadToBody:
	 ld rTemp3,Y+
	 subi rCount,-1
	 cp rTemp,rTemp3
	 breq GAMEOVER
	 cp rCount,rTemp2
	 brne compareSnakeheadToBody
	 rcall resetSnakePoint
	 ret

	 GAMEOVER:
	 //If the snake has collided with itself teh GAMEOVER loop is called filling all the matrix position with 1 to make the entire screen light up
	 rcall fillMatrix
	 rcall outputMatrix
	 jmp GAMEOVER


