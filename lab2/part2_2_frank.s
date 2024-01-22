.text  # The numbers that turn into executable instructions
.global _start
_start:

/* r13 should contain the grade of the person with the student number, -1 if not found */
/* r10 has the student number being searched */


	movia r10, 718293		# r10 is where you put the student number being searched for

/* Your code goes here  */
	movia r8, result	# the address of the result
	movia r9, Snumbers	# the address of the student numbers in in r9
	movia r11, Grades	# the address of the grades is in r11
	ldw r12, (r9)	# the first student number is in r12
	ldb r13, (r11)	# the first student's grade is in r13

/* Loop through the student numbers until Student number is found, or 0 is reached*/
loop:	beq r12, r10, finished	# student number found
	   
	   addi r9,r9,4   # add 4 to pointer to the student numbers to point to next one
	   addi r11, r11, 1 # add 4 to pointer to the grades to point to the next one
		ldw r12, (r9)	# update r12
		ldb r13, (r11)	# update r13
	   
	   bne  r12, r0, loop  # if the 0 is not reached, keep looping
	   
	   movi r13, -1   # otherwise give r13 -1 b/c no student number matched
	   
finished: stw r13, (r8)	# store the answer into result
iloop: br iloop


.data  	# the numbers that are the data 

/* result should hold the grade of the student number put into r10, or
-1 if the student number isn't found */ 

result: .byte 0
.align 2	# align the memory location to that of a word
/* Snumbers is the "array," terminated by a zero of the student numbers  */
Snumbers: .word 10392584, 423195, 644370, 496059, 296800
        .word 265133, 68943, 718293, 315950, 785519
        .word 982966, 345018, 220809, 369328, 935042
        .word 467872, 887795, 681936, 0

/* Grades is the corresponding "array" with the grades, in the same order*/
Grades: .byte 99, 68, 90, 85, 91, 67, 80
        .byte 66, 95, 91, 91, 99, 76, 68  
        .byte 69, 93, 90, 72
	
	
