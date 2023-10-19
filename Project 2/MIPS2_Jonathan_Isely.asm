# This program takes in an input of up to 64 characters
# and determines if it is a valid mathematical expression
# Author: Jonathan Isely

.data						# What follows will be data
prompt:		.asciiz				"\n>>> "
isValid:	.asciiz				"Valid Input"
isNotValid:	.asciiz				"Invalid Input" 
inputString: 	.space 64			# Sets aside 64 bytes to store input string

.text						# What follows will be actual code

#########################################################################
# MAIN SUBROUTINE: This is the main loop of the program
MAIN:
	jal	INIT				# Jump and link to INIT
	jal	CHAR_START			# Jump and link to CHAR_START
	add	$t0, $zero, $zero		# [i] = 0
	jal	COUNT_PAREN_START		# Jump and link to COUNT_PAREN_START
	add	$t0, $zero, $zero		# [i] = 0
	jal	CHECK_COMBO			# Jump and link to CHECK_COMBO
	add	$t0, $zero, $zero		# [i] = 0
	jal	CHECK_COEFFICIENTS		# Jump and link to CHECK_COEFFICIENTS
	add	$t0, $zero, $zero		# [i] = 0
	jal	CHECK_START			# Jump and link to CHECK_START
	add	$t0, $zero, $zero		# [i] = 0
	add	$t3, $zero, $zero		# Ensure num flag is 0
	add	$t4, $zero, $zero		# Ensure space flag is 0
	jal	CHECK_DIGITS			# Jump and link to CHECK_DIGITS
	add	$t0, $zero, $zero		#[i] = 0
		
	jal	VALID				# If the main loop reaches here, input expression is valid

#########################################################################
# MAIN SUBROUTINE: Carries out initial procedures
INIT:
	# Display prompt to user
	la	$a0, prompt			# Load prompt into $a0
	li	$v0, 4				# System call code to print string
	syscall
	
	# Collect input expression
	la	$a0, inputString		# Load $a0 with address of inputString
	la	$a1, inputString		# Load $a1 with max num of characters
	li	$v0, 8				# Syscall code to read string input
	syscall
	
	# Setting up registers for keeping track of string
	la	$s0, inputString		# __STRING - Stores input string into $s0
	add	$t0, $zero, $zero		# [i] - Set to 0
	add	$t1, $zero, $zero		# Init $t1 to 0
	add	$t2, $zero, $zero		# Init $t2 to 0
	add	$t3, $zero, $zero		# Init num flag to 0
	add	$t4, $zero, $zero		# Init space flag to 0
	add	$t6, $zero, $zero		# Init parenthesis counter to 0

	j	RETURN				# Return to main
 
#########################################################################
# MAIN SUBROUTINE: Checks to make sure all characters are valid	
CHAR_START:
	add	$t1, $s0, $t0			# $t1 = address of __STRING[i]
	lb	$t2, 0($t1)			# $t2 = char[i]
	addi	$t0, $t0, 1			#Increment counter
	beq	$t2, 10, RETURN			# Break out of subroutine if end of line is reached
	beq	$t2, 0, RETURN			# Break out of subroutine if end of line is reached
	
	beq	$t2, 32, CHAR_END		# Valid if Space
	beq	$t2, 40, CHAR_END		# Valid if (
	beq	$t2, 41, CHAR_END		# Valid if )
	beq	$t2, 42, CHAR_END		# Valid if *
	beq	$t2, 43, CHAR_END		# Valid if +
	beq	$t2, 45, CHAR_END		# Valid if -
	beq	$t2, 47, CHAR_END		# Valid if /
	beq	$t2, 48, CHAR_END		# Valid if 0
	beq	$t2, 49, CHAR_END		# Valid if 1
	beq	$t2, 50, CHAR_END		# Valid if 2
	beq	$t2, 51, CHAR_END		# Valid if 3
	beq	$t2, 52, CHAR_END		# Valid if 4
	beq	$t2, 53, CHAR_END		# Valid if 5
	beq	$t2, 54, CHAR_END		# Valid if 6
	beq	$t2, 55, CHAR_END		# Valid if 7
	beq	$t2, 56, CHAR_END		# Valid if 8
	beq	$t2, 57, CHAR_END		# Valid if 9
	j	NOT_VALID			# NOT VALID CHARACTER

