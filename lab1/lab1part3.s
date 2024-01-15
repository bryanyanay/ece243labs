.global _start
_start:

	movi r9,30 
	movi r10,1 /* our index register */
	movi r12,0 /* initialize the sum register */
	
loop:
	add r12,r12,r10 /* add index to sum */
	addi r10,r10,1  /* increment the index */
	ble r10,r9,loop /* if index <= 30 */

done:
	br done
	
	