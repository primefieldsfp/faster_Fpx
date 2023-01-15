  
.intel_syntax noprefix

// Registers that are used for parameter passing:
#define reg_p1  rsi
#define reg_p2  rdx
#define reg_p3  rdi


.data

u0:
.quad	0x6EFA1180A5FE67FD   

pdiv4:
.quad   0xC000000000000000
.quad   0x284F44636E2FF4AA
.quad   0xBB98EF41DBA364C0
.quad   0x33F2D7181C6EB4F4
.quad   0xD89BA16FDF06283C
.quad   0x0CBA8040F804242E
.quad   0xB2E2B21257461FA3
.quad   0xFF3B7CAD3E703B3D
.quad   0x055555BFFFCE72A6


.text

///////////////////////////////////////////////////////////////// MACRO
// z = a x bi + z
// Inputs: base memory pointer M1 (a),
//         bi pre-stored in rdx,
//         accumulator z in [Z0:Z8]
// Output: [Z0:Z8]
// Temps:  regs T0:T1
/////////////////////////////////////////////////////////////////
.macro MULADD64x512 M1, Z0, Z1, Z2, Z3, Z4, Z5, Z6, Z7, Z8, T0, T1, C
	xor    \C, \C
    mulx   \T0, \T1, \M1     // A0*B0
    adox   \Z0, \T1
    adox   \Z1, \T0 
    mulx   \T0, \T1, 8\M1    // A0*B1
    adcx   \Z1, \T1
    adox   \Z2, \T0    
    mulx   \T0, \T1, 16\M1   // A0*B2
    adcx   \Z2, \T1
    adox   \Z3, \T0
    mulx   \T0, \T1, 24\M1   // A0*B3          
    adcx   \Z3, \T1
    adox   \Z4, \T0
    mulx   \T0, \T1, 32\M1   // A0*B4          
    adcx   \Z4, \T1
    adox   \Z5, \T0
    mulx   \T0, \T1, 40\M1   // A0*B5          
    adcx   \Z5, \T1
    adox   \Z6, \T0
    mulx   \T0, \T1, 48\M1   // A0*B6               
    adcx   \Z6, \T1
    adox   \Z7, \T0
    mulx   \T0, \T1, 56\M1   // A0*B7         
    adcx   \Z7, \T1
    adox   \Z8, \T0
    adc    \Z8, 0 
.endm

///////////////////////////////////////////////////////////////// MACRO
// z = a x b + c x d (mod p)
// Inputs: base memory pointers M0 (a,c), M1 (b,d)
//         bi pre-stored in rdx,
//         accumulator z in [Z0:Z7], pre-stores a0 x b
// Output: [Z0:Z7]
// Temps:  regs T0:T1
/////////////////////////////////////////////////////////////////
.macro FPDBLMUL512x512 M00, M01, M10, M11, Z0, Z1, Z2, Z3, Z4, Z5, Z6, Z7, Z8, T0, T1           
    mov    rdx, \M11    
    MULADD64x512 \M01, \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \T0, \T1, \T0 
    // [Z1:Z8] <- z = ((z0 x u0 mod 2^64) x p509 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   \T0, rdx, \Z0            // rdx <- z0
    MULADD64x512 [rip+p0], \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \T0, \T1, \T0
    
    // [Z1:Z8 , Z0] <- z = a01 x a1 + z
    mov    rdx, 8\M10
    MULADD64x512 \M00, \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \T0, \T1, \Z0           
    mov    rdx, 8\M11    
    MULADD64x512 \M01, \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \T0, \T1, \T0
    // [Z2:Z8 , Z0] <- z = ((z0 x u0 mod 2^64) x p509 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   \T0, rdx, \Z1            // rdx <- z0
    MULADD64x512 [rip+p0], \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \T0, \T1, \T0
    
    // [Z2:Z8 , Z0:Z1] <- z = a02 x a1 + z  
    mov    rdx, 16\M10
    MULADD64x512 \M00, \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \T0, \T1, \Z1          
    mov    rdx, 16\M11    
    MULADD64x512 \M01, \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \T0, \T1, \T0 
    // [Z3:Z8 , Z0:Z1] <- z = ((z0 x u0 mod 2^64) x p509 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   \T0, rdx, \Z2            // rdx <- z0
    MULADD64x512 [rip+p0], \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \T0, \T1, \T0
    
    // [Z3:Z8 , Z0:Z2] <- z = a03 x a1 + z
    mov    rdx, 24\M10
    MULADD64x512 \M00, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \T0, \T1, \Z2          
    mov    rdx, 24\M11    
    MULADD64x512 \M01, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \T0, \T1, \T0
    // [Z4:Z8 , Z0:Z2] <- z = ((z0 x u0 mod 2^64) x p509 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   \T0, rdx, \Z3            // rdx <- z0
    MULADD64x512 [rip+p0], \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \T0, \T1, \T0
    
    // [Z4:Z8 , Z0:Z3] <- z = a04 x a1 + z 
    mov    rdx, 32\M10
    MULADD64x512 \M00, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \T0, \T1, \Z3          
    mov    rdx, 32\M11    
    MULADD64x512 \M01, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \T0, \T1, \T0
    // [Z5:Z8 , Z0:Z3] <- z = ((z0 x u0 mod 2^64) x p509 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   \T0, rdx, \Z4            // rdx <- z0
    MULADD64x512 [rip+p0], \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \T0, \T1, \T0
    
    // [Z5:Z8 , Z0:Z4] <- z = a05 x a1 + z    
    mov    rdx, 40\M10
    MULADD64x512 \M00, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \T0, \T1, \Z4          
    mov    rdx, 40\M11    
    MULADD64x512 \M01, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \T0, \T1, \T0
    // [Z6:Z8 , Z0:Z4] <- z = ((z0 x u0 mod 2^64) x p509 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   \T0, rdx, \Z5            // rdx <- z0
    MULADD64x512 [rip+p0], \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \T0, \T1, \T0
    
    // [Z6:Z8 , Z0:Z5] <- z = a06 x a1 + z  
    mov    rdx, 48\M10
    MULADD64x512 \M00, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \T0, \T1, \Z5          
    mov    rdx, 48\M11    
    MULADD64x512 \M01, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \T0, \T1, \T0
    // [Z7, Z0:Z5] <- z = ((z0 x u0 mod 2^64) x p509 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   \T0, rdx, \Z6            // rdx <- z0
    MULADD64x512 [rip+p0], \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \T0, \T1, \T0 
    
    // [Z7:Z8 , Z0:Z6] <- z = a06 x a1 + z  
    mov    rdx, 56\M10
    MULADD64x512 \M00, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \T0, \T1, \Z6          
    mov    rdx, 56\M11    
    MULADD64x512 \M01, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \T0, \T1, \T0
    // [Z8, Z0:Z6] <- z = ((z0 x u0 mod 2^64) x p509 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   \T0, rdx, \Z7            // rdx <- z0
    MULADD64x512 [rip+p0], \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \T0, \T1, \T0     

	// Final correction
    xor    rsi, rsi
	mov    \T0, [rip+p0]
	mov    \T1, [rip+p1]
	mov    \Z7, [rip+p2]
	mov    rcx, [rip+p3]
	mov    rdx, [rip+p4]
	sub    \Z8, \T0
	sbb    \Z0, \T1
	sbb    \Z1, \Z7
	sbb    \Z2, rcx
	sbb    \Z3, rdx
	sbb    \Z4, [rip+p5]
	sbb    \Z5, [rip+p6]
	sbb    \Z6, [rip+p7]
	sbb    rsi, 0
	and    \T0, rsi
	and    \T1, rsi
	and    \Z7, rsi
	and    rcx, rsi
	and    rdx, rsi
	add    \Z8, \T0
	adc    \Z0, \T1
	adc    \Z1, \Z7
	adc    \Z2, rcx
	adc    \Z3, rdx
    setc   cl
    mov    \Z7, [rip+p5]
    mov    \T0, [rip+p6]
    mov    \T1, [rip+p7]
    and    \Z7, rsi
    and    \T0, rsi
    and    \T1, rsi
    bt     rcx, 0
	adc    \Z4, \Z7
    adc    \Z5, \T0
    adc    \Z6, \T1

    mov    [reg_p3], \Z8     
    mov    [reg_p3+8], \Z0 
    mov    [reg_p3+16], \Z1 
    mov    [reg_p3+24], \Z2
    mov    [reg_p3+32], \Z3  
    mov    [reg_p3+40], \Z4 
    mov    [reg_p3+48], \Z5 
    mov    [reg_p3+56], \Z6