# Used to bypass NOT_VALID Jump
CHAR_END:

	j	CHAR_START

#########################################################################	
# MAIN SUBROUTINE: Count Parenthesis and make sure final value is correct.
COUNT_PAREN_START:
	add	$t1, $s0, $t0			# $t1 = address of __STRING[i]
	add	$t6, $zero, $zero		# $t6 = Parenthesis tally = 0
	lb	$t2, 0($t1)			# t2 = char[i]
	addi	$t0, $t0, 1			# Increment counter
	beq	$t2, 10, RETURN			# Break out of subroutine if new line is reached
	beq	$t2, 0, RETURN			# Break out of subroutine if end of line is reached
	
	ble	$t2, 39, COUNT_PAREN_START	# Branch if less than parenthesis on ascii table
	bge	$t2, 42, COUNT_PAREN_START	# Branch if greather than parenthesis on ascii table
	beq	$t2, 41, NOT_VALID		# Not valid if first parenthesis found is ")"
	beq	$t2, 40, L_P			# Branch to L_P if "("
	j	RETURN				# Jump to Return if no parenthesis found

# Helps to navigate parenthesis check	
COUNT_PAREN_MID:
	add	$t1, $s0, $t0			# $t1 = address of __STRING[i]
	lb	$t2, 0($t1)			# $t2 = char[i]
	addi	$t0, $t0, 1			# increment counter
	beq	$t2, 10, COUNT_PAREN_END	# Branch if end of string
	beq	$t2, 40, L_P			# Branch to L_P if "("
	beq	$t2, 41, R_P			# Branch to R_P if ")"
	j	COUNT_PAREN_MID			# Jump to COUNT_PAREN_MID
	
# Increase tally if "("
L_P: 
	addi	$t6, $t6, 1			# Increase parenthesis tally
	j	COUNT_PAREN_MID			# Jump to COUNT_PAREN_MID
	
# Decrease tally if ")"
R_P: 
	addi	$t6, $t6, -1			# Decrease parenthesis tally
	blt	$t6, $zero, NOT_VALID		# NOT_VALID if ) gets placed before (
	j	COUNT_PAREN_MID			# Jump to COUNT_PAREN_MID

# Check validity at end	
COUNT_PAREN_END:
	beq	$t6, $zero, RETURN			# Utilize Return to return to main loop if valid
	j	NOT_VALID			# else, Jump to NOT_VALID
	
#########################################################################	
# MAIN SUBROUTINE: Checks for invalid operator combos
CHECK_COMBO:
	add	$t1, $s0, $t0			# $t1 = address of __STRING[i]
	lb	$t2, 0($t1)			# t2 = char[i]
	addi	$t0, $t0, 1			# Increment counter
	beq	$t2, 10, RETURN			# Break out of subroutine if end of line is reached
	beq	$t2, 0, RETURN			# Break out of subroutine if end of line is reached
	
	beq	$t2, 40, CHECK_COMBO_2		# Branch if "("
	beq	$t2, 41, CHECK_CLOSE_PAREN	# Branch if ")"
	beq	$t2, 42, CHECK_OPERATOR		# Branch if "*"
	beq	$t2, 43, CHECK_INCREMENT	# Branch if "+"
	beq	$t2, 45, CHECK_DECREMENT	# Branch if "-"
	beq	$t2, 47, CHECK_OPERATOR		# Branch if "/"
	j	CHECK_COMBO			# Jump back to top of SUBROUTINE if char is digit or space

# Used to check 2nd char after operand is first detected	
CHECK_COMBO_2:
	add	$t1, $s0, $t0			# $t1 = address of __STRING[i]
	lb	$t2, 0($t1)			# t2 = char[i]
	addi	$t0, $t0, 1			# Increment counter
	beq	$t2, 10, RETURN			# Break out of subroutine if end of line is reached
	beq	$t2, 0, RETURN			# Break out of subroutine if end of line is reached
	
	beq	$t2, 40, CHECK_COMBO_2		# Continue to check
	beq	$t2, 41, NOT_VALID		# Invalid if ")"
	beq	$t2, 42, NOT_VALID		# Invalid if "*"
	beq	$t2, 43, CHECK_INCREMENT	# Invalid if "+"
	beq	$t2, 45, CHECK_DECREMENT	# Invalid if "-"
	beq	$t2, 47, NOT_VALID		# Invalid if "/"
	beq	$t2, 32, CHECK_COMBO_2		# Continue within CHECK_COMBO_2 if char is a "space"
	j	CHECK_COMBO			# Jump back to top CHECK_COMBO if char is digit

