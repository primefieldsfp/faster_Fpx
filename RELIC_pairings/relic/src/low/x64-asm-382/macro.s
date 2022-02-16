/*
 * RELIC is an Efficient LIbrary for Cryptography
 * Copyright (c) 2017 RELIC Authors
 *
 * This file is part of RELIC. RELIC is legal property of its developers,
 * whose names are not listed here. Please refer to the COPYRIGHT file
 * for contact information.
 *
 * RELIC is free software; you can redistribute it and/or modify it under the
 * terms of the version 2.1 (or later) of the GNU Lesser General Public License
 * as published by the Free Software Foundation; or version 2.0 of the Apache
 * License as published by the Apache Software Foundation. See the LICENSE files
 * for more details.
 *
 * RELIC is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the LICENSE files for more details.
 *
 * You should have received a copy of the GNU Lesser General Public or the
 * Apache License along with RELIC. If not, see <https://www.gnu.org/licenses/>
 * or <https://www.apache.org/licenses/>.
 */

#include "relic_fp_low.h"

/**
 * @file
 *
 * Implementation of low-level prime field multiplication.
 *
 * @version $Id: macros.s 88 2009-09-06 21:27:19Z dfaranha, modified by plonga $
 * @ingroup fp
 */

// Select algorithms using Karatsuba and MULX instructions (AAPARENTLY IT IS NOT MEANINGFULLY FASTER)
//#define USE_KARATSUBA
//#define USE_MULX


#if FP_PRIME == 381
#define P0	0xB9FEFFFFFFFFAAAB
#define P1	0x1EABFFFEB153FFFF
#define P2	0x6730D2A0F6B0F624
#define P3	0x64774B84F38512BF
#define P4	0x4B1BA7B6434BACD7
#define P5	0x1A0111EA397FE69A
#define U0	0x89F3FFFCFFFCFFFD
#else
#define P0	0x004E000000000013
#define P1	0x09480097801382BE
#define P2	0xA6E58DBE43002A06
#define P3	0x6F82CEFBE47879BB
#define P4	0x2D996CC179C6D166
#define P5	0x24009015183F9489
#define U0	0xDF615E50D79435E5
#endif

.text

.macro ADD1 i j
	movq	8*\i(%rsi), %r10
	adcq	$0, %r10
	movq	%r10, 8*\i(%rdi)
	.if \i - \j
		ADD1 "(\i + 1)" \j
	.endif
.endm

.macro ADDN i j
	movq	8*\i(%rdx), %r11
	adcq	8*\i(%rsi), %r11
	movq	%r11, 8*\i(%rdi)
	.if \i - \j
		ADDN "(\i + 1)" \j
	.endif
.endm

.macro SUB1 i j
	movq	8*\i(%rsi),%r10
	sbbq	$0, %r10
	movq	%r10,8*\i(%rdi)
	.if \i - \j
		SUB1 "(\i + 1)" \j
	.endif
.endm

.macro SUBN i j
	movq	8*\i(%rsi), %r8
	sbbq	8*\i(%rdx), %r8
	movq	%r8, 8*\i(%rdi)
	.if \i - \j
		SUBN "(\i + 1)" \j
	.endif
.endm

.macro DBLN i j
	movq	8*\i(%rsi), %r8
	adcq	%r8, %r8
	movq	%r8, 8*\i(%rdi)
	.if \i - \j
		DBLN "(\i + 1)" \j
	.endif
.endm

#ifndef USE_KARATSUBA

.macro MULN i, j, k, C, R0, R1, R2, A, B
	.if \j > \k
		movq	8*\i(\A), %rax
		mulq	8*\j(\B)
		addq	%rax    , \R0
		adcq	%rdx    , \R1
		adcq	$0      , \R2
		MULN	"(\i + 1)", "(\j - 1)", \k, \C, \R0, \R1, \R2, \A, \B
	.else
		movq	8*\i(\A), %rax
		mulq	8*\j(\B)
		addq	%rax    , \R0
		movq	\R0     , 8*(\i+\j)(\C)
		adcq	%rdx    , \R1
		adcq	$0      , \R2
	.endif
.endm

