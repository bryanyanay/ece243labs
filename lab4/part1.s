  .global _start

_start:
  .equ KEY_BASE, 0xff200050
  .equ LEDS, 0xff200000

  movia r8, LEDS
  movia r9, KEY_BASE

polling:
  ldwio r10, (r9) 
  andi r11, r10, 0b1              # check KEY0
  bne r11, r0, wait_release_key0  # if KEY0 is pressed

  andi r11, r10, 0b10             
  bne r11, r0, wait_release_key1

  andi r11, r10, 0b100             
  bne r11, r0, wait_release_key2

  andi r11, r10, 0b1000
  bne r11, r0, wait_release_key3

  br polling

wait_release_key0:
  ldwio r10, (r9)
  andi r11, r10, 0b1  
  bne r11, r0, wait_release_key0  # if KEY0 is stilling being pressed, keep waiting

  # already consistent with behaviour of setting LEDs to 1 when they are all 0
  movi r12, 1       # set the LEDs to 1
  stwio r12, (r8) 

  br polling

wait_release_key1:
  ldwio r10, (r9)
  andi r11, r10, 0b10  
  bne r11, r0, wait_release_key1  # if KEY1 is stilling being pressed, keep waiting

  # already consistent with behaviour of setting LEDs to 1 when they are all 0
  ldwio r12, (r8)                 # load the LEDs current value
  movi r13, 0b1111
  beq r12, r13, polling           # if already 15, don't increment, just go back to polling
  addi r12, r12, 1                # otherwise, increment
  stwio r12, (r8)
  br polling

wait_release_key2:
  ldwio r10, (r9)
  andi r11, r10, 0b100  
  bne r11, r0, wait_release_key2  # if KEY2 is stilling being pressed, keep waiting

  ldwio r12, (r8)                 # load the LEDs current value
  movi r13, 1
  beq r12, r13, polling           # if LEDs are 1, do nothing, just go back to polling
  
  bne r12, r0, not_all_zero       # if the LEDs are all 0, we're gonna set them to 1
  movi r12, 1
  br update_leds
not_all_zero:
  subi r12, r12, 1                # otherwise decrement
update_leds:
  stwio r12, (r8)
  br polling

wait_release_key3:
  ldwio r10, (r9)
  andi r11, r10, 0b1000  
  bne r11, r0, wait_release_key3  # if KEY3 is stilling being pressed, keep waiting

  stwio r0, (r8)
  br polling