.endm

//***********************************************************************
//  Multiplication in GF(p^2), non-complex part
//  Operation: c [reg_p3] = a0 x b0 - a1 x b1
//  Inputs: a = [a1, a0] stored in [reg_p1] 
//          b = [b1, b0] stored in [reg_p2] 
//  Output: c stored in [reg_p3]
//***********************************************************************
.global fp2_mulm_subpart
fp2_mulm_subpart:   
    push   r12 
    mov    rcx, reg_p2
	
	// [reg_p3_0:reg_p3_48] <- p - b1
	mov    r8, [rip+p0]  
	mov    r9, [rip+p0+8]   
	mov    r10, [rip+p0+16]       
	mov    r11, [rip+p0+24]
	mov    r12, [rip+p0+32] 
	mov    rax, [rcx+64]
	mov    rdx, [rcx+72]           
	sub    r8, rax
    push   r13 
	sbb    r9, rdx
	mov    rax, [rcx+80]
	mov    rdx, [rcx+88]
	sbb    r10, rax
    push   r14 
	sbb    r11, rdx
	mov    rax, [rcx+96]
	mov    rdx, [rcx+104]
	mov    r13, [rip+p0+40]
	mov    r14, [rip+p0+48]
	mov    [reg_p3], r8
	mov    [reg_p3+8], r9
	sbb    r12, rax
    push   r15 
	sbb    r13, rdx
	mov    rax, [rcx+112]
	mov    rdx, [rcx+120]
	mov    r15, [rip+p0+56]
	sbb    r14, rax 
	sbb    r15, rdx 
	mov    [reg_p3+16], r10
    
    // [r8:r15, rax] <- z = a0 x b00 - a1 x b10
    mov    rdx, [rcx]
    mulx   r9, r8, [reg_p1] 
	mov    [reg_p3+24], r11      
    xor    rax, rax 
    mulx   r10, r11, [reg_p1+8] 
	mov    [reg_p3+32], r12     
    adcx   r9, r11        
    mulx   r11, r12, [reg_p1+16]
	mov    [reg_p3+40], r13     
    adcx   r10, r12        
    mulx   r12, r13, [reg_p1+24] 
	mov    [reg_p3+48], r14     
    adcx   r11, r13       
    mulx   r13, r14, [reg_p1+32]
	mov    [reg_p3+56], r15 
    adcx   r12, r14      
    mulx   r14, rax, [reg_p1+40]    
    push   rbx 
    adcx   r13, rax      
    mulx   r15, rax, [reg_p1+48]  
    push   rbp    
    adcx   r14, rax      
    mulx   rax, rbx, [reg_p1+56]
    adcx   r15, rbx     
    adc    rax, 0 

	FPDBLMUL512x512 [reg_p1], [reg_p1+64], [rcx], [reg_p3], r8, r9, r10, r11, r12, r13, r14, r15, rax, rbx, rbp
	              
    pop    rbp
    pop    rbx
    pop    r15
    pop    r14
    pop    r13
    pop    r12
    ret

//***********************************************************************
//  Multiplication in GF(p^2), complex part
//  Operation: c [reg_p3] = a0 x b1 + a1 x b0
//  Inputs: a = [a1, a0] stored in [reg_p1] 
//          b = [b1, b0] stored in [reg_p2] 
//  Output: c stored in [reg_p3]
//***********************************************************************
.global fp2_mulm_addpart
fp2_mulm_addpart: 
    mov    rcx, reg_p2
    
    // [r8:r15, rax] <- z = a0 x b10 + a1 x b00
    mov    rdx, [rcx]
    mulx   r9, r8, [reg_p1+64]     // a0 x b10
    xor    rax, rax     
    push   r12 
    mulx   r10, r11, [reg_p1+72]  
    push   r13  
    adcx   r9, r11        
    mulx   r11, r12, [reg_p1+80]  
    push   r14  
    adcx   r10, r12        
    mulx   r12, r13, [reg_p1+88]  
    push   r15   
    adcx   r11, r13       
    mulx   r13, r14, [reg_p1+96] 
    push   rbx    
    adcx   r12, r14      
    mulx   r14, r15, [reg_p1+104] 
    push   rbp 
    adcx   r13, r15      
    mulx   r15, rbp, [reg_p1+112] 
    adcx   r14, rbp       
    mulx   rax, rbx, [reg_p1+120]
    adcx   r15, rbx     
    adc    rax, 0 

	FPDBLMUL512x512 [reg_p1+64], [reg_p1], [rcx], [rcx+64], r8, r9, r10, r11, r12, r13, r14, r15, rax, rbx, rbp
                        
    pop    rbp
    pop    rbx
    pop    r15
    pop    r14
    pop    r13
    pop    r12
    ret

///////////////////////////////////////////////////////////////// MACRO
// z = z - a x bi
// Inputs: base memory pointer M1 (a),
//         bi pre-stored in rdx,
//         accumulator z in [Z0:Z8]
// Output: [Z0:Z8]
// Temps:  regs T0:T1
/////////////////////////////////////////////////////////////////
.macro MULSUB64x512 M1, Z0, Z1, Z2, Z3, Z4, Z5, Z6, Z7, Z8, T0, T1
    mulx   \T0, \T1, 8\M1    // A0*B1
    sub    \Z1, \T1
    sbb    \Z2, \T0
    mulx   \T0, \T1, 24\M1   // A0*B3          
    sbb    \Z3, \T1
    sbb    \Z4, \T0  
    mulx   \T0, \T1, 40\M1   // A0*B5          
    sbb    \Z5, \T1
    sbb    \Z6, \T0	  
    mulx   \T0, \T1, 56\M1   // A0*B7      
    sbb    \Z7, \T1
    sbb    \Z8, \T0	
    mulx   \T0, \T1, \M1     // A0*B0     
    sub    \Z0, \T1
    sbb    \Z1, \T0  
    mulx   \T0, \T1, 16\M1   // A0*B2
    sbb    \Z2, \T1
    sbb    \Z3, \T0   
    mulx   \T0, \T1, 32\M1   // A0*B4
    sbb    \Z4, \T1
    sbb    \Z5, \T0    
    mulx   \T0, \T1, 48\M1   // A0*B6
    sbb    \Z6, \T1
    sbb    \Z7, \T0 
	sbb    \Z8, 0
