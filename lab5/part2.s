/******************************************************************************
 * Write an interrupt service routine
 *****************************************************************************/
.section .exceptions, "ax"

# the only register we don't restore (and thus "clobber") is r16, since it is our global flag
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
        # also save r4, r5, r17, r18
        subi sp, sp, 16
        stw r4, 0(sp)
        stw r5, 4(sp)
        stw r17, 8(sp)
        stw r18, 12(sp)

        andi    r20, et, 0x2        # check if interrupt is from pushbuttons
        beq     r20, r0, END_ISR    # if not, ignore this interrupt
        call    KEY_ISR             # if yes, call the pushbutton ISR

END_ISR:
        ldw r4, 0(sp)
        ldw r5, 4(sp)
        ldw r17, 8(sp)
        ldw r18, 12(sp)
        addi sp, sp, 16
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

    .equ KEY_BASE, 0xff200050
    .equ HEX_BASE1, 0xff200020
    .equ HEX_BASE2, 0xff200030

_start:
    /*
    1. Initialize the stack pointer
    2. set up keys to generate interrupts
    3. enable interrupts in NIOS II
    */
    movia sp, 0x20000
    movi r16, 0b0000    # stores whether each of the 4 displays are on or blank 

    movi r4, 0b1111
    movia r5, KEY_BASE
    stwio r4, 12(r5) # clear edge capture bits
    stwio r4, 8(r5) # enable interrupts for every key
    movi r4, 0b10
    wrctl ctl3, r4  # enable KEYs IRQ
    movi r4, 0b1
    wrctl ctl0, r4  # enable PIE bit
IDLE:   br  IDLE

# may change r4, r5 (not accounting for further registers that may change from subroutine calls)
KEY_ISR:
    subi sp, sp, 4
    stw ra, 0(sp)

    movi r4, 0b1
    movi r5, 0
    call HANDLE_KEYPRESS
    movi r4, 0b10
    movi r5, 1
    call HANDLE_KEYPRESS
    movi r4, 0b100
    movi r5, 2
    call HANDLE_KEYPRESS
    movi r4, 0b1000
    movi r5, 3
    call HANDLE_KEYPRESS

    ldw ra, 0(sp)
    addi sp, sp, 4
    ret

# may change r4, r17, r18
# may change r16, but that's a global
HANDLE_KEYPRESS:
    # r4 is bitmask storing which key we're trying to check
    # r5 is the actual number of the key we're checking (e.g., 0-3)
    movia r17, KEY_BASE
    ldwio r18, 12(r17)
    and r18, r18, r4
    bne r18, r0, PRESSED
    ret
PRESSED:
    stwio r4, 12(r17)    # clear the edge capture bit
    xor r16, r16, r4    # toggle the on/off bit
    and r17, r16, r4
    beq r17, r0, TURN_OFF
    mov r4, r5

    subi sp, sp, 4
    stw ra, (sp)
    call HEX_DISP
    ldw ra, (sp)
    addi sp, sp, 4
    ret
TURN_OFF:
    movi r4, 0b10000

    subi sp, sp, 4
    stw ra, (sp)
    call HEX_DISP
    ldw ra, (sp)
    addi sp, sp, 4
    ret

# uses r8, r6, r7
# uses r4, r2, r5
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
			




