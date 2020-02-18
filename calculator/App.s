	AREA	RESET, CODE, READONLY
	;IMPORT	main

; sample program makes the 4 LEDs P1.16, P1.17, P1.18, P1.19 go on and off in sequence
; (c) Mike Brady, 2011 -- 2019.

	;EXPORT	start
start
IO1DIR	EQU	0xE0028018
IO1SET	EQU	0xE0028014
IO1CLR	EQU	0xE002801C
IO1PIN  EQU     0xE0028010
	
;	TODO
; 	get decimal representation from hex
;   get binary representation using TABLE
; 	calls flash subroutine
	
;;delay for about a half second
;ds	ldr	r4,=8000000
;dloop	subs	r4,r4,#1
	;bne	dloop



l1
	bl button
	cmp r0,#0	; if no input
	beq l1
	mov r5,r0
	b l1
	
	;ldr r4,#0	; sum
	;ldr r6,#0	; check if input started
	;ldr r7,#0	; stored operand
	;ldr r8,#0	; operator

;sloop
	;cmp r6,#1	; if input ended
	;beq endin
;loop	
	;ldr r5,#0	; current number
	;bl button
	;cmp r0,#19	; if have input
	;beq sloop	
	
;operands
;n+	
	;cmp r0,#23	; if n+
	;bne n-
	;add r5,r5,#1	; n++
	;b timer
	
;n-	
	;cmp r0,#22	; if n-
	;bne operators
	;b timer

;operators
;addi	
	;cmp r0,#21	; if +
	;bne minus
	;ldr r8,#1	; set operator to +
	;b loop
;minus	
	;cmp r0,#20	; if -
	;bne clearc
	;ldr r8,#2	; set operator to -
	;b timer
;clearc	
	;cmp r0,#-20	; if clear curr
	;bne cleara
	;b timer
;cleara	
	;cmp r0,#-21	; if clear all
	;b timer
	
;timer
	;ldr	r1,=4000000	; wait for 0.5 second for input
;tloop	subs	r1,r1,#1
	;bne	tloop
	;b loop
	
;endin	
	;ldr r6,#0	; end input
	;cmp r8,#0	; if operator
	;beq setop
	;cmp r8,#1	; if +
	;bne min
	;add r4,r5,r4	; sum+= operand
	;ldr r8,#0	; reset operator
	;b loop
;min	cmp r8,#2	; if -
	;bne loop
	;sub r4,r4,r5	; sum-= operand
	;ldr r8,#0	; reset operator
	;b loop
	
;setop	
	;mov r4, r5	; move operand
	;b loop
			
stop	B	stop

;  	button subroutine
;	Reads the memory and determine the input
;	Returns the input index
;	parameter:
;	none
;	returns
; 	R0: Index

button
	PUSH {r4-r5,LR}
	ldr r5,=0	; not pressed
extract	ldr r0,=IO1PIN	; loads memory
	ldr r0,[r0]	
	lsr r0,#20	; shift to right location
	ldr r1,=0xf
	and r0,r0,r1 	; clear other bits
	cmp r0,#0	; if has input
	beq fin
	;cmp r5,#0	; if not sure long press
	;bgt long
	mov r3, r0	; store a copy
	
;delay for a quarter second
;ds	ldr	r4,=2000000
;dloop	subs	r4,r4,#1
	;bne	dloop
	;b extract

;long	cmp r0,r3	; if same(holding)
	;bne finRE
	;cmp r5,#8	; if
	;bge finLong
	;add r5,r5,#1	; increment counter
	;b ds


;finRE	mov r0,r3	; revert input	
	;b fin
	
;finLong mvn r0,r0	; invert
	;add r0,r0,#1	; +1
fin	
	mvn r0,r0
	POP {r4,r5,PC}


;
;	flash subroutine
;	Show the binary representation with LED flashing	
;	parameter: 
;	 R0: binary representation
;	output:
;	 none

flash   PUSH {r3-r5,lr}
		ldr	r1,=IO1DIR
		ldr	r2,=0x000f0000	;select P1.19--P1.16
		str	r2,[r1]		;make them outputs
		ldr	r1,=IO1SET
		str	r2,[r1]		;set them to turn the LEDs off
		ldr	r2,=IO1CLR
		
; r1 points to the SET register
; r2 points to the CLEAR register
	
		ldr r5,=0x000080000	; end when the mask reaches this value
fs		ldr r3,=0x000080000	; start with P1.16.
floop		
		ldr r4,=0		; check if bit set
		cmp r0,#0
		beq ledE
		movs r0,r0,lsr #1	; check if bit set
		adc r4,r4,#0		
		cmp r4,#0		; if set
		beq floop
		str r3,[r2]	   	; clear the bit -> turn on the LED
		mov r3,r3,lsr #1	; next bit
		b floop

		
ledE
		POP {r3-r5,pc}
			
NUMBER DCD 0x00000419

	END