.endm

///////////////////////////////////////////////////////////////// MACRO
// z = a x b + c x d (mod p)
// Inputs: base memory pointers M0 (a,c), M1 (b,d)
//         bi pre-stored in rdx,
//         accumulator z in [Z0:Z7], pre-stores a0 x b
// Output: reg_p3
// Temps:  regs T0:T1
/////////////////////////////////////////////////////////////////
.macro FPADDSUBMUL512x512nr M00, M01, M10, M11, Z0, Z1, Z2, Z3, Z4, Z5, Z6, Z7, Z8, T0, T1           
    mov    rdx, \M11    
    MULSUB64x512 \M01, \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \T0, \T1
    mov    [reg_p3], \Z0            // Result c0
    
    // [Z1:Z8 , Z0] <- z = a01 x a1 + z
    xor    \Z0, \Z0 
	bt     \Z8, 63
    sbb    \Z0, 0
    mov    rdx, 8\M10
    MULADD64x512 \M00, \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \T0, \T1, \T0           
    mov    rdx, 8\M11    
    MULSUB64x512 \M01, \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \T0, \T1
    mov    [reg_p3+8], \Z1          // Result c1
    
    // [Z2:Z8 , Z0:Z1] <- z = a02 x a1 + z  
    xor    \Z1, \Z1 
	bt     \Z0, 63
    sbb    \Z1, 0
    mov    rdx, 16\M10
    MULADD64x512 \M00, \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \T0, \T1, \T0          
    mov    rdx, 16\M11    
    MULSUB64x512 \M01, \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \T0, \T1
    mov    [reg_p3+16], \Z2         // Result c2
    
    // [Z3:Z8 , Z0:Z2] <- z = a03 x a1 + z  
    xor    \Z2, \Z2 
	bt     \Z1, 63
    sbb    \Z2, 0
    mov    rdx, 24\M10
    MULADD64x512 \M00, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \T0, \T1, \T0          
    mov    rdx, 24\M11    
    MULSUB64x512 \M01, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \T0, \T1
    mov    [reg_p3+24], \Z3         // Result c3
    
    // [Z4:Z8 , Z0:Z3] <- z = a04 x a1 + z   
    xor    \Z3, \Z3 
	bt     \Z2, 63
    sbb    \Z3, 0
    mov    rdx, 32\M10
    MULADD64x512 \M00, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \T0, \T1, \T0          
    mov    rdx, 32\M11    
    MULSUB64x512 \M01, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \T0, \T1
    mov    [reg_p3+32], \Z4         // Result c4
    
    // [Z5:Z8 , Z0:Z4] <- z = a05 x a1 + z       
    xor    \Z4, \Z4 
	bt     \Z3, 63
    sbb    \Z4, 0
    mov    rdx, 40\M10
    MULADD64x512 \M00, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \T0, \T1, \T0          
    mov    rdx, 40\M11    
    MULSUB64x512 \M01, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \T0, \T1
    mov    [reg_p3+40], \Z5         // Result c5
    
    // [Z6:Z8 , Z0:Z5] <- z = a06 x a1 + z        
    xor    \Z5, \Z5 
	bt     \Z4, 63
    sbb    \Z5, 0
    mov    rdx, 48\M10
    MULADD64x512 \M00, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \T0, \T1, \T0          
    mov    rdx, 48\M11    
    MULSUB64x512 \M01, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \T0, \T1
    mov    [reg_p3+48], \Z6         // Result c6
    
    // [Z7:Z8 , Z0:Z6] <- z = a06 x a1 + z        
    xor    \Z6, \Z6 
	bt     \Z5, 63
    sbb    \Z6, 0 
    mov    rdx, 56\M10
    MULADD64x512 \M00, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \T0, \T1, \T0          
    mov    rdx, 56\M11    
    MULSUB64x512 \M01, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \T0, \T1 
    mov    [reg_p3+56], \Z7         // Result c7
    xor    \T1, \T1 
	bt     \Z6, 63
    sbb    \T1, 0                                 
.endm

//***********************************************************************
//  Multiplication in GF(p^2) without reduction, non-complex part
//  Operation: c [reg_p3] = a0 x b0 - a1 x b1
//  Inputs: a = [a1, a0] stored in [reg_p1] 
//          b = [b1, b0] stored in [reg_p2] 
//  Output: c stored in [reg_p3]
//***********************************************************************
.global fp2_muln_subpart
fp2_muln_subpart:   
    push   r12 
    mov    rcx, reg_p2
    
    // [r8:r15, rax] <- z = a0 x b00 - a1 x b10
    mov    rdx, [rcx]
    mulx   r9, r8, [reg_p1]    
    xor    rax, rax 
    mulx   r10, r11, [reg_p1+8]
    adcx   r9, r11        
    mulx   r11, r12, [reg_p1+16]    
    push   r13
    adcx   r10, r12        
    mulx   r12, r13, [reg_p1+24]   
    push   r14
    adcx   r11, r13       
    mulx   r13, r14, [reg_p1+32]   
    push   r15
    adcx   r12, r14      
    mulx   r14, rax, [reg_p1+40]    
    push   rbx 
    adcx   r13, rax      
    mulx   r15, rax, [reg_p1+48]  
    push   rbp    
    adcx   r14, rax      
    mulx   rax, rbx, [reg_p1+56]
    adcx   r15, rbx     
    adc    rax, 0 

	FPADDSUBMUL512x512nr [reg_p1], [reg_p1+64], [rcx], [rcx+64], r8, r9, r10, r11, r12, r13, r14, r15, rax, rbx, rbp                                    

    // Final correction if partial result < 0
    mov    r15, [rip+p0]
    mov    rbx, [rip+p1]
    mov    rcx, [rip+p2]
    mov    rdx, [rip+p3]
    mov    rsi, [rip+p4]
    and    r15, rbp
    and    rbx, rbp
    and    rcx, rbp
    and    rdx, rbp
    and    rsi, rbp

    add    rax, r15
    adc    r8, rbx
    adc    r9, rcx
    adc    r10, rdx
    adc    r11, rsi
    setc   cl
    
    mov    r15, [rip+p5]
    mov    rbx, [rip+p6]
    mov    rdx, [rip+p7]
    and    r15, rbp
    and    rbx, rbp
    and    rdx, rbp

    bt     rcx, 0
    adc    r12, r15
    adc    r13, rbx
    adc    r14, rdx
	              
    mov    [reg_p3+64], rax     
    mov    [reg_p3+72], r8 
    mov    [reg_p3+80], r9 
    mov    [reg_p3+88], r10
    mov    [reg_p3+96], r11  
    mov    [reg_p3+104], r12
    mov    [reg_p3+112], r13 
    mov    [reg_p3+120], r14
    pop    rbp
    pop    rbx
    pop    r15
    pop    r14
    pop    r13
    pop    r12
    ret

