/* Program to Count the number of 1's in a 32-bit word,
located at InputWord */

.global _start
_start:

	/* Put your code here */
	movia r8, Answer	# r8 <- answer
	movia r10, InputWord	# r10 <- InputWord
	ldw r4, (r10)	# load first word to r4 as parameter
	call ONES	# call function
	stw r2, (r8)	# store output into location in r8

endiloop: br endiloop

ONES: 
	movi r9, 32	# set parameter of the loop
	movi r2, 0	# initialize r2
	loop: andi r12, r4, 0x0001	# check for the least sig fig 
		add r2, r2, r12	# add to r2
		srli r4, r4, 1	# shift r4 1 bit to the right
		subi r9, r9, 1	# r9--
		bgt r9, r0, loop	# if r9 > 0, keep looping
	ret

InputWord: .word 0x4a01fead

Answer: .word 0
	
	