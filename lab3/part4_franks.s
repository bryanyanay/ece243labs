.text
/* Program to Count the number of 1's and Zeroes in a sequence of 32-bit words,
and determines the largest of each */

.global _start
_start:

	/* Your code here  */
	movia r8, LargestOnes	# r8 <- LargestOnes
	movia r9, LargestZeroes	# r9 <- LargestZeroes
	movia r10, TEST_NUM		# r10 <- TEST_NUM
	movia sp, 0x20000		# initialize stack
	movia r15, 0xffffffff	# used for reversing bits with xor
	subi sp, sp, 4			# clearing the stack
	stw r0, (sp)
	subi sp, sp, 4
	stw r0, (sp)
	addi sp, sp, 8
	
mainloop: 
	ldw r11, (r10)			# deref word in r10 into r11
	beq r11, r0, finished	# if reaching the 0, goes to finish
	mov r4, r11				# set parameter
	call ONES				# call function
	subi sp, sp, 4			# goes to 4 bye before, to save data in stack
	ldw r12, (sp)			# load stack value into r12, (first time is 0)
	bge r2, r12, switchOne	# if current value is the largest, go to switch logic
continue:
	xor r4, r4, r15			# flip the value in r4
	call ONES				# call function
	subi sp, sp, 4			# another 4 bytes before, for another slot in stack
	ldw r13, (sp)			# load value into r13, first time is 0
	bge r2, r13, switchZero	# if current is largest, switch
continue2:
	addi sp, sp, 8			# restore sp back to 0x20000
	addi r10, r10, 4		# proceed to the next word in TEST_NUM
	br mainloop				# keep looping
switchOne:
	stw r2, (sp)			# store r2 in stack
	br continue				# return to continue
switchZero:
	stw r2, (sp)			# store r2 in stack	
	br continue2			# return to continue 2
	

	
finished: 
	subi sp, sp, 4			# retrieve largestOne and largestZero and save to memory at r8 and r9
	ldw r16, (sp)
	stw r16, (r8)
	subi sp, sp, 4
	ldw r17, (sp)
	stw r17, (r9)
	
  .equ LEDs, 0xFF200000
  movia r20, LEDs

maindisplay:
  stwio r16, (r20)     # display largestOnes
  call DELAYLOOP
  stwio r17, (r20)  	# desplay largestZeroes
  call DELAYLOOP
  br maindisplay

ONES: 
	movi r18, 32	# set parameter of the loop
	movi r2, 0	# initialize r2
	mov r5, r4	# pass r4 to r5 so original value stays intact
	movi r14, 0	# initialize r14
	loop: andi r14, r5, 0x0001	# check for the least sig fig 
		add r2, r2, r14	# add to r2
		srli r5, r5, 1	# shift r5 1 bit to the right
		subi r18, r18, 1	# r18--
		bgt r18, r0, loop	# if r18 > 0, keep looping
	ret

DELAYLOOP:
	movia r21, 0x01000000	# this looping 
dloop:
  subi r21, r21, 1
  bne r21, r0, dloop
  ret

.data
TEST_NUM:  .word 0x4a01fead, 0xF677D671,0xDC9758D5,0xEBBD45D2,0x8059519D
            .word 0x76D8F0D2, 0xB98C9BB5, 0xD7EC3A9E, 0xD9BADC01, 0x89B377CD
            .word 0  # end of list 

LargestOnes: .word 0
LargestZeroes: .word 0