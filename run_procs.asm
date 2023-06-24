%include "../include/io.mac"

struc avg
	.quo:        resw 1
	.remain:     resw 1
endstruc

struc proc
	.pid:       resw 1
	.prio:      resb 1
	.time:      resw 1
endstruc

	;; Hint: you can use these global arrays
section .data
	prio_result     dd 0, 0, 0, 0, 0
	time_result     dd 0, 0, 0, 0, 0
	arr_len         dd 0
	quotient		dw 0
	remainder		dw 0

section .text
	global run_procs
	extern printf

run_procs:
	;; DO NOT MODIFY

	push ebp
	mov ebp, esp
	pusha

	xor ecx, ecx

clean_results:
	mov dword [time_result + 4 * ecx], dword 0
	mov dword [prio_result + 4 * ecx],  0

	inc ecx
	cmp ecx, 5
	jne clean_results

	mov ecx, [ebp + 8]		; processes
	mov ebx, [ebp + 12]		; length
	mov eax, [ebp + 16]		; proc_avg
	;; DO NOT MODIFY
   
	;; Your code starts here
	mov     [arr_len], ebx		; move the length in arr_len variable
	mov		word [quotient], 0	; set quotient to 0 (as a safety measure)
	mov		word [remainder], 0	; set remainder to 0 (as a safety measure)	
	xor     ebx, ebx		; set ebx to 0
	xor		edx, edx		; set edx to 0

main_loop:
	cmp		dword [arr_len], 0		; check if the loop has reached the end
	jle		end_main_loop			; exit the loop if necessary
	mov		dl, [ecx + ebx + proc.prio]		; take the priority
	sub		edx, 1							; subtract 1 to use edx for indexing in the array
	add		dword [prio_result + 4 * edx], 1	; increse the value in the array
	push	eax								; push eax on stack to use it properly
	xor		eax, eax						; set to 0
	mov		ax, [ecx + ebx + proc.time]		; store the time in ax
	add		dword [time_result + 4 * edx], eax	; add the time to the corresponding element of the array
	pop		eax								; bring back the eax
	add		ebx, 5							; add 5 to take the next element at next iteration
	dec		dword [arr_len]					; decrese the "counter"
	jmp		main_loop						; go back in loop
end_main_loop:
	push	ecx					; we don't need the array in ecx anymore, but I will restore it later
								; in case the checker needs it
	xor		ecx, ecx			; set ecx to 0
calculate_avg:
	cmp		ecx, 5				; check if it has reached the end of the array
	jge		end_calculate_avg	; stop the loop if the end was reached
	cmp		word [prio_result + 4 * ecx], 0		; check if the prios number is 0
	je		undefined_division					; if it is, jump to the specific block

	push	eax					; push eax on stack, to use the register for division
	xor		eax, eax			; set eax to 0
	xor		edx, edx			; set edx to 0
	mov		ax, word [time_result + 4 * ecx]	; put the dividend in ax
	div		word [prio_result + 4 * ecx]		; perform the division
	
	mov		word [quotient], ax			; save the quotient of the division
	mov		word [remainder], dx		; save the remainder of the division
	pop		eax							; bring back the eax with the array
	jmp		end_undefined_division
undefined_division:
	mov		word [quotient], 0		; set quotient to 0
	mov		word [remainder], 0		; set remainder to 0
end_undefined_division:
	;; here i have to put in the array
	xor		edx, edx			; set edx to 0
								; edx will be used to store temporary values, so I can put
								; them into the array
	mov		dx, word [quotient]						; move the quotient into dx
	mov		word [eax + 4 * ecx + avg.quo], dx		; put the quotient into the quo field
	xor		edx, edx			; set edx to 0 again, for safety
	mov		dx, word [remainder]					; move the remainder into dx
	mov		word [eax + 4 * ecx + avg.remain], dx	; put the remainder into the remain field
	inc		ecx
	jmp		calculate_avg
end_calculate_avg:
	pop		ecx					; restore the ecx from before the calculations
								; I mean the ecx that contained the initial array
	;; Your code ends here
	
	;; DO NOT MODIFY
	popa
	leave
	ret
	;; DO NOT MODIFY