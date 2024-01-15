.global _start
_start:
	movi r8, 0 /* r8 <- 0 */	
	movi r9, 30 /* r9 <- 30 */	
	movi r12, 0 /* r12 <- 0 */	
myloop: 
	addi r8, r8, 1 /* r8 = r8 + 1 */	
	add r12, r8, r12 /* r12 = r8 + r12 */	
blt r8, r9, myloop /* if r8 < r9, keep executing myloop */	

done: br done /* infinite loop */	