# Used to check for ++, which is valid
CHECK_INCREMENT:
	add	$t1, $s0, $t0			# $t1 = address of __STRING[i]
	lb	$t2, 0($t1)			# t2 = char[i]
	addi	$t0, $t0, 1			# Increment counter
	beq	$t2, 10, RETURN			# Break out of subroutine if end of line is reached
	beq	$t2, 0, RETURN			# Break out of subroutine if end of line is reached
	
	beq	$t2, 41, NOT_VALID		# Invalid if ")"
	beq	$t2, 42, NOT_VALID		# Invalid if "*"
	
	beq	$t2, 45, CHECK_DECREMENT	# CHECK_DECREMENT if -
	
	beq	$t2, 47, NOT_VALID		# Invalid if "/"
	beq	$t2, 32, CHECK_INCREMENT	# Continue within CHECK_INCREMENT if char is a "space"
	beq	$t2, 40, CHECK_COMBO_2		# Branch to CHECK_COMBO_2 if "("
	beq	$t2, 43, CHECK_INCREMENT	# Continue to CHECK_INCREMENT if also "+"
	j	CHECK_COMBO			# Jump back to top CHECK_COMBO if char is digit
	
CHECK_DECREMENT:
	add	$t1, $s0, $t0			# $t1 = address of __STRING[i]
	lb	$t2, 0($t1)			# t2 = char[i]
	addi	$t0, $t0, 1			# Increment counter
	beq	$t2, 10, RETURN			# Break out of subroutine if end of line is reached
	beq	$t2, 0, RETURN			# Break out of subroutine if end of line is reached
	
	beq	$t2, 41, NOT_VALID		# Invalid if ")"
	beq	$t2, 42, NOT_VALID		# Invalid if "*"
	
	beq	$t2, 43, CHECK_INCREMENT	# CHECK_INCREMENT if +
	
	beq	$t2, 47, NOT_VALID		# Invalid if "/"
	beq	$t2, 40, CHECK_COMBO_2		# Branch to CHECK_COMBO_2 if "("
	beq	$t2, 32, CHECK_DECREMENT	# Continue within CHECK_DECREMENT if char is a "space"
	beq	$t2, 45, CHECK_DECREMENT	# Continue to CHECK_DECREMENT if also "-"
	j	CHECK_COMBO			# Jump back to top CHECK_COMBO if char is digit	

# Checks for valid multiplication/Division i.e. *( or /(
CHECK_OPERATOR:
	add	$t1, $s0, $t0			# $t1 = address of __STRING[i]
	lb	$t2, 0($t1)			# t2 = char[i]
	addi	$t0, $t0, 1			# Increment counter
	beq	$t2, 10, RETURN			# Break out of subroutine if end of line is reached
	beq	$t2, 0, RETURN			# Break out of subroutine if end of line is reached
	
	beq	$t2, 41, NOT_VALID		# Invalid if ")"
	beq	$t2, 42, NOT_VALID		# Invalid if "*"
	beq	$t2, 43, CHECK_INCREMENT	# Invalid if "+"
	beq	$t2, 45, CHECK_DECREMENT	# Invalid if "-"
	beq	$t2, 47, NOT_VALID		# Invalid if "/"
	beq	$t2, 32, CHECK_OPERATOR		# Continue within CHECK_OPERATOR if char is a "space"
	
	beq	$t2, 40, CHECK_COMBO_2		# Branch to CHECK_COMBO_2 if "("
	j	CHECK_COMBO			# Jump back to top CHECK_COMBO if char is valid
	