//***********************************************************************
//  Multiplication in GF(p^2) without reduction, non-complex part
//  Operation: c [reg_p3] = a0 x b0 - a1 x b1
//  Inputs: a = [a1, a0] stored in [reg_p1] 
//          b = [b1, b0] stored in [reg_p2] 
//  Output: c stored in [reg_p3]
//***********************************************************************
.global fp2_muln_subpart_p4
fp2_muln_subpart_p4:   
    push   r12 
    mov    rcx, reg_p2
    
    // [r8:r15, rax] <- z = a0 x b00 - a1 x b10
    mov    rdx, [rcx]
    mulx   r9, r8, [reg_p1]    
    xor    rax, rax 
    mulx   r10, r11, [reg_p1+8]
    adcx   r9, r11        
    mulx   r11, r12, [reg_p1+16]    
    push   r13
    adcx   r10, r12        
    mulx   r12, r13, [reg_p1+24]   
    push   r14
    adcx   r11, r13       
    mulx   r13, r14, [reg_p1+32]   
    push   r15
    adcx   r12, r14      
    mulx   r14, rax, [reg_p1+40]    
    push   rbx 
    adcx   r13, rax      
    mulx   r15, rax, [reg_p1+48]  
    push   rbp    
    adcx   r14, rax      
    mulx   rax, rbx, [reg_p1+56]
    adcx   r15, rbx     
    adc    rax, 0 

	FPADDSUBMUL512x512nr [reg_p1], [reg_p1+64], [rcx], [rcx+64], r8, r9, r10, r11, r12, r13, r14, r15, rax, rbx, rbp                                    

    // Final correction if partial result < 0
    mov    rbx, [rip+pdiv4]
    mov    rcx, [rip+pdiv4+8]
    mov    rdx, [rip+pdiv4+16]
    mov    rsi, [rip+pdiv4+24]
    and    rbx, rbp
    and    rcx, rbp
    and    rdx, rbp
    and    rsi, rbp
    
    add    r15, rbx
    adc    rax, rcx
    adc    r8, rdx
    adc    r9, rsi
    setc   cl
    mov    [reg_p3+56], r15 
    mov    [reg_p3+64], rax     
    mov    [reg_p3+72], r8 
    mov    [reg_p3+80], r9 
    
    mov    r15, [rip+pdiv4+32]
    mov    rax, [rip+pdiv4+40]
    mov    rbx, [rip+pdiv4+48]
    mov    rdx, [rip+pdiv4+56]
    mov    rsi, [rip+pdiv4+64]
    and    r15, rbp
    and    rax, rbp
    and    rbx, rbp
    and    rdx, rbp
    and    rsi, rbp
    
    bt     rcx, 0
    adc    r10, r15
    adc    r11, rax
    adc    r12, rbx
    adc    r13, rdx
    adc    r14, rsi
	              
    mov    [reg_p3+88], r10
    mov    [reg_p3+96], r11  
    mov    [reg_p3+104], r12
    mov    [reg_p3+112], r13 
    mov    [reg_p3+120], r14
    pop    rbp
    pop    rbx
    pop    r15
    pop    r14
    pop    r13
    pop    r12
    ret

///////////////////////////////////////////////////////////////// MACRO
// z = a x b + c x d (mod p)
// Inputs: base memory pointers M0 (a,c), M1 (b,d)
//         bi pre-stored in rdx,
//         accumulator z in [Z0:Z7], pre-stores a0 x b
// Output: reg_p3
// Temps:  regs T0:T1
/////////////////////////////////////////////////////////////////
.macro FPDBLMUL512x512nr M00, M01, M10, M11, Z0, Z1, Z2, Z3, Z4, Z5, Z6, Z7, Z8, T0, T1           
    mov    rdx, \M11    
    MULADD64x512 \M01, \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \T0, \T1, \T0
    mov    [reg_p3], \Z0            // Result c0
    
    // [Z1:Z8 , Z0] <- z = a01 x a1 + z
    mov    rdx, 8\M10
    MULADD64x512 \M00, \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \T0, \T1, \Z0           
    mov    rdx, 8\M11    
    MULADD64x512 \M01, \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \T0, \T1, \T0
    mov    [reg_p3+8], \Z1          // Result c1
    
    // [Z2:Z8 , Z0:Z1] <- z = a02 x a1 + z  
    mov    rdx, 16\M10
    MULADD64x512 \M00, \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \T0, \T1, \Z1          
    mov    rdx, 16\M11    
    MULADD64x512 \M01, \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \T0, \T1, \T0
    mov    [reg_p3+16], \Z2         // Result c2
    
    // [Z3:Z8 , Z0:Z2] <- z = a03 x a1 + z
    mov    rdx, 24\M10
    MULADD64x512 \M00, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \T0, \T1, \Z2          
    mov    rdx, 24\M11    
    MULADD64x512 \M01, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \T0, \T1, \T0
    mov    [reg_p3+24], \Z3         // Result c3
    
    // [Z4:Z8 , Z0:Z3] <- z = a04 x a1 + z 
    mov    rdx, 32\M10
    MULADD64x512 \M00, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \T0, \T1, \Z3          
    mov    rdx, 32\M11    
    MULADD64x512 \M01, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \T0, \T1, \T0
    mov    [reg_p3+32], \Z4         // Result c4
    
    // [Z5:Z8 , Z0:Z4] <- z = a05 x a1 + z    
    mov    rdx, 40\M10
    MULADD64x512 \M00, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \T0, \T1, \Z4          
    mov    rdx, 40\M11    
    MULADD64x512 \M01, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \T0, \T1, \T0
    mov    [reg_p3+40], \Z5         // Result c5
    
    // [Z6:Z8 , Z0:Z5] <- z = a06 x a1 + z  
    mov    rdx, 48\M10
    MULADD64x512 \M00, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \T0, \T1, \Z5          
    mov    rdx, 48\M11    
    MULADD64x512 \M01, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \T0, \T1, \T0
    mov    [reg_p3+48], \Z6         // Result c6
    
    // [Z7:Z8 , Z0:Z6] <- z = a06 x a1 + z  
    mov    rdx, 56\M10
    MULADD64x512 \M00, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \T0, \T1, \Z6          
    mov    rdx, 56\M11    
    MULADD64x512 \M01, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \T0, \T1, \T0  
    mov    [reg_p3+56], \Z7         // Result c7:c15
    mov    [reg_p3+64], \Z8     
    mov    [reg_p3+72], \Z0 
    mov    [reg_p3+80], \Z1 
    mov    [reg_p3+88], \Z2
    mov    [reg_p3+96], \Z3  
    mov    [reg_p3+104], \Z4 
    mov    [reg_p3+112], \Z5 
    mov    [reg_p3+120], \Z6
.endm

