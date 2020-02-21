	AREA	reset, CODE, READONLY
	
;	AREA	AsmTemplate, CODE, READONLY
;	IMPORT	main

; sample program makes the 4 LEDs P1.16, P1.17, P1.18, P1.19 go on and off in sequence
; (c) Mike Brady, 2011 -- 2019.

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 	EXPORT	start
start
IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN  EQU 0xE0028010
	
;	TODO
; 	get decimal representation from hex
;   get binary representation using TABLE
; 	calls flash subroutine

ini
		ldr r4,=0	; sum
inic
		ldr r5,=0	; cur 
		ldr r6,=1	; operator
		ldr r7,=0	; temp 
		
		ldr r0,=0
		bl flash
loop	
		bl button	; get input
		
		
bn20	cmp r0,#-20	; if long P20 clearall
		bne bn21	
		b start
bn21	cmp r0,#-21	; if long P21 clear last
		bne b22
		b inic
		
b22		cmp r0,#22	; if P22 n-
		bne	b23
		sub r5,r5,#1	; n-
		mov r7,r5	; get cur into r0 for display
		b endloop
		
b23		cmp r0,#23		; if P23 n+
		bne subtract
		add r5,r5,#1	; n+
		mov r7,r5	; get cur into r0 for display
		b endloop
		
subtract
		cmp r6,#2		; if P20 -
		bne plus
		sub r4,r4,r5	; sum-=cur
		mov r7,r4		; mov for display
		ldr r5,=0		; clear cur
		b b20

plus
		cmp r6,#1		; if P21 +
		bne b20
		add r4,r4,r5	; sum+=cur
		mov r7,r4		; mov for display
		ldr r5,=0		; clear cur
		
b20
		cmp r0,#20		; if P20 -
		bne b21
		ldr r6,=2		; set op = -
		b endloop
b21
		cmp r0,#21		; if P21 +
		bne ini
		ldr r6,=1		; set op = +
		b endloop]
		

endloop
	mov r0,r7
	bl flash
	b loop
stop	B	stop
	
		
;
;	flash subroutine
;	Show the binary representation with LED flashing	
;	parameter: 
;	 R0: binary representation
;	output:
;	 none

flash   PUSH {r3-r6,lr}
		ldr	r1,=IO1DIR
		ldr	r2,=0x000f0000	;select P1.19--P1.16
		str	r2,[r1]		;make them outputs
		ldr	r1,=IO1SET
		str	r2,[r1]		;set them to turn the LEDs off
		ldr	r2,=IO1CLR
; r1 points to the SET register
; r2 points to the CLEAR register

	
	ldr	r5,=0x000080000	; end when the mask reaches this value

fs		ldr	r3,=0x000080000	; start with P1.16.
floop	ldr r6,=0
		cmp r0,#0
		beq ds 
		movs r0,r0,lsr #1
		adc r6,r6,#0
		cmp r6,#0
		beq nset
		str	r3,[r2]	   	; clear the bit -> turn on the LED
nset	mov r3,r3,lsr #1
		b floop

ds
		POP {r3-r6,pc}

;	button subroutine
;	return index of button pressed, negative if long pressed
; 	parameter: 
; 	none
;	output:
;	
;
button 
	PUSH{r4-r5,LR}
buttonIni
	ldr r2,=IO1PIN	; get mem address
	ldr r3,=0		; nothing
	ldr r4,=0;
buttonRead
	ldr r0,[r2]	; get memory
buttonGetBits
	mvn r0,r0
	lsr r0,#20		; right shift 20
	ldr r1,=0xF		; mask
	and r0,r1	; get bits
	cmp r0,#0		; if has input
	beq butNoIn
	cmp r4,#1		; if already pressed
	ble	butNew
	cmp r3,r0		; if input same
	bne finDiff
	ldr r4,=8
	b fin
	
butNew
	mov r3,r0		; store copy
	add r4,r4,#1	; add counter
	
wait 	ldr r5,=4000000
waitl	subs r5,r5,#1
		bne  waitl
	b buttonRead
	
butNoIn
	cmp r4,#0		; if already have input
	beq buttonIni
	
finDiff
	mov r0,r3	
fin	
	cmp r0,#0x1	; if P.20
	bne P21
	ldr r0,=20
P21	cmp r0,#0x2	; if P.21
	bne P22
	ldr r0,=21
	;b buttonIn
P22	cmp r0,#0x4	; if P.22
	bne P23
	ldr r0,=22
P23 cmp r0,#0x8	; if P.23
	bne checklong
	ldr r0,=23
checklong
	cmp r4,#8
	blt endBut
	neg r0,r0
endBut
	cmp r0,#0
	beq buttonIni
	POP {r4-r5,PC}
	END