%include "../include/io.mac"

;; defining constants, you can use these as immediate values in your code
LETTERS_COUNT EQU 26

section .data
	extern len_plain
	x		    DD 0
	rotor	    DD 0
	type	    DD 0
	stop	    DD 0
	key			DB 0, 0, 0
	notch		DB 0, 0, 0
	jump		DB 0
	ret_sch		DB 0
	index		DD 0

section .text
	global rotate_x_positions
	global enigma
	extern printf

; void rotate_x_positions(int x, int rotor, char config[10][26], int forward);
rotate_x_positions:
	;; DO NOT MODIFY
	push    ebp
	mov     ebp, esp
	pusha

	mov     eax, [ebp + 8]  	; x
	mov     ebx, [ebp + 12] 	; rotor
	mov     ecx, [ebp + 16] 	; config (address of first element in matrix)
	mov     edx, [ebp + 20] 	; forward
	;; DO NOT MODIFY
	;; make a reset of the variables (I got some problems without doing this)
	mov		byte [jump], 0		; this variable will be used in the second part of
								; the task
	mov		byte [ret_sch], 0	; this variable will be used in the second part of
								; the task, too
	mov		dword [index], 0	; this variable will be used in the second part of
								; the task, too
start_function:
	;; save the values into data to use the register properly 
	mov		dword [x], eax			; save the number of positions			
	mov		dword [rotor], ebx		; save the rotor number
	mov		dword [type], edx		; save the type of rotation

	xor     eax, eax				; set eax to 0
	xor     ebx, ebx				; set ebx to 0
	xor		edx, edx				; set edx to 0


	;PRINTF32 `rotor: %d\n\x0`, dword [rotor]
	mov		ebx, dword [x]			; ebx will be used to make a x-times loop
	
	;; make a "switch-case" for the rotors
	cmp		dword [rotor], 0
	je		first_rotor

	cmp		dword [rotor], 1
	je		second_rotor

	cmp		dword [rotor], 2
	je		third_rotor
first_rotor:
									; edx remains 0, because it points to the 1st line
	mov		dword [stop], 52		; 52 = 26 * 2 -> the first 2 lines needs to be changed
	jmp		rotate
second_rotor:
	mov		edx, 52					; edx should point to the 3rd line
	mov		dword [stop], 104		; 104 = 26 * 4 -> it goes from 3rd line to the 5th line
	jmp		rotate
third_rotor:
	mov		edx, 104				; edx should point to the 5th line
	mov		dword [stop], 156		; it should stop when 7th line is reached

	;; There is something like a for in for in for
rotate:
	cmp		ebx, 0					; ebx is the counter in the biggest loop			
	jle		end_rotate				; exit the loop
	push	edx						; save edx as it is, for the next iteration
	push	ebx						; save the counter, and retrieve it at the end,
									; in order to use ebx for other purposes
	;; As the name says, we loop 2 times, for the 2 rows from a rotor
loop2times:
	cmp     edx, dword [stop]		; check if it has to exit te loop, when the 3rd next line
									; is reached
	jge     end_loop2times			; exit the loop
	xor     ebx, ebx				; set ebx to 0
move_elements:
	cmp     dword [type], 0			; choose the way we rotate
	je      rotate_left				

rotate_right:
	xor		eax, eax					; set eax to 0
	mov		al, byte [ecx + edx + 25]	; save the last element of the line in eax
	xor		ebx, ebx					; set ebx to 0
										; it will be used for going through columns
	mov		ebx, 25						; go through the line from the last element to first
	push	eax							; save the last value on stack, because it will be lost
inner_loop_right:
	cmp		ebx, 0						; check if it has reached the first column
	jle		end_inner_loop_right		; if it has, stop
	xor		eax, eax					; set eax to 0
	push	ebx							; save ebx for later (register used for indexing)
	add		ebx, edx					; go to the desired element
	sub		ebx, 1						; go to the element before
	mov		al, [ecx + ebx]				; save the value before
	mov		[ecx + ebx + 1], al			; give to the current element, the value of the previous
										; element
	pop		ebx							; restore ebx (register used for indexing)
	dec		ebx							; decrese it
	jmp		inner_loop_right			; return to loop
