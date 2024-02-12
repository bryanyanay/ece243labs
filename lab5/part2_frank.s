/******************************************************************************
 * Write an interrupt service routine
 *****************************************************************************/
.section .exceptions, "ax"
IRQ_HANDLER:
        # save registers on the stack (et, ra, ea, others as needed)
        subi    sp, sp, 16          # make room on the stack
        stw     et, 0(sp)
        stw     ra, 4(sp)
        stw     r20, 8(sp)

        rdctl   et, ctl4            # read exception type
        beq     et, r0, SKIP_EA_DEC # not external?
        subi    ea, ea, 4           # decrement ea by 4 for external interrupts

SKIP_EA_DEC:
	
        stw     ea, 12(sp)
		
		
    subi sp, sp,20      # Make room for saving registers
	stw r2, 16(sp)
    stw r13, 12(sp)      # Save r13
    stw r4, 8(sp)       # Save r4
    stw r5, 4(sp)       # Save r5
	stw r14, 0(sp)
	
	
        andi    r20, et, 0x2        # check if interrupt is from pushbuttons
        beq     r20, r0, END_ISR    # if not, ignore this interrupt
        call    KEY_ISR             # if yes, call the pushbutton ISR


END_ISR:
	ldw r14, 0(sp)
    ldw r5, 4(sp)       # Restore r4
    ldw r4, 8(sp)      # Restore r13
    ldw r13, 12(sp)       # Restore ra
	ldw r2, 16(sp)
    addi sp, sp, 20     # Reset stack pointer

        ldw     et, 0(sp)           # restore registers
        ldw     ra, 4(sp)
        ldw     r20, 8(sp)
        ldw     ea, 12(sp)
        addi    sp, sp, 16          # restore stack pointer
        eret                        # return from exception

/*********************************************************************************
 * set where to go upon reset
 ********************************************************************************/
.section .reset, "ax"
        movia   r8, _start
        jmp    r8

/*********************************************************************************
 * Main program
 ********************************************************************************/
.text
.global  _start
.equ     KEYs, 0xff200050          # Base address for KEYs
	.equ HEX_BASE1, 0xff200020
	.equ HEX_BASE2, 0xff200030
_start:
        /* Initialize stack pointer, setup for interrupts, etc. */
        movia   sp, 0x20000      # Assume stack pointer initialization
		movia r11, KEYs
		movi r9, 15
		movi r12, 0
		stwio r9, 0xC(r11)
		stwio r9, 8(r11)
		movi r10, 0x2
		wrctl ctl3, r10
		movi r10, 1
		wrctl ctl0, r9

IDLE:
        br      IDLE                # Idle loop

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

KEY_ISR: 
    subi sp, sp, 8     # Make room for saving registers
	stw r7, 4(sp)
    stw ra, (sp)      # Save return address
	
	movi r5, 0
	movi r4, 1
	movi r14, 4
checkKey:	
    ldwio r13, 0xC(r11)    # Load the KEYs state into r13
	and r13, r13, r4
	slli r4, r4, 1
	addi r5, r5, 1
	bgt r13, r0, keyPressed
	bne r5, r14, checkKey
	
keyPressed:
	subi r5, r5, 1
	srli r4, r4, 1
	xor r12, r12, r4
	and r14, r12, r4
	mov r4, r5
	bne r14, r0, TURNON
	movi r4, 16
TURNON:	
	call HEX_DISP
	stwio r9, 0xC(r11)
	ldw ra, (sp)
	ldw r7, 4(sp)
    addi sp, sp, 8     # Reset stack pointer
    ret                 # Return from ISR
		
BIT_CODES:  .byte     0b00111111, 0b00000110, 0b01011011, 0b01001111
			.byte     0b01100110, 0b01101101, 0b01111101, 0b00000111
			.byte     0b01111111, 0b01100111, 0b01110111, 0b01111100
			.byte     0b00111001, 0b01011110, 0b01111001, 0b01110001

            .end
