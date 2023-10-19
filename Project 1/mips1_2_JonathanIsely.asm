.data
prompt: .asciiz "\nEnter a number to find factorial: " 
result: .asciiz "\nResult: "
.text	# What follows will be actual code
main: 	
	# Display prompt			
	la	$a0, prompt	# Load the address of "prompt" to $a0
	li	$v0, 4		# Load register $v0 with 4 - syscall code
	syscall			# print prompt to the I/O window
	
	# Read an integer
	li	$v0, 5		# syscall code for reading an int
	syscall			# Reads in int
	move	$a0, $v0	# stores integer in $a0
	jal	fact		# jump and link to fact
	jal	display		# jump and link to display
	li $v0,10		# End program
  	syscall
	
fact:
	addi	$sp, $sp, -8	# adjust stack for 2 items
	sw	$ra, 4($sp)	# save return addres s
	sw	$a0, 0($sp)	# save argument
	slti	$t0, $a0, 1	# test for n < 1
	beq	$t0, $zero, L1	# Branch to L1 if $t0 = 0
	addi	$v0, $zero, 1	# if so, result is 1
	addi 	$sp, $sp, 8	# pop 2 items from stack
	jr	$ra		# and return
	
L1:
	addi	$a0, $a0, -1	# else decrement n
	jal	fact		# recursive call
	lw	$a0, 0($sp)	# restore original n
	lw	$ra, 4($sp)	# and return address
	addi	$sp, $sp, 8	# pop 2 items from stack
	mul	$v0, $a0, $v0	# multiply to get result
	jr	$ra		# and return
	
display:
	move	$t1, $v0	# Move contents of $v0 into $t1
	la	$a0, result	# Load the address of "result" to $a0
	li	$v0, 4		# Load register $v0 with 4 - syscall code
	syscall			# print "result" to the I/O window
	move	$a0, $t1	# move contents of $t1 into $a0
	li	$v0, 1		# Load 1 into $v0 - print integer
	syscall			# print int	
	jr	$ra		# Return to address in $ra
