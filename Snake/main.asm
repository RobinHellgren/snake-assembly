//[En lista med registerdefinitioner]
.DEF rTemp         = r16
.DEF rDirection    = r23
.DEF rZero         = r17
.DEF rMatIndex	   = r18
.DEF rBOut         = r19
.DEF rDOut         = r20
.DEF rCOut         = r21

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
.ORG INT_VECTORS_SIZE
init:
     // Sätt stackpekaren till högsta minnesadressen
     ldi rTemp, HIGH(RAMEND)
     out SPH, rTemp
     ldi rTemp, LOW(RAMEND)
     out SPL, rTemp
	 ldi rTemp, 0b00001111
	 
	 out DDRC, rTemp
	 ldi rTemp, 0b11111111
	 out DDRD, rTemp
	 out DDRB, rTemp
	 ldi rZero, 0
	 
	 ldi XH, HIGH(matrix)
	 ldi XL, LOW(matrix)
	 ldi rMatIndex, 0
	 
	 ldi rTemp, 0b10101010
	 st X, rTemp
	 subi XL, -1
	 ldi rTemp, 0b01010101
	 st X, rTemp
	 subi XL, 1
	 loop:

	 rcall outputRow
	
	 jmp loop

	 wait:
	 nop
	 nop
	 nop
	 nop
	 nop
	 nop
	 nop
	 nop
	 nop
	 nop
	 nop
	 ret
	 
	 dim:
	 out PortC, rZero
	 out PortD, rZero
	 out PortB, rZero
	 ret

	 resetMatPoint:
	 ldi XH, HIGH(matrix)
	 ldi XL, LOW(matrix)
	 ret

	 outputRow:
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

	 //subi X, -1
	 //subi rMatIndex, -1

	 out PortD, rDOut
	 out PortB, rBOut
	 out PortC, rCOut

	 rcall wait
	 rcall dim

	 ld rTemp, X
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

	 //subi X, -1
	 //subi rMatIndex, -1

	 out PortD, rDOut
	 out PortB, rBOut
	 out PortC, rCOut
	 rcall resetMatPoint
	 ret