.macro FP_MULN_LOW C, R0, R1, R2, A, B
	movq 	0(\A),%rax
	mulq 	0(\B)
	movq 	%rax ,0(\C)
	movq 	%rdx ,\R0

	xorq 	\R1,\R1
	xorq 	\R2,\R2
	MULN 	0, 1, 0, \C, \R0, \R1, \R2, \A, \B
	xorq 	\R0,\R0
	MULN	0, 2, 0, \C, \R1, \R2, \R0, \A, \B
	xorq 	\R1,\R1
	MULN	0, 3, 0, \C, \R2, \R0, \R1, \A, \B
	xorq 	\R2,\R2
	MULN	0, 4, 0, \C, \R0, \R1, \R2, \A, \B
	xorq 	\R0,\R0
	MULN	0, 5, 0, \C, \R1, \R2, \R0, \A, \B
	xorq 	\R1,\R1
	MULN	1, 5, 1, \C, \R2, \R0, \R1, \A, \B
	xorq 	\R2,\R2
	MULN	2, 5, 2, \C, \R0, \R1, \R2, \A, \B
	xorq 	\R0,\R0
	MULN	3, 5, 3, \C, \R1, \R2, \R0, \A, \B
	xorq 	\R1,\R1
	MULN	4, 5, 4, \C, \R2, \R0, \R1, \A, \B

	movq	40(\A),%rax
	mulq	40(\B)
	addq	%rax  ,\R0
	movq	\R0   ,80(\C)
	adcq	%rdx  ,\R1
	movq	\R1   ,88(\C)
.endm

.macro MULD i, j, k, C, R0, R1, R2, A, B
		movq	8*\i(\A), %rax
		mulq	\B
		addq	%rax, \R0
	.if \j < \k
		movq	\R0 , 8*(\i+\j)(\C)
	.endif
		adcq	%rdx, \R1
		adcq	$0  , \R2
.endm

.macro FP_MULD_LOW C, R0, R1, R2, A, B0, B1, B2, B3, B4, B5
	movq 	0(\A),%rax
	mulq 	\B0
	movq 	%rax ,0(\C)
	movq 	%rdx ,\R0

	xorq 	\R1,\R1
	xorq 	\R2,\R2
	MULD 	0, 1, 0, \C, \R0, \R1, \R2, \A, \B1
	MULD 	1, 0, 9, \C, \R0, \R1, \R2, \A, \B0
	xorq 	\R0,\R0
	MULD	0, 2, 0, \C, \R1, \R2, \R0, \A, \B2
	MULD	1, 1, 0, \C, \R1, \R2, \R0, \A, \B1
	MULD	2, 0, 9, \C, \R1, \R2, \R0, \A, \B0
	xorq 	\R1,\R1
	MULD	0, 3, 0, \C, \R2, \R0, \R1, \A, \B3
	MULD	1, 2, 0, \C, \R2, \R0, \R1, \A, \B2
	MULD	2, 1, 0, \C, \R2, \R0, \R1, \A, \B1
	MULD	3, 0, 9, \C, \R2, \R0, \R1, \A, \B0
	xorq 	\R2,\R2
	MULD	0, 4, 0, \C, \R0, \R1, \R2, \A, \B4
	MULD	1, 3, 0, \C, \R0, \R1, \R2, \A, \B3
	MULD	2, 2, 0, \C, \R0, \R1, \R2, \A, \B2
	MULD	3, 1, 0, \C, \R0, \R1, \R2, \A, \B1
	MULD	4, 0, 9, \C, \R0, \R1, \R2, \A, \B0
	xorq 	\R0,\R0
	MULD	0, 5, 0, \C, \R1, \R2, \R0, \A, \B5
	MULD	1, 4, 0, \C, \R1, \R2, \R0, \A, \B4
	MULD	2, 3, 0, \C, \R1, \R2, \R0, \A, \B3
	MULD	3, 2, 0, \C, \R1, \R2, \R0, \A, \B2
	MULD	4, 1, 0, \C, \R1, \R2, \R0, \A, \B1
	MULD	5, 0, 9, \C, \R1, \R2, \R0, \A, \B0
	xorq 	\R1,\R1
	MULD	1, 5, 0, \C, \R2, \R0, \R1, \A, \B5
	MULD	2, 4, 0, \C, \R2, \R0, \R1, \A, \B4
	MULD	3, 3, 0, \C, \R2, \R0, \R1, \A, \B3
	MULD	4, 2, 0, \C, \R2, \R0, \R1, \A, \B2
	MULD	5, 1, 9, \C, \R2, \R0, \R1, \A, \B1
	xorq 	\R2,\R2
	MULD	2, 5, 0, \C, \R0, \R1, \R2, \A, \B5
	MULD	3, 4, 0, \C, \R0, \R1, \R2, \A, \B4
	MULD	4, 3, 0, \C, \R0, \R1, \R2, \A, \B3
	MULD	5, 2, 9, \C, \R0, \R1, \R2, \A, \B2
	xorq 	\R0,\R0
	MULD	3, 5, 0, \C, \R1, \R2, \R0, \A, \B5
	MULD	4, 4, 0, \C, \R1, \R2, \R0, \A, \B4
	MULD	5, 3, 9, \C, \R1, \R2, \R0, \A, \B3
	xorq 	\R1,\R1
	MULD	4, 5, 0, \C, \R2, \R0, \R1, \A, \B5
	MULD	5, 4, 9, \C, \R2, \R0, \R1, \A, \B4

	movq	40(\A),%rax
	mulq	\B5
	addq	%rax  ,\R0
	movq	\R0   ,80(\C)
	adcq	%rdx  ,\R1
	movq	\R1   ,88(\C)
