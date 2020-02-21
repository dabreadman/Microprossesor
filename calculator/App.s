		;AREA	reset, CODE, READONLY
	AREA	AsmTemplate, CODE, READONLY

	IMPORT	main

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
loop	
		bl button	; get input
		
		
bn20	cmp r0,#-20	; if long P20 clearall
		bne bn21	
		b ini
bn21	cmp r0,#-21	; if long P21 clear last
		bne b22
		b inic
		
b22		cmp r0,#22	; if P22 n-
		bne	b23
		sub r5,r5,#1	; n-
		b numEnd
		
b23		cmp r0,#23		; if P23 n+
		bne b20
		add r5,r5,#1	; n+
		b numEnd
		
substract
		cmp r6,#2		; if P20 -
		bne plus
		sub r4,r4,r5	; sum-=cur
		mov r0,r4		; mov for display
		ldr r5,=0		; clear cur

plus
		cmp r6,#1		; if P21 +
		bne ini
		add r4,r4,r5	; sum+=cur
		mov r0,r4		; mov for display
		ldr r5,=0		; clear cur
		
b20
		cmp r0,#20		; if P20 -
		bne b21
		ldr r6,=2		; set op = -
b21
		cmp r0,#21		; if P21 +
		bne ini
		ldr r6,=1		; set op = +
		
		mov r0,r4		; mov for display
		b endloop
		
numEnd
	mov r0,r5	; get cur into r0 for display
endloop
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

		cmp r0,#0
		bne fs 
		ldr r0,=0xf
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
		
		
;	wait subrotuine
;	wait for a certain time
;	parameter:
;	R0: time to wait
;	output: none
		
;wait 	ldr r0,=4000000
;waitl	subs r0,r0,#1
		;bne  waitl
		;bx lr

;
;
;
;
;


button 
	PUSH{r4-r5,LR}
buttonIni
	ldr r2,=IO1PIN	; get mem address
	ldr r3,=0		; nothing
buttonRead
	ldr r0,[r2]	; get memory
buttonGetBits
	mvn r0,r0
	lsr r0,#20		; right shift 20
	ldr r1,=0xF		; mask
	and r0,r1	; get bits
	cmp r0,#0		; if has input
	beq butNoIn
	cmp r4,#0		; if already pressed
	beq	butNew
	cmp r3,r1		; if input same
	bne finDiff
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
	POP {r4-r5,PC}
	END