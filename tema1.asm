%include "includes/io.inc"

extern getAST
extern freeAST

section .bss
	root: resd 1
section .text
global main

	;Functia atoi converteste
	;din string in numar
	;se apeleaza doar pentru
	;frunze adica doar pentru numere
atoi:
	mov eax, 0
convert:
	;Se repeta pana la \0
	movzx esi, byte [edi]
	test esi, esi
	je done

	;Daca se respecta conditia inseamna
	;ca primul caracter e -
	;=> numarul este negativ
	cmp esi, 48
	jl nr_neg

	;Operatia de convertire
	sub esi, 48
	imul eax, 10
	add eax, esi

	inc edi
	jmp convert
nr_neg:
	;Cand se ajunge aici inseamna
	;ca in frunza e numar negativ
	;incrementez edi, la rezultat fac C2
	inc edi
	call atoi
	not eax
	inc eax
done:
	ret

rezolv:
	push ebp
	mov ebp, esp

	;In ebx este adresa cop stang
	;daca e null => e frunza
	mov ebx, [ebp + 8]
	mov ebx, [ebx + 4]
	test ebx, ebx
	jz numar

	;Apel recursiv stanga
	push ebx
	call rezolv

	;Apel recursiv dreapta
	mov ebx, [ebp + 8]
	mov ebx, [ebx + 8]
	push ebx
	call rezolv

	pop ebx
	pop eax

	;Aflu ce operatie este
	;in nod si apelez
	mov ecx, [ebp + 8]
	mov ecx, [ecx]
	mov ecx, [ecx]
	
        ;Numarul arata operatia cod ASCII
	cmp cl, 43
	je adun
	cmp cl, 45
	je scad
	cmp cl, 42
	je inmultire
	cdq
	idiv ebx
	jmp final
	
	;Adunarea
adun:
	add eax, ebx
	jmp final
	
	;Scaderea
scad:
	sub eax, ebx
	jmp final
	
	;Inmultirea
inmultire:
	imul ebx
	
	;Pentru toate operatiile
	;salvez rezultatul pe stiva
final:
	mov [ebp + 8], eax
	leave
	ret

numar:
	;Iau nodul care a fost pus pe stiva
	;diferentiez adica iau interiorul si
	;pun in edi, apelez atoi si fac
	;mov la rezultat pe stiva
	mov ecx, [ebp + 8]
	mov edi, [ecx]
	call atoi
	mov [ebp + 8], eax
	leave
	ret

main:
	push ebp
	mov ebp, esp
	call getAST
	mov [root], eax

	;Fac push pe stiva la root
	;Mai concret adresa root-ului
	push dword [root]
	
	;Apelez functia recursiva de
	;parcurgere si evaluare
	call rezolv
	
	;Afisez rezultat
	pop eax
	PRINT_DEC 4, eax

	;Eliberare memorie
	push dword [root]
	call freeAST
	xor eax, eax
	leave
	ret