.endm

#endif

.macro _RDCN0 i, j, k, R0, R1, R2 A, P
	movq	8*\i(\A), %rax
	mulq	8*\j(\P)
	addq	%rax, \R0
	adcq	%rdx, \R1
	adcq	$0, \R2
	.if \j > 1
		_RDCN0 "(\i + 1)", "(\j - 1)", \k, \R0, \R1, \R2, \A, \P
	.else
		addq	8*\k(\A), \R0
		adcq	$0, \R1
		adcq	$0, \R2
		movq	\R0, %rax
		mulq	%rcx
		movq	%rax, 8*\k(\A)
		mulq	0(\P)
		addq	%rax , \R0
		adcq	%rdx , \R1
		adcq	$0   , \R2
		xorq	\R0, \R0
	.endif
.endm

.macro RDCN0 i, j, R0, R1, R2, A, P
	_RDCN0	\i, \j, \j, \R0, \R1, \R2, \A, \P
.endm

.macro _RDCN1 i, j, k, l, R0, R1, R2 A, P
	movq	8*\i(\A), %rax
	mulq	8*\j(\P)
	addq	%rax, \R0
	adcq	%rdx, \R1
	adcq	$0, \R2
	.if \j > \l
		_RDCN1 "(\i + 1)", "(\j - 1)", \k, \l, \R0, \R1, \R2, \A, \P
	.else
		addq	8*\k(\A), \R0
		adcq	$0, \R1
		adcq	$0, \R2
		movq	\R0, 8*\k(\A)
		xorq	\R0, \R0
	.endif
.endm

.macro RDCN1 i, j, R0, R1, R2, A, P
	_RDCN1	\i, \j, "(\i + \j)", \i, \R0, \R1, \R2, \A, \P
.endm

// r8, r9, r10, r11, r12, r13, r14, r15, rbp, rbx, rsp, //rsi, rdi, //rax, rcx, rdx
.macro FP_RDCN_LOW C, R0, R1, R2, A, P
	xorq	\R1, \R1
	movq	$U0, %rcx

	movq	0(\A), \R0
	movq	\R0  , %rax
	mulq	%rcx
	movq	%rax , 0(\A)
	mulq	0(\P)
	addq	%rax , \R0
	adcq	%rdx , \R1
	xorq    \R2  , \R2
	xorq    \R0  , \R0

	RDCN0	0, 1, \R1, \R2, \R0, \A, \P
	RDCN0	0, 2, \R2, \R0, \R1, \A, \P
	RDCN0	0, 3, \R0, \R1, \R2, \A, \P
	RDCN0	0, 4, \R1, \R2, \R0, \A, \P
	RDCN0	0, 5, \R2, \R0, \R1, \A, \P
	RDCN1	1, 5, \R0, \R1, \R2, \A, \P
	RDCN1	2, 5, \R1, \R2, \R0, \A, \P
	RDCN1	3, 5, \R2, \R0, \R1, \A, \P
	RDCN1	4, 5, \R0, \R1, \R2, \A, \P
	RDCN1	5, 5, \R1, \R2, \R0, \A, \P
	addq	8*11(\A), \R2
	movq	\R2, 8*11(\A)

	movq	48(\A), %r11
	movq	56(\A), %r12
	movq	64(\A), %r13
	movq	72(\A), %r14
	movq	80(\A), %r15
	movq	88(\A), %rcx

	subq	p0(%rip), %r11
	sbbq	p1(%rip), %r12
	sbbq	p2(%rip), %r13
	sbbq	p3(%rip), %r14
	sbbq	p4(%rip), %r15
	sbbq	p5(%rip), %rcx

	cmovc	48(\A), %r11
	cmovc	56(\A), %r12
	cmovc	64(\A), %r13
	cmovc	72(\A), %r14
	cmovc	80(\A), %r15
	cmovc	88(\A), %rcx
	movq	%r11,0(\C)
	movq	%r12,8(\C)
	movq	%r13,16(\C)
	movq	%r14,24(\C)
	movq	%r15,32(\C)
	movq	%rcx,40(\C)