# Checks for valid closing parenthesis i.e. )* or )/
CHECK_CLOSE_PAREN:
	add	$t1, $s0, $t0			# $t1 = address of __STRING[i]
	lb	$t2, 0($t1)			# t2 = char[i]
	addi	$t0, $t0, 1			# Increment counter
	beq	$t2, 10, RETURN			# Break out of subroutine if end of line is reached
	beq	$t2, 0, RETURN			# Break out of subroutine if end of line is reached
	
	beq	$t2, 40, NOT_VALID		# Invalid if "("
	beq	$t2, 41, CHECK_CLOSE_PAREN	# Branch if ")"
	beq	$t2, 42, CHECK_OPERATOR		# Branch if "*"
	beq	$t2, 43, CHECK_INCREMENT	# Branch if "+"
	beq	$t2, 45, CHECK_DECREMENT	# Branch if "-"
	beq	$t2, 47, CHECK_OPERATOR		# Branch if "/"
	beq	$t2, 32, CHECK_CLOSE_PAREN	# Continue within CHECK_CLOSE_PAREN if char is a "space"
	j	CHECK_COMBO			# Jump back to top CHECK_COMBO if char is valid	

#########################################################################	
# SUBROUTINE: Checks coefficients before/after parenthesis
CHECK_COEFFICIENTS:
	add	$t1, $s0, $t0			# $t1 = address of __STRING[i]
	lb	$t2, 0($t1)			# t2 = char[i]
	addi	$t0, $t0, 1			# Increment counter
	beq	$t2, 10, RETURN			# Break out of subroutine if end of line is reached
	beq	$t2, 0, RETURN			# Break out of subroutine if end of line is reached
	
	beq	$t2, 48, CHECK_FOR_PAREN	# Branch if 0
	beq	$t2, 49, CHECK_FOR_PAREN	# Branch if 1
	beq	$t2, 50, CHECK_FOR_PAREN	# Branch if 2
	beq	$t2, 51, CHECK_FOR_PAREN	# Branch if 3
	beq	$t2, 52, CHECK_FOR_PAREN	# Branch if 4
	beq	$t2, 53, CHECK_FOR_PAREN	# Branch if 5
	beq	$t2, 54, CHECK_FOR_PAREN	# Branch if 6
	beq	$t2, 55, CHECK_FOR_PAREN	# Branch if 7
	beq	$t2, 56, CHECK_FOR_PAREN	# Branch if 8
	beq	$t2, 57, CHECK_FOR_PAREN	# Branch if 9
	
	beq	$t2, 41, CHECK_FOR_NUM		# Branch if )
	
	j	CHECK_COEFFICIENTS		# Jump to top if we don't need to check anything above

# Checks to see if coefficient is immediately followed by parenthesis
CHECK_FOR_PAREN:
	add	$t1, $s0, $t0			# $t1 = address of __STRING[i]
	lb	$t2, 0($t1)			# t2 = char[i]
	addi	$t0, $t0, 1			# Increment counter
	beq	$t2, 10, RETURN			# Break out of subroutine if end of line is reached
	beq	$t2, 0, RETURN			# Break out of subroutine if end of line is reached
	
	beq	$t2, 40, NOT_VALID		# Not valid if digit is immediately followed by "("
	beq	$t2, 32, CHECK_FOR_PAREN	# Ignore spaces and continue checking
	
	beq	$t2, 48, CHECK_FOR_PAREN	# Check again if 0
	beq	$t2, 49, CHECK_FOR_PAREN	# Check again if 1
	beq	$t2, 50, CHECK_FOR_PAREN	# Check again if 2
	beq	$t2, 51, CHECK_FOR_PAREN	# Check again if 3
	beq	$t2, 52, CHECK_FOR_PAREN	# Check again if 4
	beq	$t2, 53, CHECK_FOR_PAREN	# Check again if 5
	beq	$t2, 54, CHECK_FOR_PAREN	# Check again if 6
	beq	$t2, 55, CHECK_FOR_PAREN	# Check again if 7
	beq	$t2, 56, CHECK_FOR_PAREN	# Check again if 8
	beq	$t2, 57, CHECK_FOR_PAREN	# Check again if 9
	beq	$t2, 41, CHECK_FOR_NUM		# Check ")"
	
	j	CHECK_COEFFICIENTS		# Jump to top of CHECK_COEFFICIENTS if currently valid

