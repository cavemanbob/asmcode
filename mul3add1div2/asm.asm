.data
val dq 450
.code
f1 proc
;	example of mul which is perfectly running :)
;	mov rax,val
;	mov rbx, 2
;	mul rbx
	
;	example of div which is perfectly running :)
;	mov rax,val
;	mov rbx,3
;	xor edx,edx
;	div ebx

;	cmp and jmp ex
;	mov rbx,2
;	mov rax,3
;	cmp rbx,rax
;	je ex
;	mov rax,5
;	ret
;ex:
;	mov rax,7
;	ret

	;this part is start of code other parts for help
	mov rax,val ;get value from memory
	mov rbx,rax ;check is it odd or even
	and rbx,1	
	jnz odd		
	xor edx,edx ;div by 2
	mov rbx,2
	div rbx
	mov qword ptr [val],rax ;save calculated value to memory
	ret		; return rax to print
odd:
	mov rbx,3 ;mul by 3 and add 1
	mul rbx
	inc rax
	mov qword ptr [val],rax ;sace calculated value to memory
	ret	;return rax to print

f1 endp
end