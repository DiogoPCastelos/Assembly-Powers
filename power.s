prompt1: .asciz "Let's calculate powers!\nEnter non-negative base: "
prompt2: .asciz "Enter non-negative exponent: "
input: .asciz "%ld"
output: .asciz "Your power is: %ld\n"

.global main

# main subroutine
main:
	# prologue
	pushq %rbp # push the base pointer
	movq %rsp , %rbp # copy stack pointer value to base pointer

	#print out first prompt
	movq $0 , %rax # no vector registers in use for printf
	movq $prompt1 , %rdi # first parameter: the message string
	call printf # call printf to print message
	
	#read base
	subq $16 , %rsp # make 16 bytes space on the stack for read variable
	movq $0 , %rax # no vector registers in use for scanf
	movq $input , %rdi # set the format string to input
	leaq -16(%rbp) , %rsi # set the address on the stack for the read variable
	call scanf # call scanf subroutine with the parameters above
	popq  %r14 # saving the base variable in %r14 (Pops 8 bytes, stack no longer aligned`)	
	addq $8 , %rsp # aligning the stack, because it was pushed 16 bytes and only popped 8

	#print out second prompt
	movq $0 , %rax # no vector registers in use for printf
	movq $prompt2 , %rdi # first parameter: the message string
	call printf # call printf to print message

	#read exponent	
	subq $16 , %rsp # make 16 bytes space on the stack for read variable
	movq $0 , %rax # no vector registers in use for scanf
	movq $input , %rdi # set the format string to input
	leaq -16(%rbp) , %rsi # set the address on the stack for the read variable
	call scanf # call scanf subroutine with the parameters above
	popq  %r15 # saving the exp variable in %r15 (Pops 8 bytes, stack no longer aligned`)	
	addq $8 , %rsp # aligning the stack, because it was pushed 16 bytes and only popped 8

	#call pow with read parameters	
	movq %r14, %rdi # set first parameter to the base (saved in %r14) 
	movq %r15, %rsi # set second parameter to the exo (saved in %r15)
	call pow # call pow subroutine with the parameters above (returns result in %rax)

	# call printf to show result on screen
	movq %rax, %rsi # second parameter (the '%ld' in the format string) - the result from the pow function
	movq $0 , %rax # no vector registers in use for printf
	movq $output , %rdi # first parameter: the message string
	call printf # call printf to print message

	#epilogue
	movq %rbp, %rsp # clear local variables from stack
	popq %rbp # restore base pointer location

end: # this loads the program exit code and exits the program (end label does not serve a functional purpose here)
	movq $0 , %rdi
	call exit

# Subroutine that takes 2 arguments: base and exp and returns base to the power
# of exp.
pow:
	# prologue
	pushq %rbp # push the base pointer
	movq %rsp , %rbp # copy stack pointer value to base pointer
 
	# Passed arguments are: base in %rdi and exp in %rsi

	# If the exponent (%rsi) is 0, jump to case 0 which returns 1
	cmpq $0, %rsi
	je case_zero

	# Save %rsi value in %r14
	movq %rsi, %r14
		
	# Declare and initialize variables total to 1 in %r12 and i to 0 in %r13
	movq $1, %r12
	movq $0, %r13

# Execute loop until i (%rcx) is equal to exp (%rsi)
for:
	# total = total * base
	movq %rdi, %rax # move the %rdi (value of base variablie) value to %rax to be multiplied
	mulq %r12 # muliply the total (%r12) by base - result goes to %rax
	movq %rax, %r12 # move the multiplication result to %r12

	# increment i (i++)	
	incq %r13

	# jump back to loop if i is different from exp
	cmpq %r14, %r13	# compares i to exp
	jne for # jumps to label for if i != exp

	movq %r12, %rax # returns the variable total
	
	# epilogue
	movq %rbp, %rsp # clear local variables from stack
	popq %rbp # restore base pointer location
	ret # jumps back to main subroutine

case_zero:
	movq $1, %rax #returns 1
	
	#epilogue
	movq %rbp, %rsp
	popq %rbp

	ret #returns back in main
