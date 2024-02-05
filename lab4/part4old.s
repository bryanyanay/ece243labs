  .global _start

_start:
  .equ KEY_BASE, 0xff200050
  .equ LEDS, 0xff200000
  .equ COUNTER_INIT, 1000000
  .equ TIMER_BASE, 0xff202000

  movia r16, LEDS
  movia r17, KEY_BASE
  movia r20, TIMER_BASE
  movi r7, 0          # flag register for when counter is started/stopped; 0 = stopped, 1 = started

  # start the timer
  stwio r0, (r20)           # clear data
  movi r21, 0b1000          # STOP timer in case it was running
  stwio r21, 0x4(r20)
  movia r21, COUNTER_INIT
  srli r22, r21, 16         # r22 now has upper 16 bits of COUNTER_INIT
  andi r21, r21, 0xffff     # r21 has lower 16 bits
  stwio r21, 0x8(r20)
  stwio r22, 0xC(r20)
  movi r21, 0b0110          # START and CONT
  stwio r21, 0x4(r20)

polling:
  ldwio r4, 0xC(r17)   # store the current edge capture bits in r4

  # check KEY0
  movi r5, 0b1                    
  call check_and_handle_keypress
  bne r2, r0, counting      # if the key was pressed, skip checking the other keys

  movi r5, 0b10
  call check_and_handle_keypress
  bne r2, r0, counting

  movi r5, 0b100
  call check_and_handle_keypress
  bne r2, r0, counting

  movi r5, 0b1000
  call check_and_handle_keypress
  bne r2, r0, counting

counting:
  beq r7, r0, polling     # if counter is stopped, just go back to polling

  # otherwise, wait until next timeout
delay:
  ldwio r21, (r20)
  andi r21, r21, 1
  beq r21, r0, delay    # if TO not happened yet, keep waiting

  stwio r0, (r20)       # reset TO

  # then update the counter
  ldwio r9, (r16)
  andi r10, r9, 0b1111111     # hundreths value
  srli r9, r9, 7              # seconds value

  addi r10, r10, 1
  movi r11, 100
  bne r10, r11, update_leds           # if no hundreths overflow
  movi r10, 0                         # handle hundreths overflow
  addi r9, r9, 1
  movi r11, 8
  bne r9, r11, update_leds            # if no seconds overflow
  movi r9, 0                          # handle seconds overflow
update_leds:
  slli r9, r9, 7
  add r9, r9, r10
  stwio r9, (r16)

  br polling

# uses r8
# may modify r7 (global)
check_and_handle_keypress:
  # r4 should store current edge capture bits
  # r5 should store bitmask indicating without key to check (e.g., 0b0100 for KEY2)
  # r2 will return 1 if the key was pressed and we handled it, 0 otherwise
  and r8, r4, r5              
  beq r8, r0, not_pressed  # if KEY0 is not pressed, skip the actions
  xori r7, r7, 1           # otherwise toggle our flag
  stwio r5, 0xC(r17)        # reset edge capture bit
  movi r2, 1
  ret
not_pressed:
  movi r2, 0
  ret
