.section .exceptions, "ax"
IRQ_HANDLER:
    /* Save context */
    subi    sp, sp, 32         /* Make room for 8 registers */
    stw     ra, 28(sp)
    stw     r4, 24(sp)
    stw     r5, 20(sp)
    stw     r6, 16(sp)
	
	rdctl   et, ctl4            # read exception type
	beq     et, r0, SKIP_EA_DEC # not external?
	subi    ea, ea, 4           # decrement ea by 4 for external interrupts
SKIP_EA_DEC:
	stw ea, 12(sp)
    /* Identify the source of the interrupt */
	

	andi    r4, et, 0x2        # check if interrupt is from pushbuttons
	beq     r4, r0, SKIP_KEY_INT    # if not, ignore this interrupt
	call    KEY_ISR             # if yes, call the pushbutton ISR
SKIP_KEY_INT:
	andi 	r5, et, 0x1
	beq		r5, r0, SKIP_TIME_INT
	call	TIMER_ISR

SKIP_TIME_INT:
    /* Restore context */
	
	ldw		ea, 12(sp)
    ldw     r6, 16(sp)
    ldw     r5, 20(sp)
    ldw     r4, 24(sp)
    ldw     ra, 28(sp)
    addi    sp, sp, 32
    eret

	
TIMER_ISR:
    /* Increment COUNT by the value of RUN */
	movia r4, TIMER_BASE   # clear the timeout bit
    stwio r0, (r4)
	
    movia   r4, RUN
    ldw     r5, 0(r4)
    beq     r5, r0, SKIP_INC   /* Check if RUN is 0 */
    movia   r4, COUNT
    ldw     r5, 0(r4)
    addi    r5, r5, 1          /* Increment COUNT */
    stw     r5, 0(r4)
SKIP_INC:
    ret
	
KEY_ISR:
    /* Toggle RUN between 0 and 1 */
    movia   r4, RUN
    ldw     r5, 0(r4)
    xori     r5, r5, 1          /* Toggle RUN */
    stw     r5, 0(r4)
    /* Acknowledge key interrupt */
    movia   r4, KEY_BASE     /* KEY base address */
    movi    r5, 0xF
    stwio   r5, 0xC(r4)        /* Write to edge capture register to clear interrupt */
    ret
.text
    .equ TIMER_BASE, 0xff202000
    .equ LED_BASE, 0xff200000
    .equ KEY_BASE, 0xff200050
    .equ COUNTER_INIT, 25000000
.global  _start
_start:
    /* Set up stack pointer */
    movia sp, 0x20000
    call    CONFIG_TIMER        # configure the Timer
    call    CONFIG_KEYS         # configure the KEYs port
    /* Enable interrupts in the NIOS-II processor */

    movi r9, 3               # enable IRQ for keys and timer 1
    wrctl ctl3, r9 
    movi r9, 1
    wrctl ctl0, r9              # enable PIE bit

    movia   r8, LED_BASE        # LEDR base address (0xFF200000)
    movia   r9, COUNT           # global variable
		
LOOP:
    ldw     r10, 0(r9)         /* Load the current count */
    stwio   r10, 0(r8)         /* Display it on the LEDs */
    br      LOOP               /* Endless loop */


CONFIG_TIMER:
    movia r8, TIMER_BASE

    movi r9, 0b1000          # STOP timer in case it was running
    stwio r9, 0x4(r8)
    stwio r0, (r8)           # reset timer data
    movia r9, COUNTER_INIT   # move the counter value in
    srli r10, r9, 16
    andi r9, r9, 0xffff
    stwio r9, 0x8(r8)
    stwio r10, 0xC(r8)
    movi r9, 0b0111          # START, CONT, ITO
    stwio r9, 0x4(r8)
    ret
CONFIG_KEYS: 
    movia r8, KEY_BASE
    movi r9, 0b1111
    stwio r9, 0xC(r8)   # clear edge capture
    stwio r9, 0x8(r8)   # enable interrupts for every key
    ret

.data
/* Global variables */
.global  COUNT
COUNT:  .word    0x0            # used by timer

.global  RUN                    # used by pushbutton KEYs
RUN:    .word    0x1            # initial value to increment COUNT

.end