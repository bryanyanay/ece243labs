.global _start
	.equ KEY_BASE, 0xff200050	# initialize key mem mapped addr
	.equ LEDs, 0xff200000	# initialize LED mem mapped addr
	.equ COUNTER, 0xff202000	# initialize the hardware counter
	.equ COUNTER_DELAY, 25000000
_start:	movia r13, KEY_BASE	# r8 <- KEY_BASE
		movia r9, LEDs	# r9 <- LEDs
		movia r8, COUNTER	# delay loop
		movia r15, COUNTER_DELAY	# store counter delay here
		srli r19, r15, 16	# r19 gets the higher bits of the delay
		andi r15, r15, 0xffff	# r15 gets the lower bits
		movi r10, 255	# set parameter for max counter value
		movi r11, 0	# initialize for counter value
		movi r4, 0	# initialize input value, (stop at the beginning)
		movi r12, 15	# set parameter for resetting edgecap
		movi r16, 4	# initialize the start value of the timer
		movi r18, 1	# needed for polling for TO
		
counter:
	stwio r11, (r9)	# r11 <- LEDs value
	call edgecap	# detect edge cap and start/stop control
	mov r4, r2	# update start/stop
	DO_DELAY: stwio r19, 0xC(r8)	# store the higher bits
				stwio r15, 0x8(r8)	# store the lower bits
				stwio r16, 0x4(r8)	# set the START value in the control register to 1
		SUB_LOOP:	ldwio r17, (r8)	
		bne r17, r18, SUB_LOOP	# polling for TO to become 1
	stwio r0, (r8)	# reset back to 0
	addi r11, r11, 1	# increment counter value
	ble r11, r10, counter	# if r11 is less than 255, keep looping
	movi r11, 0	# reset counter value to 0
	movi r4, 1	# reset r4 to 0 so counter keeps going when gettiing back to 0
	br counter	# infinite loop
	

		
edgecap: ldwio r14, 0xC(r13)	# load edgecap value
		beq r4, r0, stop	# if r4 is 0, goes to stop
start: bgt r14, r0, transition	# else if r14 is greater than 0, (key pressed)
ret	# else continue the counter
transition:
	stwio r12, 0xC(r13)	# reset it back to 0, so it can detect the next time to resume
stop: ldwio r14, 0xC(r13)	# load edgecap value
	beq r14, r0, stop	# if r14 stays 0, keep looping
	stwio r12, 0xC(r13)		# else reset edgecap back to 0,
	movi r2, 1	# set r2 to 1, (start signal)
ret	# continue the counter
	
	