end_inner_loop_right:
	pop		eax							; retrive the value that was the last value
	mov		[ecx + edx], al				; put it on the first position
	jmp		end_move					; end here, because next is the part of the code
										; for the left rotation

rotate_left:
	xor		eax, eax					; set eax to 0
	mov		al, byte [ecx + edx]		; store the first value, which will be lost
	xor		ebx, ebx					; se ebx to 0. It will be going from the first element to
										; the last element
	push	eax							; save the first value on stack, because it will be lost
inner_loop_left:
	cmp		ebx, 25						; the steps are similar with those performed before
	jge		end_inner_loop_left
	xor		eax, eax
	push	ebx
	add		ebx, edx
	mov		al, [ecx + ebx + 1]			; take the next value
	mov		[ecx + ebx], al				; put the next value in the current element
	pop		ebx
	inc		ebx
	jmp		inner_loop_left
end_inner_loop_left:
	pop		eax							; restore the first value
	mov		[ecx + edx + 25], al		; put the first value on the last position
end_move:
	add     edx, 26						; add 26 to jump over a row
	jmp     loop2times					; return to the 2nd iteration, to make changes in the
										; 2nd row
end_loop2times:
	pop		ebx							; restore the index
	pop		edx							; restore the edx, which contains the number where the row
										; starts
	dec		ebx							; decrese the counter
	jmp		rotate						; go back in loop
end_rotate:
	;; This is for second part of the task
	;; switch-case
	cmp		byte [jump], 1
	je		back_to_task1
	cmp		byte [jump], 2
	je		back_to_task2
	cmp		byte [jump], 3
	je 		back_to_task3
	popa
	leave
	ret
	;; DO NOT MODIFY

; void enigma(char *plain, char key[3], char notches[3], char config[10][26], char *enc);
enigma:
	;; DO NOT MODIFY
	push 	ebp
	mov 	ebp, esp
	pusha

	mov 	eax, [ebp + 8]  		; plain (address of first element in string)
	mov		ebx, [ebp + 12] 		; key
	mov 	ecx, [ebp + 16] 		; notches
	mov 	edx, [ebp + 20] 		; config (address of first element in matrix)
	mov 	edi, [ebp + 24] 		; enc
	;; DO NOT MODIFY

	;; A little disclaimer: I did this type of push and pop in many places, maybe it wasn't
	;; necessary at all in some parts of the code , but I did it for safety
	push	eax						; save the original string
	push	edx						; save the config

	;; For start, I want to move the keys and notches into memory, in order to use ebx and ecx
	;; for other things
	xor		edx, edx				; edx starts from 0
mini_loop:
	cmp		edx, 3					; just 3 keys and 3 notches
	jge		end_mini_loop			; exit the mini_loop
	mov		al, byte [ebx + edx]	; move the key at index described by edx into memory
	mov		byte [key + edx], al
	mov		al, byte [ecx + edx]	; move the notch at index described by edx into memory
	mov		byte [notch + edx], al
	inc		edx						; next key / notch
	jmp		mini_loop				; back to loop
end_mini_loop:

	pop		edx						; restore the config				
	pop		eax						; restore the string

	xor		ebx, ebx				; set the registers that stored the keys and
	xor		ecx, ecx				; the notches to 0 
	mov		ebx, dword [len_plain]	; save the initial length in ebx
	push	ebx						; each iteration, the initial length will be retrieved
									; from the stack 
strlen_loop:
	cmp		dword [len_plain], 0	; go through all the characters of the string
	jle		end_strlen_loop			; exit the loop if all the characters where encoded
	pop		ebx						; bring back the initial value to calculate the index
	push	ebx						; save it as it is, for the next iter
	sub		ebx, dword [len_plain]	; calculate the current index
	mov		dword [index], ebx		; save the current index, for the final part of the for loop,
									; where I need it to put the character in edi
									; I could have done something with the stack, but this was added
									; later, after almost 200 lines of code, you know...

	mov		cl, [eax + ebx]			; store the current letter in cl, but just temporarily, until I
									; put it in eax
	push	eax						; because it will be a big code, I need as many register as 
									; possible, so I will push eax on stack, and retrieve it after
									; I encoded the letter. In the meantime, eax will store the
									; current letter
	movzx 	eax, cl					; store the letter in eax

	;; Firstly, I will check if the second rotor is in the notch position, in order to rotate
	;; all 3 rotors
