%include "../include/io.mac"

struc proc
	.pid: resw 1
	.prio: resb 1
	.time: resw 1
endstruc

section .data
	arr_len     DD 0
	counter     DD 0
	step        DD 0
	idx			DD 0
section .text
	global sort_procs
	extern printf

sort_procs:
	;; DO NOT MODIFY
	enter 0,0
	pusha

	mov     edx, [ebp + 8]      	; processes
	mov     eax, [ebp + 12]     	; length
	;; DO NOT MODIFY

	;; Your code starts here
	mov     dword [arr_len], eax		; save the length of the array to be used unmodified
	mov		dword [counter], eax		; save the length of the arrau to be modified as a
										; countdown
	mov		ebx, 0						; ebx will be used for indexing
	mov		dword [step], 0
outer_loop:
	cmp		dword [counter], 1					; check if it has to exits the loop
	jle 	end_outer_loop						; exit the loop
	xor		eax, eax							; set eax to 0
	mov		al, byte [edx + ebx + proc.prio]	; put the priority in the lower part of ax
	mov		ecx, dword [step]					; initialize counter for inner loop
	inc		ecx									; the inner loop has to start from one step forward
	mov		dword [idx], ebx					; save the index in a variabile to use ebx as
												; increment in the inner loop
	add		ebx, 5								; increase ebx to take the next element
inner_loop:
	cmp		ecx, dword [arr_len]				; check if it has to exits the inner loop
	jge		end_inner_loop						; exit the inner loop
	mov		ah, [edx + ebx + proc.prio]			; get the current prio to compare the two elements
	cmp		al, ah								; compare the 2 prios
	jl		end_swap							; if first prio < second prio, do nothing
	jg		swap								; if first prio > second prio, perform the swap
check_time:
	push	eax					; ax will be used to store the time of proc from outer loop
	xor		eax, eax			; set eax to 0, to avoid errors
	push	ecx					; cx will be used to store the time of proc from inner loop
	xor		ecx, ecx			; set ecx to 0, to avoid errors

	mov		cx, [edx + ebx + proc.time]			; store the second proc time in cx
	push	ebx									; push the index from inner loop on stack
	xor		ebx, ebx
	mov		ebx, [idx]							; bring back the index from outer loop
	mov		ax, [edx + ebx + proc.time]			; store the first proc time in ax
	pop		ebx									; restore the index from the inner loop

	cmp		ax, cx								; compare the times to set the flag
	pop		ecx									; be careful, restore the values the 
	pop		eax									; ecx and eax had before the check
	jl		end_swap			; if first time < second time, do nothing, just jump over swap
	jg		swap				; if first time > second time, do the swap
								; if they're equal, check the pids
check_pids:
	push	eax					; push eax on stack to use the register and restore the value later
								; ax will be used to store the pid of the proc from outer loop
	push	ecx					; push ecx on stack to use the register and restore the value later
								; cx will be used to store the pid of proc from inner loop
	xor		eax, eax			; set them to 0 to avoid errors
	xor		ecx, ecx
	mov		cx, [edx + ebx + proc.pid]			; store the second pid in ecx
	push	ebx									; save the index from inner loop
	xor		ebx, ebx
	mov		ebx, [idx]							; get the index from outer loop
	mov		ax, [edx + ebx + proc.pid]			; store the first pid in eax
	pop		ebx									; restore the index from inner loop

	cmp		ax, cx								; make the comparision
	pop		ecx									; restore the values from the beggining
	pop		eax

	jl		end_swap			; jump to the end of the swap block, because there is no change to be
								; made, if ax < cx (first < second)
	jg		swap				; make the swap if ax > cx (first > second)
swap:
	;; swap the prios
	mov		byte [edx + ebx + proc.prio], al	; change de values of the two elements in the array
	push	ebx									; save the within the inner loop on the stack, to restore it
	xor		ebx, ebx							; set ebx to 0
	mov		ebx, dword [idx]					; bring the index within the outer loop
	mov		byte [edx + ebx + proc.prio], ah	; make the change here too
	xchg	al, ah								; change the values in ax, too
	pop		ebx									; restore the index from the inner loop

	;; swap the pids
	push	eax									; save the value on the stack, to use eax properly
	push	ecx									; save the value on the stack, to use ecx properly							
	xor		eax, eax							; set eax to 0
	xor		ecx, ecx							; set ecx to 0

	mov		cx, word [edx + ebx + proc.pid]		; bring the second value to cx
	push	ebx									; save the index from the inner loop
	xor		ebx, ebx							; set ebx to 0 to avoid errors
	mov		ebx, dword [idx]					; bring back the index within the outer loop
	mov		ax, word [edx + ebx + proc.pid]		; bring the first value to ax
	mov		word [edx + ebx + proc.pid], cx		; change the value of the element in the outer loop
	pop		ebx									; bring back the index to make the change in the inner loop, too
	mov		[edx + ebx + proc.pid], ax			; change the value of element in the inner loop

	pop		ecx									; restore the value of ecx
	pop		eax									; restore the value of eax

	;; swap the time
	push	eax										; save the value on the stack, to use eax properly
	push	ecx										; save the value on the stack, to use ecx properly							
	xor		eax, eax								; set eax to 0
	xor		ecx, ecx								; set ecx to 0

	mov		cx, word [edx + ebx + proc.time]		; bring the second value to cx
	push	ebx										; save the index from the inner loop
	xor		ebx, ebx								; set ebx to 0 to avoid errors
	mov		ebx, dword [idx]						; bring back the index within the outer loop
	mov		ax, word [edx + ebx + proc.time]		; bring the first value to ax
	mov		word [edx + ebx + proc.time], cx		; change the value of the element in the outer loop
	pop		ebx										; bring back the index to make the change in the inner loop, too
	mov		[edx + ebx + proc.time], ax				; change the value of element in the inner loop

	pop		ecx										; restore the value of ecx
	pop		eax										; restore the value of eax
end_swap:
	inc		ecx										; increase the step for inner loop
	add		ebx , 5									; get the new index
	jmp		inner_loop								; return to inner loop
end_inner_loop:
	mov		ebx, [idx]								; bring back the index from outer loop
	inc		dword [step]							; increse the number of steps
	add		ebx, 5									; take ebx to the next element
	dec		dword [counter]							; countdown to 1
	jmp		outer_loop								; go back in the loop
end_outer_loop:
	;; Your code ends here
	
	;; DO NOT MODIFY
	popa
	leave
	ret
	;; DO NOT MODIFY