# Checks to see if ")" is immediately followed by a digit
CHECK_FOR_NUM:
	add	$t1, $s0, $t0			# $t1 = address of __STRING[i]
	lb	$t2, 0($t1)			# t2 = char[i]
	addi	$t0, $t0, 1			# Increment counter
	beq	$t2, 10, RETURN			# Break out of subroutine if end of line is reached
	beq	$t2, 0, RETURN			# Break out of subroutine if end of line is reached
	
	beq	$t2, 48, NOT_VALID		# Branch if 0
	beq	$t2, 49, NOT_VALID		# Branch if 1
	beq	$t2, 50, NOT_VALID		# Branch if 2
	beq	$t2, 51, NOT_VALID		# Branch if 3
	beq	$t2, 52, NOT_VALID		# Branch if 4
	beq	$t2, 53, NOT_VALID		# Branch if 5
	beq	$t2, 54, NOT_VALID		# Branch if 6
	beq	$t2, 55, NOT_VALID		# Branch if 7
	beq	$t2, 56, NOT_VALID		# Branch if 8
	beq	$t2, 57, NOT_VALID		# Branch if 9
	beq	$t2, 32, CHECK_FOR_NUM		# Ignore spaces and continue checking
	beq	$t2, 41, CHECK_FOR_NUM		# Check again if ")"
	j	CHECK_COEFFICIENTS		# Jump to top of CHECK_COEFFICIENTS if currently valid

#########################################################################
# MAIN SUBROUTINE: Check start and end for operator
CHECK_START:	
	add	$t1, $s0, $t0			# $t1 = address of __STRING[i]
	lb	$t2, 0($t1)			# t2 = char[i]
	addi	$t0, $t0, 1			# Increment counter
	beq	$t2, 10, RETURN			# Break out of subroutine if end of line is reached
	beq	$t2, 0, RETURN			# Break out of subroutine if end of line is reached
	
	beq	$t2, 32, CHECK_START		# Branch to top if char is space
	beq	$t2, 41, NOT_VALID		# Invalid if ")"
	beq	$t2, 42, NOT_VALID		# Invalid if "*"
	beq	$t2, 47, NOT_VALID		# Invalid if "/"
	j 	CHECK_END			# Jump to CHECK_END if first non-space is valid

# Tries to find last non-space char
CHECK_END:
	add	$t3, $t2, $zero
	add	$t1, $s0, $t0			# $t1 = address of __STRING[i]
	lb	$t2, 0($t1)			# t2 = char[i]
	addi	$t0, $t0, 1			# Increment counter

	beq	$t2, 10, CHECK_LAST		# Branch to CHECK_LAST when end of input is reached
	beq	$t2, 32, CHECK_END		# Branch to top of CHECK_END if char is space

	j	CHECK_END			# Jump to CHECK_END

# Checks validity of last non-space char
CHECK_LAST:
	beq	$t3, 40, NOT_VALID		# Invalid if last char is "("
	beq	$t3, 42, NOT_VALID		# Invalid if last char is "*"
	beq	$t3, 43, NOT_VALID		# Invalid if last char is "+"
	beq	$t3, 45, NOT_VALID		# Invalid if last char is "-"
	beq	$t3, 47, NOT_VALID		# Invalid if last char is "/"
	
	beq	$t2, 10, RETURN			# Break out of subroutine if last char is valid
	beq	$t2, 0, RETURN			# Break out of subroutine if end of line is reached
	