check_second:
	movzx	ecx, byte [key + 1]		; store the key of the second rotor in ecx, just for this step
	cmp		cl, byte [notch + 1]	; compare with the notch
	je		rotate_first_rotor		; if they are equal, I have to rotate all the 3 rotors
	jmp		check_third				; if they aren't check if the third rotor is on notch position

	;; Another little disclaimer: I completed this part of the code lately, so the numbers for the
	;; return points are not ordered (I think they are in descending order, tho)
rotate_first_rotor:
	;; Set the parameters for calling rotate_x_positions, the return point, and save the current
	;; values
	mov		byte [jump], 3			; set the return point to 3
	pusha							; save all we have by now
	mov		ecx, edx				; move the configuration to ecx
	mov		eax, 1					; rotate by 1
	mov		ebx, 0					; rotate the first rotor
	xor		edx, edx				; rotate left
	jmp		start_function			; "call" the function, in this way

back_to_task3:
	popa							; retrieve the values
	inc		byte [key]				; take the next letter as key
	cmp		byte [key], 90			; check if it has reached the letter 'Z'
	jle		rotate_second_rotor		; jump over this step, if is not the case
	sub		byte [key], 26			; turn 'Z' into 'A'
	jmp		rotate_second_rotor		; rotate next rotor

	;; I will check if the third rotor is on notch position, in order to rotate both the third
	;; and the second rotor
check_third:
	movzx	ecx, byte [key + 2]		; store the key of the third rotor in ecx
	cmp		cl, byte [notch + 2]	; compare with the notch
	je		rotate_second_rotor		; if they're equal, rotate the both
	jmp		rotate_third_rotor		; else, rotate just the third

rotate_second_rotor:
	mov		byte [jump], 2			; set the return point to 2
	pusha							; save all we have by now
	mov		ecx, edx				; move the configuration to ecx
	mov		eax, 1					; rotate by 1
	mov		ebx, 1					; rotate the second rotor
	xor		edx, edx				; rotate left
	jmp		start_function			; "call" the function in this strange way

back_to_task2:
	popa							; retrieve the values when the rotation is done
	inc		byte [key + 1]			; increse the initial position
	cmp		byte [key + 1], 90		; check if it has reached 'Z'
	jle		rotate_third_rotor		; skip over this, if the letter is in the alphabet
	sub		byte [key + 1], 26		; transform to A

	;; The third rotor will be always rotated
rotate_third_rotor:
	mov		byte [jump], 1			; set the jump to 1 to return to this part
	pusha							; push all we have by now
	mov		ecx, edx				; move the configuration to ecx
	mov		eax, 1					; rotate by 1 position
	mov		ebx, 2					; rotate the third rotor
	xor		edx, edx				; rotate left
	jmp		start_function			; "call" the function

back_to_task1:
	popa							; return to our scope by retrieving the inital parameters
	inc		byte [key + 2]			; increse the initial key
	cmp		byte [key + 2], 90		; check if it has reached 'Z'
	jle		start_enc				; jump over this part, if the letter is in the alphabet
	sub		byte [key + 2], 26		; transform in A

start_enc:
	;; First, I have to search for the index where the letter is on the last row
	;; of the matrix
	;; The last row starts from 234
	push	edx								; save the begging of the matrix
	add		edx, 234						; go to the last row
	mov		byte [ret_sch], 1				; set the return point
	jmp		search							; search the index

return_point1:
	pop		edx								; retrieve the matrix
	
	;; Now, I have to take the letter from this column whose index I just found, but from the
	;; 6th row, and search for it's position in the 5th row
	;; 6th row start from 130, and 5th row from 104
	movzx	eax, byte [edx + ebx + 130]		; take the letter from 6th row
	push	edx								; save the begging of the array
	add		edx, 104						; go to the 5th row
	mov		byte [ret_sch], 2				; set the return point
	jmp		search							; search the index

return_point2:
	pop		edx								; retrieve the matrix							
	
	;; Now, I have to take the letter from this column whose index I just found, but from the
	;; 4th row this time, and search for it's position on the 3rd row
	;; 4th row starts at 78, and 3rd row at 52
	movzx	eax, byte [edx + ebx + 78]		; take the letter from 4th row
	push	edx								; save the beggining of the matrix
	add		edx, 52							; go to the 3rd row
	mov		byte [ret_sch], 3				; set the return point
	jmp		search							; search the index