//***********************************************************************
//  Multiplication in GF(p^2) without reduction, complex part
//  Operation: c [reg_p3] = a0 x b1 + a1 x b0
//  Inputs: a = [a1, a0] stored in [reg_p1] 
//          b = [b1, b0] stored in [reg_p2] 
//  Output: c stored in [reg_p3]
//***********************************************************************
.global fp2_muln_addpart
fp2_muln_addpart: 
    mov    rcx, reg_p2
    
    // [r8:r15, rax] <- z = a0 x b10 + a1 x b00
    mov    rdx, [rcx]
    mulx   r9, r8, [reg_p1+64]     // a0 x b10
    xor    rax, rax     
    push   r12 
    mulx   r10, r11, [reg_p1+72]  
    push   r13  
    adcx   r9, r11        
    mulx   r11, r12, [reg_p1+80]  
    push   r14  
    adcx   r10, r12        
    mulx   r12, r13, [reg_p1+88]  
    push   r15   
    adcx   r11, r13       
    mulx   r13, r14, [reg_p1+96] 
    push   rbx    
    adcx   r12, r14      
    mulx   r14, r15, [reg_p1+104] 
    push   rbp 
    adcx   r13, r15      
    mulx   r15, rbp, [reg_p1+112] 
    adcx   r14, rbp       
    mulx   rax, rbx, [reg_p1+120]
    adcx   r15, rbx     
    adc    rax, 0 

	FPDBLMUL512x512nr [reg_p1+64], [reg_p1], [rcx], [rcx+64], r8, r9, r10, r11, r12, r13, r14, r15, rax, rbx, rbp
                        
    pop    rbp
    pop    rbx
    pop    r15
    pop    r14
    pop    r13
    pop    r12
    ret	

/////////////////////////////////////////////////////////////////
// Precomputing values
/////////////////////////////////////////////////////////////////
.global precomp509_asm
precomp509_asm: 
  push   r12
  push   r13 
  push   r14 
  push   r15 
  push   rbx

  // bi + bii
  mov    r8, [reg_p1]
  mov    r9, [reg_p1+8]
  mov    r10, [reg_p1+16]
  mov    r11, [reg_p1+24]
  mov    rax, [reg_p1+64]
  mov    rbx, [reg_p1+72]
  mov    rcx, [reg_p1+80]
  mov    rdx, [reg_p1+88]
  add    rax, r8
  adc    rbx, r9
  adc    rcx, r10
  adc    rdx, r11
  mov    [reg_p3], rax
  mov    [reg_p3+8], rbx
  mov    [reg_p3+16], rcx
  mov    [reg_p3+24], rdx
  mov    r12, [reg_p1+32]
  mov    r13, [reg_p1+40]
  mov    r14, [reg_p1+48]
  mov    r15, [reg_p1+56]
  mov    rax, [reg_p1+96]
  mov    rbx, [reg_p1+104]
  mov    rcx, [reg_p1+112]
  mov    rdx, [reg_p1+120]
  adc    rax, r12
  adc    rbx, r13
  adc    rcx, r14
  adc    rdx, r15
  mov    [reg_p3+32], rax
  mov    [reg_p3+40], rbx
  mov    [reg_p3+48], rcx
  mov    [reg_p3+56], rdx

  // bi - bii
  xor    rax, rax
  sub    r8, [reg_p1+64] 
  sbb    r9, [reg_p1+72] 
  sbb    r10, [reg_p1+80] 
  sbb    r11, [reg_p1+88]
  sbb    r12, [reg_p1+96] 
  sbb    r13, [reg_p1+104]
  sbb    r14, [reg_p1+112]
  sbb    r15, [reg_p1+120]
  sbb    rax, 0
  mov    rbx, [rip+p0]
  mov    rcx, [rip+p1]
  mov    rdx, [rip+p2]
  mov    rsi, [rip+p3]
  and    rbx, rax
  and    rcx, rax
  and    rdx, rax
  and    rsi, rax
  add    r8, rbx
  adc    r9, rcx
  adc    r10, rdx
  adc    r11, rsi
  mov    [reg_p3+64], r8
  mov    [reg_p3+72], r9
  mov    [reg_p3+80], r10
  mov    [reg_p3+88], r11
  setc   r8b
  mov    rbx, [rip+p4]
  mov    rcx, [rip+p5]
  mov    rdx, [rip+p6]
  mov    rsi, [rip+p7]
  and    rbx, rax
  and    rcx, rax
  and    rdx, rax
  and    rsi, rax
  bt     r8, 0
  adc    r12, rbx
  adc    r13, rcx
  adc    r14, rdx 
  adc    r15, rsi
  mov    [reg_p3+96], r12
  mov    [reg_p3+104], r13
  mov    [reg_p3+112], r14
  mov    [reg_p3+120], r15 

  pop    rbx
  pop    r15
  pop    r14
  pop    r13
  pop    r12  
  ret

///////////////////////////////////////////////////////////////// MACRO

