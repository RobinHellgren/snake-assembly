//[En lista med registerdefinitioner]
.DEF rTemp         = r16
.DEF rDirection    = r23
.DEF rZero         = r17
.DEF rStickX	   = r18
.DEF rStickY	   = r24
.DEF rBOut         = r19
.DEF rDOut         = r20
.DEF rCOut         = r21
.DEF rInter		   = r22


//[En lista med konstanter]
.EQU NUM_COLUMNS   = 8
.EQU MAX_LENGTH    = 25
//[Datasegmentet]
.DSEG
matrix:   .BYTE 8
snake:    .BYTE MAX_LENGTH+1

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
     // S�tt stackpekaren till h�gsta minnesadressen
     ldi rTemp, HIGH(RAMEND)
     out SPH, rTemp
     ldi rTemp, LOW(RAMEND)
     out SPL, rTemp
	 //s�tt interupt biten till 0
	 ldi rInter, 0b00000000
	 //configuration till timer enheten
	 ldi rTemp, 0b00000011
	 out TCCR0B, rTemp
	 ldi rTemp, 0b001
	 sts TIMSK0, rTemp
	 sei
	 //configuration till AD convertern
	 ldi rTemp, 0b0011000
	 sts ADMUX, rTemp

	 ldi rTemp, 0b01000111
	 sts ADCSRA, rTemp

	 //configuration till led enheten
	 ldi rTemp, 0b00001111
	 out DDRC, rTemp
	 ldi rTemp, 0b11111111
	 out DDRD, rTemp
	 out DDRB, rTemp
	 ldi rZero, 0
	 //tilldela minne till matrixen
	 ldi XH, HIGH(matrix)
	 ldi XL, LOW(matrix)
	 

	 //main progam loop
	 loop:
	 rcall stickXInput
	 rcall stickYInput
	 st X, rDirection
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
	 //rest the matrix pointer
	 resetMatPoint:
	 ldi XH, HIGH(matrix)
	 ldi XL, LOW(matrix)
	 ret
	 
	 //output the matrix to the led display
	 outputMatrix:
	 //1
	 ld rTemp, X+
	 ldi rBOut, 0
	 ldi rDOut, 0
	 ldi rCOut, 1
	 
	 bst rTemp, 7
	 bld rDOut, 6

	 bst rTemp, 6
	 bld rDOut, 7

	 bst rTemp, 5
	 bld rBOut, 0

	 bst rTemp, 4
	 bld rBOut, 1

	 bst rTemp, 3
	 bld rBOut, 2

	 bst rTemp, 2
	 bld rBOut, 3

	 bst rTemp, 1
	 bld rBOut, 4

	 bst rTemp, 0
	 bld rBOut, 5

	 
	 //subi rMatIndex, -1

	 out PortD, rDOut
	 out PortB, rBOut
	 out PortC, rCOut
	 
	 rcall wait 
	 rcall dim
	 
	 ldi rInter, 0

	 //2
	 ld rTemp, X+
	 ldi rBOut, 0
	 ldi rDOut, 0
	 ldi rCOut, 2
	 
	 bst rTemp, 7
	 bld rDOut, 6

	 bst rTemp, 6
	 bld rDOut, 7

	 bst rTemp, 5
	 bld rBOut, 0

	 bst rTemp, 4
	 bld rBOut, 1

	 bst rTemp, 3
	 bld rBOut, 2

	 bst rTemp, 2
	 bld rBOut, 3

	 bst rTemp, 1
	 bld rBOut, 4

	 bst rTemp, 0
	 bld rBOut, 5

	 
	 //subi rMatIndex, -1

	 out PortD, rDOut
	 out PortB, rBOut
	 out PortC, rCOut
	 
	 rcall wait 
	 rcall dim
	 
	 ldi rInter, 0	 
	 
	 //3
	 ld rTemp, X+
	 ldi rBOut, 0
	 ldi rDOut, 0
	 ldi rCOut, 4
	 
	 bst rTemp, 7
	 bld rDOut, 6

	 bst rTemp, 6
	 bld rDOut, 7

	 bst rTemp, 5
	 bld rBOut, 0

	 bst rTemp, 4
	 bld rBOut, 1

	 bst rTemp, 3
	 bld rBOut, 2

	 bst rTemp, 2
	 bld rBOut, 3

	 bst rTemp, 1
	 bld rBOut, 4

	 bst rTemp, 0
	 bld rBOut, 5

	 
	 //subi rMatIndex, -1

	 out PortD, rDOut
	 out PortB, rBOut
	 out PortC, rCOut
	 
	 rcall wait 
	 rcall dim
	 
	 ldi rInter, 0	 
	 
	 //4
	 ld rTemp, X+
	 ldi rBOut, 0
	 ldi rDOut, 0
	 ldi rCOut, 8
	 
	 bst rTemp, 7
	 bld rDOut, 6

	 bst rTemp, 6
	 bld rDOut, 7

	 bst rTemp, 5
	 bld rBOut, 0

	 bst rTemp, 4
	 bld rBOut, 1

	 bst rTemp, 3
	 bld rBOut, 2

	 bst rTemp, 2
	 bld rBOut, 3

	 bst rTemp, 1
	 bld rBOut, 4

	 bst rTemp, 0
	 bld rBOut, 5

	 
	 //subi rMatIndex, -1

	 out PortD, rDOut
	 out PortB, rBOut
	 out PortC, rCOut
	 
	 rcall wait 
	 rcall dim
	 
	 ldi rInter, 0	 
	 
	 //5
	 ld rTemp, X+
	 ldi rBOut, 0
	 ldi rDOut, 0b00000100
	 ldi rCOut, 0
	 
	 bst rTemp, 7
	 bld rDOut, 6

	 bst rTemp, 6
	 bld rDOut, 7

	 bst rTemp, 5
	 bld rBOut, 0

	 bst rTemp, 4
	 bld rBOut, 1

	 bst rTemp, 3
	 bld rBOut, 2

	 bst rTemp, 2
	 bld rBOut, 3

	 bst rTemp, 1
	 bld rBOut, 4

	 bst rTemp, 0
	 bld rBOut, 5

	 
	 //subi rMatIndex, -1

	 out PortD, rDOut
	 out PortB, rBOut
	 out PortC, rCOut
	 
	 rcall wait 
	 rcall dim
	 
	 ldi rInter, 0	 
	 
	 //6
	 ld rTemp, X+
	 ldi rBOut, 0
	 ldi rDOut, 0b00001000
	 ldi rCOut, 0
	 
	 bst rTemp, 7
	 bld rDOut, 6

	 bst rTemp, 6
	 bld rDOut, 7

	 bst rTemp, 5
	 bld rBOut, 0

	 bst rTemp, 4
	 bld rBOut, 1

	 bst rTemp, 3
	 bld rBOut, 2

	 bst rTemp, 2
	 bld rBOut, 3

	 bst rTemp, 1
	 bld rBOut, 4

	 bst rTemp, 0
	 bld rBOut, 5

	 
	 //subi rMatIndex, -1

	 out PortD, rDOut
	 out PortB, rBOut
	 out PortC, rCOut
	 
	 rcall wait 
	 rcall dim
	 
	 ldi rInter, 0	 
	 
	 //7
	 ld rTemp, X+
	 ldi rBOut, 0
	 ldi rDOut, 0b00010000
	 ldi rCOut, 0
	 
	 bst rTemp, 7
	 bld rDOut, 6

	 bst rTemp, 6
	 bld rDOut, 7

	 bst rTemp, 5
	 bld rBOut, 0

	 bst rTemp, 4
	 bld rBOut, 1

	 bst rTemp, 3
	 bld rBOut, 2

	 bst rTemp, 2
	 bld rBOut, 3

	 bst rTemp, 1
	 bld rBOut, 4

	 bst rTemp, 0
	 bld rBOut, 5

	 
	 //subi rMatIndex, -1

	 out PortD, rDOut
	 out PortB, rBOut
	 out PortC, rCOut
	 
	 rcall wait 
	 rcall dim
	 
	 ldi rInter, 0
	 
	 //8	 
	 ld rTemp, X
	 ldi rBOut, 0
	 ldi rDOut, 0b00100000
	 ldi rCOut, 0
	 
	 bst rTemp, 7
	 bld rDOut, 6

	 bst rTemp, 6
	 bld rDOut, 7

	 bst rTemp, 5
	 bld rBOut, 0

	 bst rTemp, 4
	 bld rBOut, 1

	 bst rTemp, 3
	 bld rBOut, 2

	 bst rTemp, 2
	 bld rBOut, 3

	 bst rTemp, 1
	 bld rBOut, 4

	 bst rTemp, 0
	 bld rBOut, 5

	 
	 //subi rMatIndex, -1

	 out PortD, rDOut
	 out PortB, rBOut
	 out PortC, rCOut
	 
	 rcall wait 
	 rcall dim
	 
	 ldi rInter, 0

	 rcall resetMatPoint
	 ret
	 //interup subrutinen
	 interup:
	 ldi rInter, 0b00000001
	 reti

	 stickXInput:
	 push rTemp
	 
	 ldi rTemp, 0b0
	 bld rTemp,0
	 push rTemp
	 bst rTemp, 0
	 bst rTemp, 1
	 bst rTemp, 2
	 bst rTemp, 3
	 sts ADMUX, rTemp
	 pop rTemp

	 ldi rTemp, 0b1
	 bld rTemp, 0
	 
	 push rTemp
	 lds rTemp, ADMUX
	 bst rTemp, 2
	 bst rTemp, 5
	 sts ADMUX, rTemp
	 pop rTemp
	 jmp stickXLoop

	 stickXLoopPop:
	 pop rTemp
	 stickXLoop:
	 lds rTemp, ADCL
	 push rTemp
	 lds rTemp, ADMUX
	 sbrc rTemp, 5
	 jmp stickXLoopPop

	 pop rTemp

	 cpi rTemp, 200
	 brsh XPos
	 cpi rTemp, 50
	 brlo XNeg 

	 XPos:
	 ldi rTemp, 0b1
	 bld rTemp, 0
	 bst rDirection, 1
	 ret
	 XNeg:
	 ldi rTemp, 0b0
	 bld rTemp, 0
	 bst rDirection, 1
	 ret

	 
	 stickYInput:
	 push rTemp

	 ldi rTemp, 0b0
	 bld rTemp,0
	 push rTemp
	 bst rTemp, 0
	 bst rTemp, 1
	 bst rTemp, 2
	 bst rTemp, 3
	 sts ADMUX, rTemp
	 pop rTemp

	 ldi rTemp, 0b1
	 bld rTemp, 0
	 
	 push rTemp
	 lds rTemp, ADMUX
	 bst rTemp, 3
	 bst rTemp, 5
	 sts ADMUX, rTemp
	 pop rTemp
	 jmp stickYLoop

	 stickYLoopPop:
	 pop rTemp
	 stickYLoop:
	 lds rTemp, ADCL
	 push rTemp
	 lds rTemp, ADMUX
	 sbrc rTemp, 5
	 jmp stickYLoopPop

	 pop rTemp
	 cpi rTemp, 200
	 brsh YPos
	 cpi rTemp, 50
	 brlo YNeg 

	 YPos:
	 ldi rTemp, 0b1
	 bld rTemp, 0
	 bst rDirection, 0
	 ret
	 YNeg:
	 ldi rTemp, 0b0
	 bld rTemp, 0
	 bst rDirection, 0
	 ret