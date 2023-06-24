%include "../include/io.mac"

section .data
	; The order in the arrays: 
	;; upper-left, upper-right, lower-left, lower-right
	x     dd 0, 0, 0, 0
	y     dd 0, 0, 0, 0

section .text
	global bonus
	extern printf

bonus:
	;; DO NOT MODIFY
	push 	ebp
	mov 	ebp, esp
	pusha

	mov 	eax, [ebp + 8]	; x
	mov 	ebx, [ebp + 12]	; y
	mov 	ecx, [ebp + 16] ; board

	;; DO NOT MODIFY
	;; Because of the way the array is arranged, I want to set the bits by adding
	;; 2 ^ (8 * x + y), to set the cell at (x, y), or make a x - 4 before calculating,
	;; the power if it is in the upper part of the table

	;; First, I want to calculate the x and y positions of the possible moves
	push	eax							; push x - value on stack
	push	ebx							; push y - value on stack

	add		eax, 1						; x + 1 -> for the line above
	mov		dword [x], eax				; upper-left x - value
	mov		dword [x + 4], eax			; upper-right x - value 

	add		ebx, 1						; y + 1 -> for the column at right
	mov		[y + 4], ebx				; upper-right y - value	
	mov		[y + 12], ebx				; lower-right y - value

	pop		ebx							; restore the unchanged values
	pop		eax

	sub		eax, 1						; x - 1 -> for the line below
	mov		[x + 8], eax				; lower-left x - value
	mov		[x + 12], eax				; lower-right x - value

	sub 	ebx, 1						; y - 1 -> for the column at left
	mov		[y], ebx					; upper-left y - value
	mov		[y + 8], ebx				; lower-left y - value

	xor		ebx, ebx					; set ebx to 0 to use it as increment
main_loop:
	cmp		ebx, 4						; i have to do the same steps 4 times
	jge		end_main_loop				; exit the loop when the 4th step was reached
					
	mov		eax, dword [x + 4 * ebx]	; store the current x - value in eax
	cmp		eax, 0						; eax should be at least 0
	jl		skip						; otherwise, it is outside the table
	cmp		eax, 8						; eax should be smaller than 8
	jge		skip						; otherwise, it is outside the table

	mov		edx, dword [y + 4 * ebx]	; store the current y - value in edx
	cmp		edx, 0						; the same verification is required for edx
	jl		skip
	cmp		edx, 8
	jge		skip

	;; if it reaches this point, I sould calculate 2 ^ (8 * eax + ebx), but for
	;; a special case

	push	eax							; push eax on stack to use this value in a later comparison
	
	cmp		eax, 4						; check if the piece should go on the lower part of the 
										; table, or the upper part of the table (lower : lines 
										; 0 - 3, upper : lines 4 - 7)
	jl		calculate_power				; skip this reindexing
	sub		eax, 4						; for the upper part, the x value transforms into x - 4
										; to fit the formula

calculate_power:
	imul	eax, 8						; calculate 8 * x
	add		eax, edx					; calculate 8 * x + y
	mov		edx, 1						; the result of 2 ^ (8 * x + y) will be stored in edx
pow2loop:
	cmp		eax, 0						; I have to compute 8 * x + y steps
	jle		end_pow2loop				; exit the loop
	add		edx, edx					; edx + edx is the same as 2 * edx
	dec		eax							; decrease the counter
	jmp		pow2loop					; return to loop
end_pow2loop:

	;; Now, I have to select the part of the table where to put the result
	pop		eax							; bring back the value for the later verification I told you
										; about
	cmp		eax, 4						; check if it is in the lower table
	jge		upper_table					; go to the block for the upper table	
	add		[ecx + 4], edx				; set the bit in the lower table
	jmp		skip						; skip the next block of code (actually, just an instruction)

upper_table:
	add		[ecx], edx					; set the bit in the upper table

skip:
	inc		ebx							; next step
	jmp		main_loop					; return to loop
end_main_loop:


	;; DO NOT MODIFY
	popa
	leave
	ret
	;; DO NOT MODIFY