.endm


#ifdef USE_KARATSUBA

//////////////////////////////////////////////////////////////////////////////////////////////////////////
// 
// The routines below combine Karatsuba with other techniques to optimize the field multiplication

 //////////////////*************** NOTE: only a negligible improvement detected when using Karatsuba + schoolbook + MULX. Comba performs relatively well (because of relatively small field size?)

#ifdef USE_MULX
    
///////////////////////////////////////////////////////////////// MACRO
// Schoolbook integer multiplication
// Inputs:  memory pointers M0 and M1
// Outputs: memory pointer C and regs T1, T2, T0
// Temps:   regs T0:T6
/////////////////////////////////////////////////////////////////
.macro MUL192_SCHOOL i, j, k, M0, M1, C, T0, T1, T2, T3, T4, T5, T6
    movq   \i(\M0), %rdx
    mulxq  \j(\M1), \T1, \T0        // T0:T1 = A0*B0
    movq   \T1, \k(\C)              // C0_final
    mulxq  (\j+8)(\M1), \T2, \T1    // T1:T2 = A0*B1
    xorq   %rax, %rax   
    adoxq  \T2, \T0        
    mulxq  (\j+16)(\M1), \T3, \T2   // T2:T3 = A0*B2
    adoxq  \T3, \T1
           
    movq   (\i+8)(\M0), %rdx
    mulxq  \j(\M1), \T4, \T3        // T3:T4 = A1*B0
    adoxq  %rax, \T2 
    xorq   %rax, %rax   
    mulxq  (\j+8)(\M1), \T6, \T5    // T5:T6 = A1*B1
    adoxq  \T0, \T4
    movq   \T4, (\k+8)(\C)          // C1_final  
    adcx   \T6, \T3      
    mulxq  (\j+16)(\M1), \T0, \T6   // T6:T0 = A1*B2 
    adoxq  \T1, \T3  
    adcx   \T0, \T5     
    adcx   %rax, \T6 
    adoxq  \T2, \T5	
    
    movq   (\i+16)(\M0), %rdx
    mulxq  \j(\M1), \T0, \T1        // T1:T0 = A2*B0
    adoxq  %rax, \T6
    xorq   %rax, %rax 
    mulxq  (\j+8)(\M1), \T4, \T2    // T2:T4 = A2*B1
    adoxq  \T3, \T0   
    movq   \T0, (\k+16)(\C)         // C2_final 
    adcx   \T5, \T1    
    mulxq  (\j+16)(\M1), \T3, \T0   // T0:T3 = A2*B2
    adcx   \T6, \T2  
    adcx   %rax, \T0
    adoxq  \T4, \T1                 // T1 <- C3_final
    adoxq  \T3, \T2                 // T2 <- C4_final
    adoxq  %rax, \T0                // T0 <- C5_final
.endm

#endif

