.global _start

	.equ KEY_BASE, 0xff200050	# initialize key mem mapped addr
	.equ LEDs, 0xff200000	# initialize LED mem mapped addr
_start:	movia r8, KEY_BASE	# r8 <- KEY_BASE
		movia r9, LEDs	# r9 <- LEDs
		movi r11, 1	# parameter for key0 value
		movi r12, 2	# parameter for key1 value
		movi r13, 4	# parameter for key2 value
		movi r14, 15	# parameter for max LED value

loop:
	call polling 	# subroutine for getting key pressed
	call waiting	# subroutine for getting key released
key0:
	bne r2, r11, key1	# if key0 pressed
	stwio r11, (r9)	# set LEDs to 1
	br loop
key1:
	bne r2, r12, key2	# if key1 pressed
	ldwio r10, (r9)	# get current LEDs value
	beq r10, r14, loop	# if LEDs are already 15, back to looping
	addi r10, r10, 1	# else increment
	stwio r10, (r9)	# store value
	br loop	
key2:
	bne r2, r13, key3	# if key2 pressed
	ldwio r10, (r9)	# get current LEDs value
	beq r10, r11, loop	# if LEDs are already 1, back to looping
	beq r10, r0, increment	# if it was just resetted, increment
	subi r10, r10, 1	# decrement
	stwio r10, (r9)	# store value
	br loop	
increment: 
	stwio r11, (r9)	# set to 1 (same as increment)
	br loop
key3:
	stwio r0, (r9)	# assuming key3 has to be pressed if all others were not pressed
	br loop
	
polling:
	getPress: ldwio r2, 0(r8)
			beq r2, r0, getPress	# keep looping until a key is pressed
	ret
	
	
waiting: 
	getRelease: ldwio r3, 0(r8)
			bne r3, r0, getRelease	# keep looping until a key is released
	ret