.macro FPMULADDSUB512x512 A0, B0, A1, B1, A2, B2, A3, B3, C  
    mov    rcx, reg_p2
    
    // [r8:r15, rax] <- z = a00 x b00
    mov    rdx, \B0
    mulx   r9, r8, \A0    
    xor    rax, rax  
    push   r12  
    mulx   r10, r11, 8\A0
    adcx   r9, r11        
    mulx   r11, r12, 16\A0   
    push   r13
    adcx   r10, r12        
    mulx   r12, r13, 24\A0   
    push   r14
    adcx   r11, r13       
    mulx   r13, r14, 32\A0   
    push   r15
    adcx   r12, r14      
    mulx   r14, rax, 40\A0    
    push   rbx 
    adcx   r13, rax      
    mulx   r15, rax, 48\A0  
    push   rbp    
    adcx   r14, rax      
    mulx   rax, rbx, 56\A0
    adcx   r15, rbx     
    adc    rax, 0 
                     
    mov    rdx, \B1    
    MULSUB64x512 \A1, r8, r9, r10, r11, r12, r13, r14, r15, rax, rbx, rbp            
    mov    rdx, \B2    
    MULADD64x512 \A2, r8, r9, r10, r11, r12, r13, r14, r15, rax, rbx, rbp, rbx          
    mov    rdx, \B3    
    MULSUB64x512 \A3, r8, r9, r10, r11, r12, r13, r14, r15, rax, rbx, rbp 
    // [r9:r15, rax] <- z = (z0 x p509 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   rbx, rdx, r8             // rdx <- z0
    MULADD64x512 [rip+p0], r8, r9, r10, r11, r12, r13, r14, r15, rax, rbx, rbp, rbx
	mov    r8, 0
	bt     rax, 63
    sbb    r8, 0
    
    // [r9:r15, rax, r8] <- z = a0 x b01 - a1 x b11 + z 
    mov    rdx, 8\B0
    MULADD64x512 \A0, r9, r10, r11, r12, r13, r14, r15, rax, r8, rbx, rbp, rbx
    mov    rdx, 8\B1
    MULSUB64x512 \A1, r9, r10, r11, r12, r13, r14, r15, rax, r8, rbx, rbp         
    mov    rdx, 8\B2    
    MULADD64x512 \A2, r9, r10, r11, r12, r13, r14, r15, rax, r8, rbx, rbp, rbx  
    mov    rdx, 8\B3
    MULSUB64x512 \A3, r9, r10, r11, r12, r13, r14, r15, rax, r8, rbx, rbp 
    // [r10:r15, rax, r8] <- z = (z0 x p509 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r9             // rdx <- z0
    MULADD64x512 [rip+p0], r9, r10, r11, r12, r13, r14, r15, rax, r8, rbx, rbp, rbx
    mov    r9, 0
	bt     r8, 63
    sbb    r9, 0
    
    // [r10:r15, rax,, r8:r9] <- z = a0 x b02 - a1 x b12 + z
    mov    rdx, 16\B0
    MULADD64x512 \A0, r10, r11, r12, r13, r14, r15, rax, r8, r9, rbx, rbp, rbx
    mov    rdx, 16\B1
    MULSUB64x512 \A1, r10, r11, r12, r13, r14, r15, rax, r8, r9, rbx, rbp
    mov    rdx, 16\B2    
    MULADD64x512 \A2, r10, r11, r12, r13, r14, r15, rax, r8, r9, rbx, rbp, rbx
    mov    rdx, 16\B3
    MULSUB64x512 \A3, r10, r11, r12, r13, r14, r15, rax, r8, r9, rbx, rbp
    // [r11:r15, rax,, r8:r9] <- z = (z0 x p509 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r10           // rdx <- z0
    MULADD64x512 [rip+p0], r10, r11, r12, r13, r14, r15, rax, r8, r9, rbx, rbp, rbx
    mov    r10, 0
	bt     r9, 63
    sbb    r10, 0
    
    // [r11:r15, rax,, r8:r10] <- z = a0 x b03 - a1 x b13 + z
    mov    rdx, 24\B0
    MULADD64x512 \A0, r11, r12, r13, r14, r15, rax, r8, r9, r10, rbx, rbp, rbx
    mov    rdx, 24\B1
    MULSUB64x512 \A1, r11, r12, r13, r14, r15, rax, r8, r9, r10, rbx, rbp      
    mov    rdx, 24\B2    
    MULADD64x512 \A2, r11, r12, r13, r14, r15, rax, r8, r9, r10, rbx, rbp, rbx     
    mov    rdx, 24\B3
    MULSUB64x512 \A3, r11, r12, r13, r14, r15, rax, r8, r9, r10, rbx, rbp     
    // [r12:r15, rax, r8:r10] <- z = (z0 x p509 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r11           // rdx <- z0
    MULADD64x512 [rip+p0], r11, r12, r13, r14, r15, rax, r8, r9, r10, rbx, rbp, rbx
    mov    r11, 0
	bt     r10, 63
    sbb    r11, 0
    
    // [r12:r15, rax r8:r11] <- z = a0 x b04 - a1 x b14 + z 
    mov    rdx, 32\B0
    MULADD64x512 \A0, r12, r13, r14, r15, rax, r8, r9, r10, r11, rbx, rbp, rbx
    mov    rdx, 32\B1
    MULSUB64x512 \A1, r12, r13, r14, r15, rax, r8, r9, r10, r11, rbx, rbp         
    mov    rdx, 32\B2   
    MULADD64x512 \A2, r12, r13, r14, r15, rax, r8, r9, r10, r11, rbx, rbp, rbx  
    mov    rdx, 32\B3 
    MULSUB64x512 \A3, r12, r13, r14, r15, rax, r8, r9, r10, r11, rbx, rbp  
    // [r13:r15, rax, r8:r11] <- z = (z0 x p509 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r12           // rdx <- z0
    MULADD64x512 [rip+p0], r12, r13, r14, r15, rax, r8, r9, r10, r11, rbx, rbp, rbx
    mov    r12, 0
	bt     r11, 63
    sbb    r12, 0
    
    // [r13:r15, rax, r8:r12] <- z = a0 x b05 - a1 x b15 + z 
    mov    rdx, 40\B0
    MULADD64x512 \A0, r13, r14, r15, rax, r8, r9, r10, r11, r12, rbx, rbp, rbx
    mov    rdx, 40\B1
    MULSUB64x512 \A1, r13, r14, r15, rax, r8, r9, r10, r11, r12, rbx, rbp      
    mov    rdx, 40\B2
    MULADD64x512 \A2, r13, r14, r15, rax, r8, r9, r10, r11, r12, rbx, rbp, rbx
    mov    rdx, 40\B3
    MULSUB64x512 \A3, r13, r14, r15, rax, r8, r9, r10, r11, r12, rbx, rbp
    // [r14:r15, rax, r8:r12] <- z = (z0 x p509 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r13           // rdx <- z0
    MULADD64x512 [rip+p0], r13, r14, r15, rax, r8, r9, r10, r11, r12, rbx, rbp, rbx
    mov    r13, 0
	bt     r12, 63
    sbb    r13, 0                                    
    
    // [r14:r15, rax, r8:r13] <- z = a0 x b05 - a1 x b15 + z 
    mov    rdx, 48\B0
    MULADD64x512 \A0, r14, r15, rax, r8, r9, r10, r11, r12, r13, rbx, rbp, rbx
    mov    rdx, 48\B1
    MULSUB64x512 \A1, r14, r15, rax, r8, r9, r10, r11, r12, r13, rbx, rbp      
    mov    rdx, 48\B2
    MULADD64x512 \A2, r14, r15, rax, r8, r9, r10, r11, r12, r13, rbx, rbp, rbx
    mov    rdx, 48\B3
    MULSUB64x512 \A3, r14, r15, rax, r8, r9, r10, r11, r12, r13, rbx, rbp
    // [r15, rax, r8:r13] <- z = (z0 x p509 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r14           // rdx <- z0
    MULADD64x512 [rip+p0], r14, r15, rax, r8, r9, r10, r11, r12, r13, rbx, rbp, rbx 
    mov    r14, 0
	bt     r13, 63
    sbb    r14, 0                                    
    
    // [r15, rax, r8:r14] <- z = a0 x b05 - a1 x b15 + z 
    mov    rdx, 56\B0
    MULADD64x512 \A0, r15, rax, r8, r9, r10, r11, r12, r13, r14, rbx, rbp, rbx
    mov    rdx, 56\B1
    MULSUB64x512 \A1, r15, rax, r8, r9, r10, r11, r12, r13, r14, rbx, rbp      
    mov    rdx, 56\B2
    MULADD64x512 \A2, r15, rax, r8, r9, r10, r11, r12, r13, r14, rbx, rbp, rbx
    mov    rdx, 56\B3
    MULSUB64x512 \A3, r15, rax, r8, r9, r10, r11, r12, r13, r14, rbx, rbp
    // [rax, r8:r14] <- z = (z0 x p509 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r15           // rdx <- z0
    MULADD64x512 [rip+p0], r15, rax, r8, r9, r10, r11, r12, r13, r14, rbx, rbp, rbx
    mov    rsi, 0
	bt     r14, 63
    sbb    rsi, 0                                    
	
    // Correction if result < 0
	mov    rbx, [rip+p0]
	mov    rbp, [rip+p1]
	mov    r15, [rip+p2]
	mov    rcx, [rip+p3]
	mov    rdx, [rip+p4]
	and    rbx, rsi
	and    rbp, rsi
	and    r15, rsi
	and    rcx, rsi
	and    rdx, rsi
	add    rax, rbx
	adc    r8, rbp
	adc    r9, r15
	adc    r10, rcx
	adc    r11, rdx
    setc   cl
    mov    r15, [rip+p5]
    mov    rbx, [rip+p6]
    mov    rbp, [rip+p7]
    and    r15, rsi
    and    rbx, rsi
    and    rbp, rsi
    bt     rcx, 0
	adc    r12, r15
    adc    r13, rbx
    adc    r14, rbp

	// Final correction
    xor    rsi, rsi
	mov    rbx, [rip+p0]
	mov    rbp, [rip+p1]
	mov    r15, [rip+p2]
	mov    rcx, [rip+p3]
	mov    rdx, [rip+p4]
	sub    rax, rbx
	sbb    r8, rbp
	sbb    r9, r15
	sbb    r10, rcx
	sbb    r11, rdx
	sbb    r12, [rip+p5]
	sbb    r13, [rip+p6]
	sbb    r14, [rip+p7]
	sbb    rsi, 0
	and    rbx, rsi
	and    rbp, rsi
	and    r15, rsi
	and    rcx, rsi
	and    rdx, rsi
	add    rax, rbx
	adc    r8, rbp
	adc    r9, r15
	adc    r10, rcx
	adc    r11, rdx
    setc   cl
    mov    r15, [rip+p5]
    mov    rbx, [rip+p6]
    mov    rbp, [rip+p7]
    and    r15, rsi
    and    rbx, rsi
    and    rbp, rsi
    bt     rcx, 0
	adc    r12, r15
    adc    r13, rbx
    adc    r14, rbp
    
    mov    \C, rax          
    mov    8\C, r8         
    mov    16\C, r9         
    mov    24\C, r10      
    mov    32\C, r11      
    mov    40\C, r12     
    mov    48\C, r13     
    mov    56\C, r14
    pop    rbp
    pop    rbx
    pop    r15
    pop    r14
    pop    r13
    pop    r12
 .endm