//*****************************************************************************
//  384-bit multiplication using Karatsuba (one level), schoolbook (one level)
//  Input operands A and B should be in the range [0, 2^383)
//  Output pointer C
//***************************************************************************** 
.macro FP_MULN_LOW C, R0, R1, R2, A, B
    // r8-r10 <- AH + AL, rax <- mask
    xorq   %rax, %rax
    movq   (\A), %r8
    movq   8(\A), %r9
    movq   16(\A), %r10
    addq   24(\A), %r8
    adcq   32(\A), %r9
    adcq   40(\A), %r10
    sbbq   $0, %rax

    // r11-r13 <- BH + BL, rbx <- mask
    xorq   %rbx, %rbx
    movq   (\B), %r11
    movq   8(\B), %r12
    movq   16(\B), %r13
    subq   $144, %rsp
    addq   24(\B), %r11
    adcq   32(\B), %r12
    adcq   40(\B), %r13
    sbbq   $0, %rbx
    movq   %r8, (%rsp)
    movq   %r9, 8(%rsp)
    movq   %r10, 16(%rsp)
    movq   %r11, 24(%rsp)
    movq   %r12, 32(%rsp)
    movq   %r13, 40(%rsp)
    
    // r11-r13 <- masked (BH + BL)
    andq   %rax, %r11
    andq   %rax, %r12
    andq   %rax, %r13

    // r8-r10 <- masked (AH + AL)
    andq   %rbx, %r8
    andq   %rbx, %r9
    andq   %rbx, %r10

    // r8-r10 <- masked (AH + AL) + masked (AH + AL)
    addq   %r11, %r8
    adcq   %r12, %r9
    adcq   %r13, %r10
	
    // 48(rsp) <- (AH+AL) x (BH+BL), low part 
    MUL192_SCHOOL  0, 24, 48, %rsp, %rsp, %rsp, %r15, %rbx, %rbp, %r11, %r12, %r13, %r14 
    movq   %rbx, 72(%rsp)         
    movq   %rbp, 80(%rsp)         
    movq   %r15, 88(%rsp)

    // 96(rsp) <- AL x BL
    MUL192_SCHOOL  0, 0, 96, \A, \B, %rsp, %r15, %rbx, %rbp, %r11, %r12, %r13, %r14 
    movq   %rbx, 120(%rsp)         
    movq   %rbp, 128(%rsp)         
    movq   %r15, 136(%rsp)     

    // (rsp), rbx, rbp, r15 <- AH x BH 
    MUL192_SCHOOL  24, 24, 0, \A, \B, %rsp, %r15, %rbx, %rbp, %r11, %r12, %r13, %r14
    
    // r8-r10 <- (AH+AL) x (BH+BL), final step
    addq   72(%rsp), %r8
    adcq   80(%rsp), %r9
    adcq   88(%rsp), %r10
    
    // r11-r13, r8-r10 <- (AH+AL) x (BH+BL) - ALxBL
    movq   48(%rsp), %r11
    movq   56(%rsp), %r12
    movq   64(%rsp), %r13
    subq   96(%rsp), %r11
    sbbq   104(%rsp), %r12
    sbbq   112(%rsp), %r13
    sbbq   120(%rsp), %r8
    sbbq   128(%rsp), %r9
    sbbq   136(%rsp), %r10
    
    // r11-r13, r8-r10 <- (AH+AL) x (BH+BL) - ALxBL - AHxBH
    movq   (%rsp), %rcx
    movq   8(%rsp), %rsi
    movq   16(%rsp), %rdx
    subq   %rcx, %r11
    sbbq   %rsi, %r12
    sbbq   %rdx, %r13
    sbbq   %rbx, %r8
    sbbq   %rbp, %r9
    sbbq   %r15, %r10
    
    addq   120(%rsp), %r11
    adcq   128(%rsp), %r12
    adcq   136(%rsp), %r13
    addq   $144, %rsp
    movq   %r11, 24(\C)    // Result C3-C5
    movq   %r12, 32(\C)
    movq   %r13, 40(\C)
    movq   -48(%rsp), %r11
    movq   -40(%rsp), %r12
    movq   -32(%rsp), %r13
    adcq   %rcx, %r8 
    adcq   %rsi, %r9
    adcq   %rdx, %r10
    movq   %r11, (\C)     // Result C0-C2
    movq   %r12, 8(\C)
    movq   %r13, 16(\C)
    movq   %r8, 48(\C)    // Result C6-C8
    movq   %r9, 56(\C) 
    movq   %r10, 64(\C)
    adcq   $0, %rbx
    adcq   $0, %rbp
    adcq   $0, %r15
    movq   %rbx, 72(\C)   // Result C9-C11
    movq   %rbp, 80(\C) 
    movq   %r15, 88(\C)
.endm

#endif