

  	;  Get a value from array -> ar[0 + 1 * qword]
	lea rcx, ar - 8
	mov rbx, 0
	add rcx, 1 * QWORD
	mov rax, [rcx]

	; Calling func example
	sub rsp, 28h
	mov qword ptr 20h[rsp], rax
	
	call WriteFile 
	add rsp, 28h