return_point3:
	pop		edx						; retrieve the matrix

	;; Now, I have the take the letter from this column whose index I just found, but from the
	;; 2nd row this time, and search for it's position on the 1st row
	;; 2nd row starts at 26, and 1st row at 0
	movzx	eax, byte [edx + ebx + 26]		; take the letter from the 2nd row
	;; This time, the edx coincide with the begging of the 1st row, so I won't push edx again
	mov		byte [ret_sch], 4				; set the return point
	jmp		search							; search the index

return_point4:
	
	;; Now, I have to take the letter from the 8th row at the index I found last time, and find
	;; it's correspondent letter from 7th row
	;; 8th row starts at 182
	movzx	eax, byte [edx + ebx + 182]		; I could skip this move instruction, but it seems
											; natural to let this here, for the understanding of
											; the code
	movzx	eax, byte [edx + ebx + 156]		; the the correspondent letter from the 7th row

	;; Search it's index on the 8th row
	push	edx								; save the beggining of the matrix
	add		edx, 182						; go to the 8th row
	mov		byte [ret_sch], 5 				; set the return point
	jmp		search							; search

return_point5:
	pop		edx								; retrieve the matrix
	
	;; Now, I have to take the letter from the 1st row, and search it's index on the 2nd row
	movzx	eax, byte [edx + ebx]			; take the letter from 1st row
	push	edx								; save the beggining of the matrix
	add		edx, 26							; go to the 2nd row
	mov		byte [ret_sch], 6				; set the return point
	jmp		search							; search

return_point6:
	pop		edx								; retrieve the matrix
	
	;; Now, I have to take the letter from the 3rd row, and search it's index on the 4th row
	movzx	eax, byte [edx + ebx + 52]		; take the letter from 3rd row
	push	edx								; save the beggining of the array
	add		edx, 78							; go to 4th row
	mov		byte [ret_sch], 7				; set the return point
	jmp		search							; search

return_point7:
	pop		edx								; restore the matrix
	
	;; Now, I have to take the letter from the 5th row, and search it's index on the 6th row
	movzx	eax, byte [edx + ebx + 104]		; take the letter from 5th row
	push	edx								; save the matrix
	add		edx, 130						; go to 6th row
	mov		byte [ret_sch], 8				; set the return point
	jmp		search							; search

return_point8:
	pop 	edx								; restore the matrix
	
	;; Now I have to take the letter from last row, and this is the encrypted letter
	movzx	eax, byte [edx + ebx + 234]		; take the letter
	mov		ebx, dword [index]				; take the index, to store the letter in the string
											; from edi
	mov		byte [edi + ebx], al			; put the letter in the string

	pop		eax								; retrieve the string
	dec		dword [len_plain]				; decrese the number of letters
	jmp		strlen_loop						; return to loop
end_strlen_loop:
	pop		ebx								; i have to pop the last value, because within the last 
											; iteration there was a push, and the value was
											; expected to pop at next iteration
	;; DO NOT MODIFY
	popa
	leave
	ret
	;; DO NOT MODIFY

	;; For this pseudo function, the letter we search for is always stored in al,
	;; and the index is always stored and returned in ebx
search:
	xor		ebx, ebx						; set ebx to 0
search_index:
	cmp		byte [edx + ebx], al			; compare the desired letter, with the
											; current letter
	je		end_search_index				; if the letter was found, stop the loop
	inc		ebx								; take the next letter
	jmp		search_index					; perform next iteration
end_search_index:

	;; Something like a switch-case
	cmp		byte [ret_sch], 1
	je		return_point1					; return to point 1
	cmp		byte [ret_sch], 2
	je		return_point2					; return to point 2
	cmp		byte [ret_sch], 3
	je 		return_point3					; return to point 3
	cmp		byte [ret_sch], 4
	je		return_point4					; return to point 4
	cmp		byte [ret_sch], 5
	je		return_point5					; return to point 5
	cmp		byte [ret_sch], 6
	je		return_point6					; return to point 6
	cmp		byte [ret_sch], 7
	je 		return_point7					; return to point 7
	cmp		byte [ret_sch], 8
	je 		return_point8					; return to point 8