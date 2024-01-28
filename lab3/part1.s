/* Program to Count the number of 1's in a 32-bit word,
located at InputWord */

.global _start
_start:
  movi r8, 1    # our bitmask
  movi r9, 32   # counter
  movi r10, 0   # answer
  movia r11, InputWord
  ldw r12, (r11)    # the word we're working on

loop:
  beq r9, r0, done
  and r11, r8, r12
  beq r11, r0, zero   # if the and resulted in 0, skip incrementing answer
  addi r10, r10, 1    # otherwise we increment answer
zero:
  subi r9, r9, 1      # dec counter
  slli r8, r8, 1      # shift bitmask
  br loop

done:
  movia r11, Answer
  stw r10, (r11)

endiloop: br endiloop

InputWord: .word 0x4a01fead

Answer: .word 0
	
	