#########################################################################	
# MAIN SUBROUTINE: Check for spaces between numbers (not valid syntax)
CHECK_DIGITS:
	add	$t1, $s0, $t0			# $t1 = address of __STRING[i]
	lb	$t2, 0($t1)			# t2 = char[i]
	addi	$t0, $t0, 1			# Increment counter
	beq	$t2, 10, RETURN			# Break out of subroutine if end of line is reached
	beq	$t2, 0, RETURN			# Break out of subroutine if end of line is reached
	
	beq	$t2, 48, NUM_FLAG		# Branch if 0
	beq	$t2, 49, NUM_FLAG		# Branch if 1
	beq	$t2, 50, NUM_FLAG		# Branch if 2
	beq	$t2, 51, NUM_FLAG		# Branch if 3
	beq	$t2, 52, NUM_FLAG		# Branch if 4
	beq	$t2, 53, NUM_FLAG		# Branch if 5
	beq	$t2, 54, NUM_FLAG		# Branch if 6
	beq	$t2, 55, NUM_FLAG		# Branch if 7
	beq	$t2, 56, NUM_FLAG		# Branch if 8
	beq	$t2, 57, NUM_FLAG		# Branch if 9
	beq	$t2, 32, CHECK_DIGITS		# Jump back to top if space

	beq	$t2, 45, CUR_OPERATOR		# Branch if -
	beq	$t2, 43, CUR_OPERATOR		# Branch if +
	beq	$t2, 47, CUR_OPERATOR		# Branch if "/"
	beq	$t2, 42, CUR_OPERATOR		# Branch if "*"
	beq	$t2, 40, CUR_OPERATOR		# Branch if "("
	beq	$t2, 41, CUR_OPERATOR		# Branch if ")"

# Set NUM_FLAG and handle branching conditions
NUM_FLAG:
	addi	$t3, $zero, 1			# Set num flag

	add	$t1, $s0, $t0			# $t1 = address of __STRING[i]
	lb	$t2, 0($t1)			# t2 = char[i]
	addi	$t0, $t0, 1			# Increment counter
	beq	$t2, 10, RETURN			# Break out of subroutine if end of line is reached
	beq	$t2, 0, RETURN			# Break out of subroutine if end of line is reached
	
	beq	$t2, 45, CUR_OPERATOR		# Branch if -
	beq	$t2, 43, CUR_OPERATOR		# Branch if +
	beq	$t2, 47, CUR_OPERATOR		# Branch if "/"
	beq	$t2, 42, CUR_OPERATOR		# Branch if "*"
	beq	$t2, 40, CUR_OPERATOR		# Branch if "("
	beq	$t2, 41, CUR_OPERATOR		# Branch if ")"
	beq	$t2, 32, SPACE_FLAG		# Branch if space
	
	beq	$t2, 48, COMPARE_FLAG		# Branch if 0
	beq	$t2, 49, COMPARE_FLAG		# Branch if 1
	beq	$t2, 50, COMPARE_FLAG		# Branch if 2
	beq	$t2, 51, COMPARE_FLAG		# Branch if 3
	beq	$t2, 52, COMPARE_FLAG		# Branch if 4
	beq	$t2, 53, COMPARE_FLAG		# Branch if 5
	beq	$t2, 54, COMPARE_FLAG		# Branch if 6
	beq	$t2, 55, COMPARE_FLAG		# Branch if 7
	beq	$t2, 56, COMPARE_FLAG		# Branch if 8
	beq	$t2, 57, COMPARE_FLAG		# Branch if 9
	
# Compares num and space flags	
COMPARE_FLAG:
	beq	$t3, $t4, NOT_VALID		# Invalid if both flags set
	j	NUM_FLAG			# Jump back to NUM_FLAG

# Sets space flag
SPACE_FLAG:
	addi	$t4, $zero, 1			# Set space flag
	j	NUM_FLAG
	
# Resets flags if cuurent character is operator
CUR_OPERATOR:
	add	$t3, $zero, $zero		# Reset digit flag
	add	$t4, $zero, $zero		# Reset space flag
	j	CHECK_DIGITS			# Jump back up to CHECK_DIGITS
	
#########################################################################	
# MAIN SUBROUTINE: Resets program if input was not valid
NOT_VALID:
	la	$a0, isNotValid			# Loads not valid string into $a0
	li	$v0, 4				# Syscall code for printing string
	syscall
	add	$ra, $zero, $zero		# Resets $ra to 0	
	j 	MAIN				# Reset by jumping back to top of main
	
#########################################################################
# MAIN SUBROUTINE: Resets program if input was valid
VALID:
	la	$a0, isValid			# Loads not valid string into $a0
	li	$v0, 4				# Syscall code for printing string
	syscall
	add	$ra, $zero, $zero		# Resets $ra to 0	
	j 	MAIN				# Reset by jumping back to top of main	

#########################################################################
# MAIN SUBROUTINE: Return to $ra
RETURN:
	jr	$ra				# Jump to address in $ra
