.text  # The numbers that turn into executable instructions
.global _start
_start:

/* r13 should contain the grade of the person with the student number, -1 if not found */
/* r10 has the student number being searched */
	movia r10, 718293		# r10 is where you put the student number being searched for

/* Your code goes here  */

  movi r13, -1
  movia r14, Grades
  movia r11, Snumbers

loop:
  ldw r12, (r11)      # r12 is the snum we're examining
  beq r12, r0, done   # if we've reached the end of the list (without finding the snum)
  beq r12, r10, found # found the student number
  addi r11, r11, 4    # increment the grade and snum indexes
  addi r14, r14, 1
  br loop

found:
  ldb r13, (r14)
done:
  movia r9, result
  stb r13, (r9)

iloop: 
  br iloop

.data  	# the numbers that are the data 

/* result should hold the grade of the student number put into r10, or
-1 if the student number isn't found */ 

result: .byte 0
        .align 2

/* Snumbers is the "array," terminated by a zero of the student numbers  */
Snumbers: .word 10392584, 423195, 644370, 496059, 296800
        .word 265133, 68943, 718293, 315950, 785519
        .word 982966, 345018, 220809, 369328, 935042
        .word 467872, 887795, 681936, 0

/* Grades is the corresponding "array" with the grades, in the same order*/
Grades: .byte 99, 68, 90, 85, 91, 67, 80
        .byte 66, 95, 91, 91, 99, 76, 68  
        .byte 69, 93, 90, 72
	
	
