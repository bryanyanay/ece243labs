.global _start
	.equ KEY_BASE, 0xff200050	# initialize key mem mapped addr
	.equ HEX_BASE1, 0xff200020
	.equ HEX_BASE2, 0xff200030
_start:
	movia r13, KEY_BASE	# r13 <- KEY_BASE
	movi r12, 15	# set parameter for resetting edgecap
	movi r9, 16
increment:
	mov r4, r9
	movi r5, 0
	call HEX_DISP
	call edgecap
	movi r10, 8
	bne r2, r10, increase
	movi r9, 16
	br increment
increase:
	movi r10, 16
	beq r9, r10, reset
	addi r9, r9, 1
	br increment
reset:
	mov r9, r0
	br increment

edgecap: ldwio r14, 0xC(r13)	# load edgecap value
	beq r14, r0, edgecap	# if r14 stays 0, keep looping
	mov r2, r14	# set r2 to 1, (start signal)
	stwio r12, 0xC(r13)		# else reset edgecap back to 0,
ret	# continue the counter

HEX_DISP:   movia    r8, BIT_CODES         # starting address of the bit codes
	    andi     r6, r4, 0x10	   # get bit 4 of the input into r6
	    beq      r6, r0, not_blank 
	    mov      r2, r0
	    br       DO_DISP
not_blank:  andi     r4, r4, 0x0f	   # r4 is only 4-bit
            add      r4, r4, r8            # add the offset to the bit codes
            ldb      r2, 0(r4)             # index into the bit codes

#Display it on the target HEX display
DO_DISP:    
			movia    r8, HEX_BASE1         # load address
			movi     r6,  4
			blt      r5,r6, FIRST_SET      # hex4 and hex 5 are on 0xff200030
			sub      r5, r5, r6            # if hex4 or hex5, we need to adjust the shift
			addi     r8, r8, 0x0010        # we also need to adjust the address
FIRST_SET:
			slli     r5, r5, 3             # hex*8 shift is needed
			addi     r7, r0, 0xff          # create bit mask so other values are not corrupted
			sll      r7, r7, r5 
			addi     r4, r0, -1
			xor      r7, r7, r4  
    			sll      r4, r2, r5            # shift the hex code we want to write
			ldwio    r5, 0(r8)             # read current value       
			and      r5, r5, r7            # and it with the mask to clear the target hex
			or       r5, r5, r4	           # or with the hex code
			stwio    r5, 0(r8)		       # store back
END:			
			ret
			
BIT_CODES:  .byte     0b00111111, 0b00000110, 0b01011011, 0b01001111
			.byte     0b01100110, 0b01101101, 0b01111101, 0b00000111
			.byte     0b01111111, 0b01100111, 0b01110111, 0b01111100
			.byte     0b00111001, 0b01011110, 0b01111001, 0b01110001

            .end
			
	