  .global _start

_start:
  .equ KEY_BASE, 0xff200050
  .equ LEDS, 0xff200000
  .equ COUNTER_DELAY, 500000 # use 10000000 when on actual board

  movia r16, LEDS
  movia r17, KEY_BASE
  movi r7, 0          # flag register for when counter is started/stopped; 0 = stopped, 1 = started

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

  # otherwise, wait approx 0.25 seconds
  movia r18, COUNTER_DELAY
delay:
  subi r18, r18, 1
  bne r18, r0, delay

  # then update the counter
  ldwio r18, (r16)
  movi r19, 255
  beq r18, r19, reset_counter   # if it's 255, reset to 0
  addi r18, r18, 1              # otherwise, increment
  br update_leds
reset_counter:
  movi r18, 0
update_leds:
  stwio r18, (r16)

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
