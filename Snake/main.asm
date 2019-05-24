//[En lista med registerdefinitioner]
.DEF rTemp         = r16
.DEF rDirection    = r23
.DEF rZero         = r17
.DEF rTemp2         = r19
.DEF rTemp4         = r20
.DEF rTemp3         = r21
.DEF rInter		   = r22
.DEF rTempBit      = r18
.DEF rADMUXx	   = r24
.DEF rADMUXy	   = r14
.DEF rStickInp	   = r15

//[En lista med konstanter]
.EQU NUM_COLUMNS   = 8
.EQU MAX_LENGTH    = 25
//[Datasegmentet]
.DSEG
matrix:   .BYTE 8
snake:    .BYTE MAX_LENGTH+1
Bout:	  .BYTE 1
Cout:      .BYTE 1
Dout:	  .BYTE 1

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
	 ldi rTemp, 0b00000011
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
	 ldi rDirection, 0
	 //tilldela minne till matrixen
	 ldi XH, HIGH(matrix)
	 ldi XL, LOW(matrix)
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
	 //main progam loop
	 loop:
	 rcall stickXInput
	 rcall stickYInput
	 sts matrix, rDirection
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
	 ldi rTemp2, 1
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
	 ldi rTemp2, 2
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
	 ldi rTemp2, 4
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

	 stickXInput:
	 sts ADMUX, rADMUXx
	 ldi rTemp, 0b11000111
	 sts ADCSRA, rTemp

	 stickXLoop:
	 lds rTemp, ADCSRA
	 sbrc rTemp, ADSC
	 jmp stickXLoop
	 lds rTemp, ADCL
	 lds rStickInp, ADCH
	 ldi rTemp, 200
	 cp rStickInp, rTemp
	 brsh XPos
	 ldi rTemp, 50
	 cp rStickInp, rTemp
	 brlo XNeg 
	 ret
	 XPos:
	 ldi rTempBit, 0b00000010
	 or rDirection, rTempBit
	 ret
	 XNeg:
	 ldi rTempBit, 0b11111101
	 and rDirection, rTempBit
	 ret

	 
	 stickYInput:
	 sts ADMUX, rADMUXy
	 ldi rTemp, 0b11000111
	 sts ADCSRA, rTemp

	 stickYLoop:
	 lds rTemp, ADCSRA
	 sbrc rTemp, ADSC
	 jmp stickYLoop
	 lds rTemp, ADCL
	 lds rStickInp, ADCH
	 
	 ldi rTemp, 200
	 cp rStickInp, rTemp
	 brsh YPos
	 ldi rTemp, 50
	 cp rStickInp, rTemp
	 brlo YNeg
	  
	 ret
	 YPos:
	 ldi rTempBit, 0b00000001
	 or rDirection, rTempBit
	 ret
	 YNeg:
	 ldi rTempBit, 0b11111110
	 and rDirection, rTempBit
	 ret
