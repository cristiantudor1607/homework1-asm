%include "../include/io.mac"
section .data
	x   	db 0
	y   	db 0
section .text
	global checkers
	extern printf

checkers:
	;; DO NOT MODIFY
	push 	ebp
	mov 	ebp, esp
	pusha

	mov 	eax, [ebp + 8]	; x
	mov 	ebx, [ebp + 12]	; y
	mov 	ecx, [ebp + 16] ; table

	;; DO NOT MODIFY
	xor		edx, edx				; I don't think I will use edx at all, but set to 0 for safety

upper_left_corner:
	push	eax						; I still have the indexes in eax and ebx, and I want to
	push	ebx						; use them 4 times, so I will push them on stack, each time
									; I test a new case
	add		eax, 1					; one row above
	cmp		eax, 7					; check if the row above doesn't exist
	jg		upper_right_corner		; skip the case if it doesn't exist
	sub		ebx, 1					; one column left
	cmp		ebx, 0					; check if one column left doesn't exist
	jl		upper_right_corner		; skip the case if it doesn't exist

	;; put 1 in the matrix
	push	ecx						; save the inital ecx
	add		ecx, ebx				; go to the desired column
	mov		byte [ecx + 8 * eax], 1	; jump over a number of lines indicated by the value in
									; eax, with the length of 8 bytes each line
	pop		ecx						; restore the initial ecx

upper_right_corner:
	pop		ebx						; bring back the initial column index
	pop		eax						; bring back the initial row index

	push	eax						; save the row index unmodified, again
	push	ebx						; save the column index unmodified, again
	add		eax, 1					; one row above
	cmp		eax, 7					; check if the row above really exists
	jg		lower_left_corner		; skip this step if it doesn't 
	add		ebx, 1					; one column right
	cmp		ebx, 7					; check if one column right really exists
	jg		lower_left_corner		; skip this step if it doesn't
	
	;; put 1 in the matrix
	push 	ecx						; save the initial ecx
	add 	ecx, ebx				; go to the desired column
	mov		byte [ecx + 8 * eax], 1	; go to the desired line
	pop		ecx						; bring back the initial ecx

lower_left_corner:
	pop		ebx						; bring back the initial column index
	pop		eax						; bring back the inital row index

	push	eax						; save the row index
	push	ebx						; save the column index
	sub		eax, 1					; one row below
	cmp		eax, 0					; check if one row below exists		
	jl		lower_right_corner		; skip this step if it doesn't
	sub		ebx, 1					; one column left
	cmp		ebx, 0					; check if is out of the table
	jl		lower_right_corner		; skip this step if is out

	;; put 1 in the matrix
	push	ecx						; the same steps as before
	add		ecx, ebx
	mov		byte [ecx + 8 * eax], 1
	pop		ecx

lower_right_corner:
	pop		ebx						; bring back one last time the values
	pop 	eax						; this time I don't need to save them anymore

	sub		eax, 1					; one row below
	cmp		eax, 0
	jl		skip
	add		ebx, 1					; one column right
	cmp		ebx, 7
	jg		skip

	;; put 1 in the matrix
	push	ecx						; the same as before
	add		ecx, ebx
	mov		byte [ecx + 8 * eax], 1
	pop		ecx

skip:		
	;; DO NOT MODIFY
	popa
	leave
	ret
	;; DO NOT MODIFY