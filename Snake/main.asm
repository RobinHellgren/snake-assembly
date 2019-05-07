//[En lista med registerdefinitioner]
.DEF rTemp         = r16
.DEF rDirection    = r23
.DEF rZero         = r17
.DEF rMatIndex	   = r18
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
	 
	 ldi rInter, 0b00000000
	 
	 ldi rTemp, 0b00000011
	 out TCCR0B, rTemp
	 ldi rTemp, 0b001
	 sts TIMSK0, rTemp
	 sei

	 ldi rTemp, 0b00001111
	 out DDRC, rTemp
	 ldi rTemp, 0b11111111
	 out DDRD, rTemp
	 out DDRB, rTemp
	 ldi rZero, 0
	 
	 ldi XH, HIGH(matrix)
	 ldi XL, LOW(matrix)
	 ldi rMatIndex, 0
	 
	 //1
	 ldi rTemp, 0b11000011
	 st X, rTemp
	 adiw X,1
	 //2
	 ldi rTemp, 0b10111101
	 st X, rTemp
	 adiw X,1
	 //3
	 ldi rTemp, 0b01011010
	 st X, rTemp
	 adiw X,1
	 //4 
	 ldi rTemp, 0b01111110
	 st X, rTemp
	 adiw X,1
	 //5
	 ldi rTemp, 0b01011010
	 st X, rTemp
	 adiw X,1
	 //6
	 ldi rTemp, 0b01100110
	 st X, rTemp
	 adiw X,1
	 //7
	 ldi rTemp, 0b10111101
	 st X, rTemp
	 adiw X,1
	 //8
	 ldi rTemp, 0b11000011
	 st X, rTemp
	 rcall resetMatPoint
	 loop:

	 rcall outputRow
	
	 jmp loop

	 wait:
	 cpi rInter, 0
	 breq wait
	 nop
	 ret
	 
	 dim:
	 out PortC, rZero
	 out PortD, rZero
	 out PortB, rZero
	 nop
	 nop
	 nop
	 nop
	 ret

	 resetMatPoint:
	 ldi XH, HIGH(matrix)
	 ldi XL, LOW(matrix)
	 ret

	 outputRow:
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
	 ldi rDOut, 0b00000001
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
	 
	 //7
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
	 
	 //8	 
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

	 rcall resetMatPoint
	 ret

	 interup:
	 ldi rInter, 0b00000001
	 reti
