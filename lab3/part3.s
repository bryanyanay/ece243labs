.text
/* Program to Count the number of 1's and Zeroes in a sequence of 32-bit words,
and determines the largest of each */

.global _start

_start:
  movia r16, TEST_NUM   # our pointer into the list
  movi r17, 0           # will record largest ones encountered so far
  movi r18, 0           # largest zeroes encountered so far
  movia r19, 0xFFFFFFFF # used to flip the bits 
mainloop:
  ldw r4, (r16)
  beq r4, r0, maindone              # end of list
  call ONES
  ble r2, r17, nochange_ones    # if new ones is <= largest ones so far, do nothing
  mov r17, r2                   # otherwise update largest ones so far
nochange_ones:
  xor r4, r4, r19       # flip all the bits
  call ONES
  ble r2, r18, nochange_zeroes
  mov r18, r2
nochange_zeroes:
  addi r16, r16, 4
  br mainloop
maindone: 
  movia r16, LargestOnes
  stw r17, (r16)
  movia r16, LargestZeroes
  stw r18, (r16)

endiloop: br endiloop

ONES: # using r8, r9, r11 [other than r2 & r4]
  movi r8, 1    # our bitmask
  movi r9, 32   # counter
  movi r2, 0   # answer
loop:
  beq r9, r0, done
  and r11, r8, r4
  beq r11, r0, zero   # if the and resulted in 0, skip incrementing answer
  addi r2, r2, 1    # otherwise we increment answer
zero:
  subi r9, r9, 1      # dec counter
  slli r8, r8, 1      # shift bitmask
  br loop
done:
  ret

.data
TEST_NUM:  .word 0x4a01fead, 0xF677D671,0xDC9758D5,0xEBBD45D2,0x8059519D
            .word 0x76D8F0D2, 0xB98C9BB5, 0xD7EC3A9E, 0xD9BADC01, 0x89B377CD
            .word 0  # end of list 

LargestOnes: .word 0
LargestZeroes: .word 0