%include "../include/io.mac"

section .text
	global simple
	extern printf

simple:
	;; DO NOT MODIFY
	push    ebp
	mov     ebp, esp
	pusha

	mov     ecx, [ebp + 8]  		; len
	mov     esi, [ebp + 12] 		; plain
	mov     edi, [ebp + 16] 		; enc_string
	mov     edx, [ebp + 20] 		; step

	;; DO NOT MODIFY
   
	;; Your code starts here
	mov		ebx, 0					; ebx will use as an index
loop_text:
	cmp		ecx, 0					; check if it has to exit the loop
	je 		end_loop_text			; exit the loop if necessary
	mov 	eax, [esi + ebx]		; take the letter
	add		eax, edx				; transform letter
	cmp		al, 90					; check if it is goes out of range
	jle		continue_loop			
	sub		eax, 26					; go back to the alphabet
continue_loop:
	mov		[edi + ebx], eax		; put the letter in edi
	inc 	ebx						; increase index
	dec 	ecx						; decrese ecx
	jmp 	loop_text				; go back at the start of the loop
end_loop_text:
	;; Your code ends here
	
	;; DO NOT MODIFY

	popa
	leave
	ret
	
	;; DO NOT MODIFY
