    .section .exceptions, "ax"

IRQ_HANDLER:
    # we use ra, et, r16
    subi sp, sp, 12
    stw ra, (sp)
    stw et, 0x4(sp)
    stw r16, 0x8(sp)

    rdctl et, ctl4      # see if the exception was caused by a hardware interrupt
    beq et, r0, SKIP_EA_DEC
    subi ea, ea, 4      # decrement if it was
SKIP_EA_DEC:

    andi r16, et, 0b10  # check for push button 
    beq r16, r0, NO_KEY
    call KEY_ISR
NO_KEY:
    andi r16, et, 0b1   # check for timeout
    beq r16, r0, NO_TIMEOUT
    call TIMEOUT_ISR
NO_TIMEOUT:

    ldw ra, (sp)
    ldw et, 0x4(sp)
    ldw r16, 0x8(sp)
    addi sp, sp, 12
    eret

    .text

    .equ TIMER_BASE, 0xff202000
    .equ LED_BASE, 0xff200000
    .equ KEY_BASE, 0xff200050
    .equ COUNTER_INIT, 25000000

# use r16, r17, r18, r19
TIMEOUT_ISR:
    subi sp, sp, 16
    stw r16, (sp)
    stw r17, 0x4(sp)
    stw r18, 0x8(sp)
    stw r19, 0xC(sp)

    movia r16, TIMER_BASE   # clear the timeout bit
    stwio r0, (r16)

    movia r16, COUNT
    ldw r17, (r16)
    movia r18, RUN
    ldw r19, (r18)
    add r17, r17, r19
    stw r17, (r16)

    ldw r16, (sp)
    ldw r17, 0x4(sp)
    ldw r18, 0x8(sp)
    ldw r19, 0xC(sp)
    addi sp, sp, 16
    ret


# uses r16, r17
KEY_ISR:
    subi sp, sp, 8
    stw r16, (sp)
    stw r17, 0x4(sp)

    movia r16, KEY_BASE     # see if a key has been pressed
    ldwio r17, 0xC(r16)
    beq r17, r0, END_KEY_ISR

    movi r17, 0b1111        # clear edge capture
    stwio r17, 0xC(r16)

    movia r16, RUN  # toggle RUN
    ldw r17, (r16)
    xori r17, r17, 1
    stw r17, (r16)

END_KEY_ISR:
    ldw r16, (sp)
    ldw r17, 0x4(sp)
    addi sp, sp, 8
    ret

    .global  _start
_start:
    /* Set up stack pointer */
    movia sp, 0x20000
    call    CONFIG_TIMER        # configure the Timer
    call    CONFIG_KEYS         # configure the KEYs port
    /* Enable interrupts in the NIOS-II processor */

    movi r9, 0b11               # enable IRQ for keys and timer 1
    wrctl ctl3, r9 
    movi r9, 0b1
    wrctl ctl0, r9              # enable PIE bit

    movia   r8, LED_BASE        # LEDR base address (0xFF200000)
    movia   r9, COUNT           # global variable
LOOP:
    ldw     r10, 0(r9)          # global variable
    stwio   r10, 0(r8)          # write to the LEDR lights
    br      LOOP

# uses r8, r9, r10
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

# uses r8, r9
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

    .global  RUN                 # used by pushbutton KEYs
RUN:    .word    0x1            # initial value to increment COUNT

    .end