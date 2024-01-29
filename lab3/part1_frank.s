/* Program to Count the number of 1's in a 32-bit word,
located at InputWord */

.global _start
_start:

	/* Put your code here */
	movia r8, Answer	# r8 <- answer
	movia r10, InputWord	# r10 <- InputWord
	ldw r11, (r10)	# load first word to r11
	movi r9, 32		# set parameter of the loop
	movi r13, 0	# initialize r13
	
loop: andi r12, r11, 0x0001	# check for the least sig fig 
	add r13, r13, r12	# add to r13
	srli r11, r11, 1# shift r11 1 bit to the right
	subi r9, r9, 1	# r9--
	bgt r9, r0, loop	# if r9 > 0, keep looping

stw r13, (r8)	# store result to location in r8
endiloop: br endiloop

InputWord: .word 0x4a01fead

Answer: .word 0
	
	