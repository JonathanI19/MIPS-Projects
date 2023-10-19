.data					# What follows will be data
#stringSize: .space 64 			# Sets aside 64 bytes to store the input string
y:	.asciiz	"Jonathan Isely"	# Stores my name in array y
x:	.asciiz " "			# Empty array

.text					# What follows will be text

init:					# Initial setup and loading of strings into appropriate memory locations
	la	$a1, y			# Load array y into $a1
	la	$a0, x			# Set $a0 to be location of blank array
	jal	strcpy			# Call strcpy
	li $v0,10			# Load 10 into $v0
    	syscall
	
strcpy:
	addi	$sp, $sp, -4		# adjust stack for 1 item
	sw	$s0, 0($sp)		# save $s0
	add	$s0, $zero, $zero	# Sets $s0 (i) to zero
	
L1:
	add	$t1, $s0, $a1		# addr of y[i] in $t1
	lbu	$t2, 0($t1)		# $t2 = y[i]
	add	$t3, $s0, $a0		# addr of x[i] in $t3
	sb	$t2, 0($t3)		# x[i] = y[i]
	beq	$t2, $zero, L2		# exit loop if y[i] == 0
	addi	$s0, $s0, 1		# i = i + 1
	j	L1			# next iteration of loop
L2:
	lw	$s0, 0($sp)		# restore saved $s0
	addi	$sp, $sp, 4		# Pop 1 item from stack
	jr	$ra			# and return