.macro FPMULADD512x512 A0, B0, A1, B1, A2, B2, A3, B3, C  
    mov    rcx, reg_p2
    
    // [r8:r15, rax] <- z = a00 x b00
    mov    rdx, \B0
    mulx   r9, r8, \A0    
    xor    rax, rax  
    push   r12  
    mulx   r10, r11, 8\A0
    adcx   r9, r11        
    mulx   r11, r12, 16\A0   
    push   r13
    adcx   r10, r12        
    mulx   r12, r13, 24\A0   
    push   r14
    adcx   r11, r13       
    mulx   r13, r14, 32\A0   
    push   r15
    adcx   r12, r14      
    mulx   r14, rax, 40\A0    
    push   rbx 
    adcx   r13, rax      
    mulx   r15, rax, 48\A0  
    push   rbp    
    adcx   r14, rax      
    mulx   rax, rbx, 56\A0
    adcx   r15, rbx     
    adc    rax, 0 
                     
    mov    rdx, \B1    
    MULADD64x512 \A1, r8, r9, r10, r11, r12, r13, r14, r15, rax, rbx, rbp, rbx            
    mov    rdx, \B2    
    MULADD64x512 \A2, r8, r9, r10, r11, r12, r13, r14, r15, rax, rbx, rbp, rbx          
    mov    rdx, \B3    
    MULADD64x512 \A3, r8, r9, r10, r11, r12, r13, r14, r15, rax, rbx, rbp, rbx 
    // [r9:r15, rax] <- z = (z0 x p509 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   rbx, rdx, r8             // rdx <- z0
    MULADD64x512 [rip+p0], r8, r9, r10, r11, r12, r13, r14, r15, rax, rbx, rbp, rbx
	//xor    r8, r8
    
    // [r9:r15, rax, r8] <- z = a0 x b01 - a1 x b11 + z 
    mov    rdx, 8\B0
    MULADD64x512 \A0, r9, r10, r11, r12, r13, r14, r15, rax, r8, rbx, rbp, r8
    mov    rdx, 8\B1
    MULADD64x512 \A1, r9, r10, r11, r12, r13, r14, r15, rax, r8, rbx, rbp, rbx         
    mov    rdx, 8\B2    
    MULADD64x512 \A2, r9, r10, r11, r12, r13, r14, r15, rax, r8, rbx, rbp, rbx  
    mov    rdx, 8\B3
    MULADD64x512 \A3, r9, r10, r11, r12, r13, r14, r15, rax, r8, rbx, rbp, rbx 
    // [r10:r15, rax, r8] <- z = (z0 x p509 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r9             // rdx <- z0
    MULADD64x512 [rip+p0], r9, r10, r11, r12, r13, r14, r15, rax, r8, rbx, rbp, rbx
	//xor    r9, r9
    
    // [r10:r15, rax,, r8:r9] <- z = a0 x b02 - a1 x b12 + z
    mov    rdx, 16\B0
    MULADD64x512 \A0, r10, r11, r12, r13, r14, r15, rax, r8, r9, rbx, rbp, r9
    mov    rdx, 16\B1
    MULADD64x512 \A1, r10, r11, r12, r13, r14, r15, rax, r8, r9, rbx, rbp, rbx
    mov    rdx, 16\B2    
    MULADD64x512 \A2, r10, r11, r12, r13, r14, r15, rax, r8, r9, rbx, rbp, rbx
    mov    rdx, 16\B3
    MULADD64x512 \A3, r10, r11, r12, r13, r14, r15, rax, r8, r9, rbx, rbp, rbx
    // [r11:r15, rax,, r8:r9] <- z = (z0 x p509 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r10           // rdx <- z0
    MULADD64x512 [rip+p0], r10, r11, r12, r13, r14, r15, rax, r8, r9, rbx, rbp, rbx
	//xor    r10, r10
    
    // [r11:r15, rax,, r8:r10] <- z = a0 x b03 - a1 x b13 + z
    mov    rdx, 24\B0
    MULADD64x512 \A0, r11, r12, r13, r14, r15, rax, r8, r9, r10, rbx, rbp, r10
    mov    rdx, 24\B1
    MULADD64x512 \A1, r11, r12, r13, r14, r15, rax, r8, r9, r10, rbx, rbp, rbx      
    mov    rdx, 24\B2    
    MULADD64x512 \A2, r11, r12, r13, r14, r15, rax, r8, r9, r10, rbx, rbp, rbx     
    mov    rdx, 24\B3
    MULADD64x512 \A3, r11, r12, r13, r14, r15, rax, r8, r9, r10, rbx, rbp, rbx     
    // [r12:r15, rax, r8:r10] <- z = (z0 x p509 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r11           // rdx <- z0
    MULADD64x512 [rip+p0], r11, r12, r13, r14, r15, rax, r8, r9, r10, rbx, rbp, rbx     
	//xor    r11, r11
    
    // [r12:r15, rax r8:r11] <- z = a0 x b04 - a1 x b14 + z 
    mov    rdx, 32\B0
    MULADD64x512 \A0, r12, r13, r14, r15, rax, r8, r9, r10, r11, rbx, rbp, r11
    mov    rdx, 32\B1
    MULADD64x512 \A1, r12, r13, r14, r15, rax, r8, r9, r10, r11, rbx, rbp, rbx         
    mov    rdx, 32\B2   
    MULADD64x512 \A2, r12, r13, r14, r15, rax, r8, r9, r10, r11, rbx, rbp, rbx  
    mov    rdx, 32\B3 
    MULADD64x512 \A3, r12, r13, r14, r15, rax, r8, r9, r10, r11, rbx, rbp, rbx  
    // [r13:r15, rax, r8:r11] <- z = (z0 x p509 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r12           // rdx <- z0
    MULADD64x512 [rip+p0], r12, r13, r14, r15, rax, r8, r9, r10, r11, rbx, rbp, rbx  
	//xor    r12, r12
    
    // [r13:r15, rax, r8:r12] <- z = a0 x b05 - a1 x b15 + z 
    mov    rdx, 40\B0
    MULADD64x512 \A0, r13, r14, r15, rax, r8, r9, r10, r11, r12, rbx, rbp, r12
    mov    rdx, 40\B1
    MULADD64x512 \A1, r13, r14, r15, rax, r8, r9, r10, r11, r12, rbx, rbp, rbx      
    mov    rdx, 40\B2
    MULADD64x512 \A2, r13, r14, r15, rax, r8, r9, r10, r11, r12, rbx, rbp, rbx
    mov    rdx, 40\B3
    MULADD64x512 \A3, r13, r14, r15, rax, r8, r9, r10, r11, r12, rbx, rbp, rbx
    // [r14:r15, rax, r8:r12] <- z = (z0 x p509 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r13           // rdx <- z0
    MULADD64x512 [rip+p0], r13, r14, r15, rax, r8, r9, r10, r11, r12, rbx, rbp, rbx 
	//xor    r13, r13
    
    // [r14:r15, rax, r8:r13] <- z = a0 x b05 - a1 x b15 + z 
    mov    rdx, 48\B0
    MULADD64x512 \A0, r14, r15, rax, r8, r9, r10, r11, r12, r13, rbx, rbp, r13
    mov    rdx, 48\B1
    MULADD64x512 \A1, r14, r15, rax, r8, r9, r10, r11, r12, r13, rbx, rbp, rbx      
    mov    rdx, 48\B2
    MULADD64x512 \A2, r14, r15, rax, r8, r9, r10, r11, r12, r13, rbx, rbp, rbx
    mov    rdx, 48\B3
    MULADD64x512 \A3, r14, r15, rax, r8, r9, r10, r11, r12, r13, rbx, rbp, rbx
    // [r15, rax, r8:r13] <- z = (z0 x p509 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r14           // rdx <- z0
    MULADD64x512 [rip+p0], r14, r15, rax, r8, r9, r10, r11, r12, r13, rbx, rbp, rbx 
	//xor    r14, r14
    
    // [r15, rax, r8:r14] <- z = a0 x b05 - a1 x b15 + z 
    mov    rdx, 56\B0
    MULADD64x512 \A0, r15, rax, r8, r9, r10, r11, r12, r13, r14, rbx, rbp, r14
    mov    rdx, 56\B1
    MULADD64x512 \A1, r15, rax, r8, r9, r10, r11, r12, r13, r14, rbx, rbp, rbx      
    mov    rdx, 56\B2
    MULADD64x512 \A2, r15, rax, r8, r9, r10, r11, r12, r13, r14, rbx, rbp, rbx
    mov    rdx, 56\B3
    MULADD64x512 \A3, r15, rax, r8, r9, r10, r11, r12, r13, r14, rbx, rbp, rbx
    // [rax, r8:r14] <- z = (z0 x p509 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r15           // rdx <- z0
    MULADD64x512 [rip+p0], r15, rax, r8, r9, r10, r11, r12, r13, r14, rbx, rbp, rbx

	// Final correction
    xor    rsi, rsi
	mov    rbx, [rip+p0]
	mov    rbp, [rip+p1]
	mov    r15, [rip+p2]
	mov    rcx, [rip+p3]
	mov    rdx, [rip+p4]
	sub    rax, rbx
	sbb    r8, rbp
	sbb    r9, r15
	sbb    r10, rcx
	sbb    r11, rdx
	sbb    r12, [rip+p5]
	sbb    r13, [rip+p6]
	sbb    r14, [rip+p7]
	sbb    rsi, 0
	and    rbx, rsi
	and    rbp, rsi
	and    r15, rsi
	and    rcx, rsi
	and    rdx, rsi
	add    rax, rbx
	adc    r8, rbp
	adc    r9, r15
	adc    r10, rcx
	adc    r11, rdx
    setc   cl
    mov    r15, [rip+p5]
    mov    rbx, [rip+p6]
    mov    rbp, [rip+p7]
    and    r15, rsi
    and    rbx, rsi
    and    rbp, rsi
    bt     rcx, 0
	adc    r12, r15
    adc    r13, rbx
    adc    r14, rbp
    
    mov    \C, rax          
    mov    8\C, r8         
    mov    16\C, r9         
    mov    24\C, r10      
    mov    32\C, r11      
    mov    40\C, r12     
    mov    48\C, r13     
    mov    56\C, r14
    pop    rbp
    pop    rbx
    pop    r15
    pop    r14
    pop    r13
    pop    r12
