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


# uses r16, r17, r18, r19, r20
KEY_ISR:
    subi sp, sp, 20
    stw r16, (sp)
    stw r17, 0x4(sp)
    stw r18, 0x8(sp)
    stw r19, 0xC(sp)
    stw r20, 0x10(sp)

    movia r16, KEY_BASE     
    ldwio r17, 0xC(r16)

    andi r18, r17, 0b1      # check KEY0
    beq r18, r0, NO_KEY0
    stwio r18, 0xC(r16)     # reset edge capture bit
    movia r18, RUN          # toggle RUN
    ldw r19, (r18)
    xori r19, r19, 1
    stw r19, (r18)
NO_KEY0:
    andi r18, r17, 0b10     # check KEY1
    beq r18, r0, NO_KEY1
    stwio r18, 0xC(r16)

    movia r18, COUNT_INIT   # double COUNT_INIT, updating it value in memory
    ldw r19, (r18)
    slli r19, r19, 1
    stw r19, (r18)

    movia r18, TIMER_BASE
    movi r20, 0b1000
    stwio r20, 0x4(r18)     # STOP the timer
    srli r20, r19, 16       # load new counter value
    andi r19, r19, 0xffff
    stwio r19, 0x8(r18)
    stwio r20, 0xC(r18)
    movi r20, 0b0111        # restart timer
    stwio r20, 0x4(r18)
NO_KEY1:
    andi r18, r17, 0b100     # check KEY2
    beq r18, r0, NO_KEY2
    stwio r18, 0xC(r16)

    movia r18, COUNT_INIT   # halve COUNT_INIT, updating it value in memory
    ldw r19, (r18)
    srli r19, r19, 1
    stw r19, (r18)

    movia r18, TIMER_BASE
    movi r20, 0b1000
    stwio r20, 0x4(r18)     # STOP the timer
    srli r20, r19, 16       # load new counter value
    andi r19, r19, 0xffff
    stwio r19, 0x8(r18)
    stwio r20, 0xC(r18)
    movi r20, 0b0111        # restart timer
    stwio r20, 0x4(r18)
NO_KEY2:

    ldw r16, (sp)
    ldw r17, 0x4(sp)
    ldw r18, 0x8(sp)
    ldw r19, 0xC(sp)
    ldw r20, 0x10(sp)
    addi sp, sp, 20
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

    movia r10, COUNT_INIT
    ldw r9, (r10)            # move the counter value in
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
    movi r9, 0b0111
    stwio r9, 0x8(r8)   # enable interrupts for every key
    ret


    .data
/* Global variables */
    .global  COUNT
COUNT:  .word    0x0            # used by timer

    .global  RUN                 # used by pushbutton KEYs
RUN:    .word    0x1            # initial value to increment COUNT
    .global COUNT_INIT
COUNT_INIT:
    .word 25000000
    .end