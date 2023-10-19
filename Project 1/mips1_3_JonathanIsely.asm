# VAR REGISTERS
# $s0 Max Width
# $s1 - Expected lead spaces
# $s2 - line count
# $s3 - Total expected lines
# $s4 - Expected middle spaces
# $s5 - current empty spaces

.data
prompt: .asciiz "\nMax Diamond Width: " 
result: .asciiz "\nResult: "
.text	# What follows will be actual code
main: 	
	# Display prompt			
	la	$a0, prompt		# Loads prompt into $a0
	li	$v0, 4			# Load register $v0 with 4 - syscall code
	syscall				# print prompt to the I/O window
	
	# Read an integer
	li	$v0, 5			# syscall code for reading an int
	syscall
	move	$s0, $v0		# Stores max width in $s0
	
	# $s1 keeps track of expected leading spaces
	add	$s1, $zero, $s0		# Stores expected leading spaces
	
	# $s2 keeps track of line count
	add	$s2, $zero, $zero	# current line count
	
	# Storing total expected lines in $s3
	add	$s3, $zero, $s0		# Initialized to width
	add	$s3, $s3, $s3		# Doubling
	addi	$s3, $s3, -1		# Subtracting 1 to get final expected line count of diamond
	
	# $s4 keeps track of expected middle spaces
	addi	$s4, $zero, 1		# Expected middle spaces on current line
		
	# $s5 keeps track of current number of leading or middle spaces
	add	$s5, $zero, $zero	# current number of spaces - Resets when leading or middle spaces are done being written 	

# Runs at start of each line and branches based upon various conditions	
init:
	beq	$s2, $s3, end		# Branch to end if line count = expected line count
	addi	$s2, $s2, 1		# Adding 1 to line count
	ble	$s2, $s0, increase	# branch to increase if current line <= width
	bgt	$s2, $s0, decrease	# branch to decrease if current line > width

# Used when width is increasing to print lines
increase:
	addi	$s1, $s1, -1		# decrement expected num of leading spaces
	jal 	lead			# jump to lead
	add	$s5, $zero, $zero	# reset space tracker
	jal 	star			#jump to star
	beq	$s2, 1, new_line	# if line tracker is line 1, go to newline
	jal	mid			# jump to mid
	addi	$s4, $s4, 2		# increase expected middle spaces by 2
	add	$s5, $zero, $zero	# Reset spaces tracker
	jal 	end_star		# Draw end_star
	beq	$s0, $s2, decrement	# If current line = expected width, Go to decrement
	j 	init			# jump to init

# Used to set up middle spaces for when width starts decreasing
decrement:
	addi	$s4, $s4, -2		# Decrease expected middle spaces by 2
	j init				# jump to init

# Used when width is decreasing to print lines
decrease:
	addi	$s4, $s4, -2		# Decrease expected middle spaces by 2
	addi	$s1, $s1, 1		# increment expected num of leading spaces
	jal 	lead			# jump to lead
	add	$s5, $zero, $zero	# reset space tracker
	jal 	star			# jump to star
	jal	mid			# jump to mid
	add	$s5, $zero, $zero	# Reset spaces tracker
	jal 	end_star		# jump to end_star
	j 	init			# jump to init

# Used to print leading spaces		
lead:
	beq	$s1, $zero, return	# If expected leading spaces is 0, return
	la	$a0, ' '		# Loads space into $a0
	li	$v0, 11			# Load register $v0 with 11 - syscall code
	syscall				# print prompt to the I/O window
	addi	$s5, $s5, 1		# increments current number of leading spaces
	beq	$s5, $s1, return	# return if number of leading 0s reaches correct ammount
	j	lead			# jump to top of lead

# Used to print middle spaces
mid:
	la	$a0, ' '		# Loads space into $a0
	li	$v0, 11			# Load register $v0 with 11 - syscall code
	syscall				# Print space
	addi $s5, $s5, 1		# increment current spaces count
	blt	$s5, $s4, mid		# jump to top of mid if current spaces < expected mid spaces	
	j	return			# otherwise jump to return
	
# used to print ending star and newline
end_star:
	la	$a0, 0x2a		# Load $a0 with asterisk
	li	$v0, 11			# load register $v0 with 11 - syscall code
	syscall				# print asterisk
	la	$a0, '\n'		# load $a0 with newline
	li	$v0, 11			# load $v0 with 11 - syscall code
	syscall				# print newline
	jr	$ra			# return to address stored in $ra

# Used to print new_line character in specific circumstance
new_line:
	la	$a0, '\n'		# Load $a0 with newline
	li	$v0, 11			# Load $v0 with 11 - syscall code
	syscall				# Print newline
	j	init			# Jump to init

# Sometimes used to return when called via branching condition
return:
	jr	$ra			# returns to address in $ra

# Used to draw initial asterisk
star:
	la	$a0, 0x2a		# Load $a0 with 0x2a
	li	$v0, 11			# Load $v0 with 11 - syscall code
	syscall				# Print asterisk
	beq	$s2, $s3, end		# Branch to end if linecount = current line
	jr	$ra			# Return to $ra otherwise

 # end of program	
 end:
	li $v0,10			# End program
  	syscall				# syscall
	