.endm
  
//***********************************************************************
//  Multiplication in GF(p^4), first term
//  Operation: c [reg_p3] = a0 x b0 + E(a1 x b1)
//  Inputs: a = [a1, a0] stored in [reg_p1] 
//          b = [b1, b0] stored in [reg_p2] 
//  Output: c stored in [reg_p3]
//*********************************************************************** 
.global fp4mul509c0_asm
fp4mul509c0_asm: 
	FPMULADDSUB512x512 [reg_p1], [rcx], [reg_p1+64], [rcx+64], [reg_p1+128], [reg_p3+320], [reg_p1+192], [reg_p3+256], [reg_p3] 
	ret
	
.global fp4mul509c1_asm
fp4mul509c1_asm:
	FPMULADD512x512 [reg_p1], [rcx+64], [reg_p1+64], [rcx], [reg_p1+128], [reg_p3+256], [reg_p1+192], [reg_p3+320], [reg_p3+64] 
    ret
	
.global fp4mul509c2_asm
fp4mul509c2_asm: 
	FPMULADDSUB512x512 [reg_p1], [rcx+128], [reg_p1+64], [rcx+192], [reg_p1+128], [rcx], [reg_p1+192], [rcx+64], [reg_p3+128] 
    ret
	
.global fp4mul509c3_asm
fp4mul509c3_asm:
	FPMULADD512x512 [reg_p1], [rcx+192], [reg_p1+64], [rcx+128], [reg_p1+128], [rcx+64], [reg_p1+192], [rcx], [reg_p3+192] 
    ret
	
.att_syntax prefix