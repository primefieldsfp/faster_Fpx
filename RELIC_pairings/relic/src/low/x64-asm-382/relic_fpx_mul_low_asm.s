  
.intel_syntax noprefix

// Registers that are used for parameter passing:
#define reg_p1  rsi
#define reg_p2  rdx
#define reg_p3  rdi


.data

u0:
.quad	0x89F3FFFCFFFCFFFD   

pdiv4:
.quad   0xC000000000000000
.quad   0xEE7FBFFFFFFFEAAA
.quad   0x07AAFFFFAC54FFFF
.quad   0xD9CC34A83DAC3D89
.quad   0xD91DD2E13CE144AF
.quad   0x92C6E9ED90D2EB35
.quad   0x0680447A8E5FF9A6   

.text
 
 ///////////////////////////////////////////////////////////////// MACRO
// z = a x bi + z
// Inputs: base memory pointer M1 (a),
//         bi pre-stored in rdx,
//         accumulator z in [Z0:Z6]
// Output: [Z0:Z6]
// Temps:  regs T0:T1
/////////////////////////////////////////////////////////////////
.macro MULADD64x384 M1, Z0, Z1, Z2, Z3, Z4, Z5, Z6, T0, T1
    mulx   \T0, \T1, \M1     // A0*B0
    xor    rax, rax
    adox   \Z0, \T1
    adox   \Z1, \T0  
    mulx   \T0, \T1, 8\M1    // A0*B1
    adcx   \Z1, \T1
    adox   \Z2, \T0    
    mulx   \T0, \T1, 16\M1   // A0*B2        ////////////// NOTE: REMOVE RAX, ELIMINATE XOR CLEARING IN THE CALLER
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
    adcx   \Z6, rax    
.endm
     
//***********************************************************************
//  Multiplication in GF(p^2), complex part
//  Operation: c [reg_p3] = a0 x b1 + a1 x b0
//  Inputs: a = [a1, a0] stored in [reg_p1] 
//          b = [b1, b0] stored in [reg_p2] 
//  Output: c stored in [reg_p3]
//*********************************************************************** 
.global fp2_mulm_addpart
fp2_mulm_addpart:   
    push   r12
    push   r13 
    push   r14  
    push   r15  
    push   rbx
    push   rbp
    mov    rcx, reg_p2
    
    // [r8:r14] <- z = a0 x b10 + a1 x b00
    mov    rdx, [rcx]
    mulx   r9, r8, [reg_p1+48]     // a0 x b10
    xor    rax, rax   
    mulx   r10, r11, [reg_p1+56]   
    adox   r9, r11        
    mulx   r11, r12, [reg_p1+64]   
    adox   r10, r12        
    mulx   r12, r13, [reg_p1+72]   
    adox   r11, r13       
    mulx   r13, r14, [reg_p1+80]   
    adox   r12, r14      
    mulx   r14, r15, [reg_p1+88]   
    adox   r13, r15 
    adox   r14, rax 
           
    mov    rdx, [rcx+48]    
    MULADD64x384 [reg_p1], r8, r9, r10, r11, r12, r13, r14, r15, rbx        
    // [r9:r14] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   rbp, rdx, r8             // rdx <- z0
    MULADD64x384 [rip+p0], r8, r9, r10, r11, r12, r13, r14, r15, rbx
    
    // [r9:r14, r8] <- z = a0 x b11 + a1 x b01 + z        
    xor    r8, r8 
    mov    rdx, [rcx+8]
    MULADD64x384 [reg_p1+48], r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    rdx, [rcx+56]    
    MULADD64x384 [reg_p1], r9, r10, r11, r12, r13, r14, r8, r15, rbx
    // [r10:r14, r8] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbp, rdx, r9             // rdx <- z0
    MULADD64x384 [rip+p0], r9, r10, r11, r12, r13, r14, r8, r15, rbx
    
    // [r10:r14, r8:r9] <- z = a0 x b12 + a1 x b02 + z        
    xor    r9, r9 
    mov    rdx, [rcx+16]
    MULADD64x384 [reg_p1+48], r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, [rcx+64]    
    MULADD64x384 [reg_p1], r10, r11, r12, r13, r14, r8, r9, r15, rbx
    // [r11:r14, r8:r9] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbp, rdx, r10           // rdx <- z0
    MULADD64x384 [rip+p0], r10, r11, r12, r13, r14, r8, r9, r15, rbx
    
    // [r11:r14, r8:r10] <- z = a0 x b13 + a1 x b03 + z        
    xor    r10, r10 
    mov    rdx, [rcx+24]
    MULADD64x384 [reg_p1+48], r11, r12, r13, r14, r8, r9, r10, r15, rbx
    mov    rdx, [rcx+72]    
    MULADD64x384 [reg_p1], r11, r12, r13, r14, r8, r9, r10, r15, rbx
    // [r12:r14, r8:r10] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbp, rdx, r11           // rdx <- z0
    MULADD64x384 [rip+p0], r11, r12, r13, r14, r8, r9, r10, r15, rbx
    
    // [r12:r14, r8:r11] <- z = a0 x b14 + a1 x b04 + z        
    xor    r11, r11 
    mov    rdx, [rcx+32]
    MULADD64x384 [reg_p1+48], r12, r13, r14, r8, r9, r10, r11, r15, rbx
    mov    rdx, [rcx+80]    
    MULADD64x384 [reg_p1], r12, r13, r14, r8, r9, r10, r11, r15, rbx
    // [r13:r14, r8:r11] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbp, rdx, r12           // rdx <- z0
    MULADD64x384 [rip+p0], r12, r13, r14, r8, r9, r10, r11, r15, rbx
    
    // [r13:r14, r8:r12] <- z = a0 x b15 + a1 x b05 + z        
    xor    r12, r12 
    mov    rdx, [rcx+40]
    MULADD64x384 [reg_p1+48], r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, [rcx+88]    
    MULADD64x384 [reg_p1], r13, r14, r8, r9, r10, r11, r12, r15, rbx
    // [r14, r8:r12] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbp, rdx, r13           // rdx <- z0
    MULADD64x384 [rip+p0], r13, r14, r8, r9, r10, r11, r12, r15, rbx           /////////////// COULD BE SIMPLIFIED

	// Final correction                        ////////////// COULD THIS ME REMOVED? RANGE TO [0, 2p]?
	mov    r13, [rip+p0]
	mov    r15, [rip+p1]
	mov    rbx, [rip+p2]
	mov    rcx, [rip+p3]
	mov    rdx, [rip+p4]
	mov    rsi, [rip+p5]
	sub    r14, r13
	sbb    r8, r15
	sbb    r9, rbx
	sbb    r10, rcx
	sbb    r11, rdx
	sbb    r12, rsi
	sbb    rax, 0
	and    r13, rax
	and    r15, rax
	and    rbx, rax
	and    rcx, rax
	and    rdx, rax
	and    rsi, rax
	add    r14, r13
	adc    r8, r15
	adc    r9, rbx
	adc    r10, rcx
	adc    r11, rdx
	adc    r12, rsi
    
    mov    [reg_p3], r14          
    mov    [reg_p3+8], r8         
    mov    [reg_p3+16], r9         
    mov    [reg_p3+24], r10      
    mov    [reg_p3+32], r11      
    mov    [reg_p3+40], r12 
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
//         accumulator z in [Z0:Z6]
// Output: [Z0:Z6]
// Temps:  regs T0:T1
/////////////////////////////////////////////////////////////////
.macro MULSUB64x384 M1, Z0, Z1, Z2, Z3, Z4, Z5, Z6, T0, T1
    mulx   \T0, \T1, 8\M1    // A0*B1
    sub    \Z1, \T1
    sbb    \Z2, \T0
    mulx   \T0, \T1, 24\M1   // A0*B3          
    sbb    \Z3, \T1
    sbb    \Z4, \T0  
    mulx   \T0, \T1, 40\M1   // A0*B5          
    sbb    \Z5, \T1
    sbb    \Z6, \T0	
    mulx   \T0, \T1, \M1     // A0*B0     
    sub    \Z0, \T1
    sbb    \Z1, \T0  
    mulx   \T0, \T1, 16\M1   // A0*B2
    sbb    \Z2, \T1
    sbb    \Z3, \T0   
    mulx   \T0, \T1, 32\M1   // A0*B4
    sbb    \Z4, \T1
    sbb    \Z5, \T0 
	sbb    \Z6, rax                ////////////// NOTE: REMOVE RAX, ELIMINATE XOR CLEARING IN THE CALLER
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
    push   r13 
    push   r14  
    push   r15  
    push   rbx
    push   rbp
    mov    rcx, reg_p2
    
    // [r8:r14] <- z = a0 x b00 - a1 x b10
    mov    rdx, [rcx]
    mulx   r9, r8, [reg_p1]        
    xor    rax, rax   
    mulx   r10, r11, [reg_p1+8]    
    adox   r9, r11        
    mulx   r11, r12, [reg_p1+16]   
    adox   r10, r12        
    mulx   r12, r13, [reg_p1+24]   
    adox   r11, r13       
    mulx   r13, r14, [reg_p1+32]   
    adox   r12, r14      
    mulx   r14, r15, [reg_p1+40]   
    adox   r13, r15 
    adox   r14, rax
           
    mov    rdx, [rcx+48]    
    MULSUB64x384 [reg_p1+48], r8, r9, r10, r11, r12, r13, r14, r15, rbx        
    // [r9:r14] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   rbp, rdx, r8             // rdx <- z0
    MULADD64x384 [rip+p0], r8, r9, r10, r11, r12, r13, r14, r15, rbx
    mov    r8, 0                                                     //////////// ANY CHANGE IF WE SWITCH IT TO XOR?
	bt     r14, 63
    sbb    r8, 0
    
    // [r9:r14, r8] <- z = a0 x b01 - a1 x b11 + z 
    mov    rdx, [rcx+8]
    MULADD64x384 [reg_p1], r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    rdx, [rcx+56]    
    MULSUB64x384 [reg_p1+48], r9, r10, r11, r12, r13, r14, r8, r15, rbx
    // [r10:r14, r8] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbp, rdx, r9             // rdx <- z0
    MULADD64x384 [rip+p0], r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    r9, 0
	bt     r8, 63
    sbb    r9, 0
    
    // [r10:r14, r8:r9] <- z = a0 x b02 - a1 x b12 + z 
    mov    rdx, [rcx+16]
    MULADD64x384 [reg_p1], r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, [rcx+64]    
    MULSUB64x384 [reg_p1+48], r10, r11, r12, r13, r14, r8, r9, r15, rbx
    // [r11:r14, r8:r9] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbp, rdx, r10           // rdx <- z0
    MULADD64x384 [rip+p0], r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    r10, 0
	bt     r9, 63
    sbb    r10, 0
    
    // [r11:r14, r8:r10] <- z = a0 x b03 - a1 x b13 + z
    mov    rdx, [rcx+24]
    MULADD64x384 [reg_p1], r11, r12, r13, r14, r8, r9, r10, r15, rbx
    mov    rdx, [rcx+72]    
    MULSUB64x384 [reg_p1+48], r11, r12, r13, r14, r8, r9, r10, r15, rbx
    // [r12:r14, r8:r10] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbp, rdx, r11           // rdx <- z0
    MULADD64x384 [rip+p0], r11, r12, r13, r14, r8, r9, r10, r15, rbx
    mov    r11, 0
	bt     r10, 63
    sbb    r11, 0
    
    // [r12:r14, r8:r11] <- z = a0 x b04 - a1 x b14 + z 
    mov    rdx, [rcx+32]
    MULADD64x384 [reg_p1], r12, r13, r14, r8, r9, r10, r11, r15, rbx
    mov    rdx, [rcx+80]    
    MULSUB64x384 [reg_p1+48], r12, r13, r14, r8, r9, r10, r11, r15, rbx
    // [r13:r14, r8:r11] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbp, rdx, r12           // rdx <- z0
    MULADD64x384 [rip+p0], r12, r13, r14, r8, r9, r10, r11, r15, rbx
    mov    r12, 0
	bt     r11, 63
    sbb    r12, 0
    
    // [r13:r14, r8:r12] <- z = a0 x b05 - a1 x b15 + z 
    mov    rdx, [rcx+40]
    MULADD64x384 [reg_p1], r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, [rcx+88]    
    MULSUB64x384 [reg_p1+48], r13, r14, r8, r9, r10, r11, r12, r15, rbx
    // [r14, r8:r12] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbp, rdx, r13           // rdx <- z0
    MULADD64x384 [rip+p0], r13, r14, r8, r9, r10, r11, r12, r15, rbx           /////////////// COULD BE SIMPLIFIED
    mov    rax, 0
	bt     r12, 63
    sbb    rax, 0                                    

    // Correction if result < 0
	mov    r13, [rip+p0]
	mov    r15, [rip+p1]
	mov    rbx, [rip+p2]
	mov    rcx, [rip+p3]
	mov    rdx, [rip+p4]
	mov    rsi, [rip+p5]
	and    r13, rax
	and    r15, rax
	and    rbx, rax
	and    rcx, rax
	and    rdx, rax
	and    rsi, rax
	add    r14, r13
	adc    r8, r15
	adc    r9, rbx
	adc    r10, rcx
	adc    r11, rdx
	adc    r12, rsi

	// Final correction                        ////////////// COULD THIS ME REMOVED? RANGE TO [0, 2p]?
	xor    rax, rax
	mov    r13, [rip+p0]
	mov    r15, [rip+p1]
	mov    rbx, [rip+p2]
	mov    rcx, [rip+p3]
	mov    rdx, [rip+p4]
	mov    rsi, [rip+p5]
	sub    r14, r13
	sbb    r8, r15
	sbb    r9, rbx
	sbb    r10, rcx
	sbb    r11, rdx
	sbb    r12, rsi
	sbb    rax, 0
	and    r13, rax
	and    r15, rax
	and    rbx, rax
	and    rcx, rax
	and    rdx, rax
	and    rsi, rax
	add    r14, r13
	adc    r8, r15
	adc    r9, rbx
	adc    r10, rcx
	adc    r11, rdx
	adc    r12, rsi
    
    mov    [reg_p3], r14          
    mov    [reg_p3+8], r8         
    mov    [reg_p3+16], r9         
    mov    [reg_p3+24], r10      
    mov    [reg_p3+32], r11      
    mov    [reg_p3+40], r12 
    pop    rbp
    pop    rbx
    pop    r15
    pop    r14
    pop    r13
    pop    r12
    ret
     
//***********************************************************************
//  Multiplication in GF(p^2) without reduction, complex part
//  Operation: c [reg_p3] = a0 x b1 + a1 x b0
//  Inputs: a = [a1, a0] stored in [reg_p1] 
//          b = [b1, b0] stored in [reg_p2] 
//  Output: c stored in [reg_p3]
//*********************************************************************** 
.global fp2_muln_addpart
fp2_muln_addpart:   
    push   r12
    push   r13 
    push   r14  
    push   r15  
    push   rbx
    mov    rcx, reg_p2
    
    // [r8:r14] <- z = a0 x b10 + a1 x b00
    mov    rdx, [rcx]
    mulx   r9, r8, [reg_p1+48]     // a0 x b10
    xor    rax, rax   
    mulx   r10, r11, [reg_p1+56]   
    adox   r9, r11        
    mulx   r11, r12, [reg_p1+64]   
    adox   r10, r12        
    mulx   r12, r13, [reg_p1+72]   
    adox   r11, r13       
    mulx   r13, r14, [reg_p1+80]   
    adox   r12, r14      
    mulx   r14, r15, [reg_p1+88]   
    adox   r13, r15 
    adox   r14, rax 
           
    mov    rdx, [rcx+48]    
    MULADD64x384 [reg_p1], r8, r9, r10, r11, r12, r13, r14, r15, rbx 
    mov    [reg_p3], r8            // Result c0
    
    // [r9:r14, r8] <- z = a0 x b11 + a1 x b01 + z        
    xor    r8, r8 
    mov    rdx, [rcx+8]
    MULADD64x384 [reg_p1+48], r9, r10, r11, r12, r13, r14, r8, r15, rbx 
    mov    rdx, [rcx+56]    
    MULADD64x384 [reg_p1], r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    [reg_p3+8], r9          // Result c1
    
    // [r10:r14, r8:r9] <- z = a0 x b12 + a1 x b02 + z        
    xor    r9, r9 
    mov    rdx, [rcx+16]
    MULADD64x384 [reg_p1+48], r10, r11, r12, r13, r14, r8, r9, r15, rbx 
    mov    rdx, [rcx+64]
    MULADD64x384 [reg_p1], r10, r11, r12, r13, r14, r8, r9, r15, rbx 
    mov    [reg_p3+16], r10        // Result c2
    
    // [r11:r14, r8:r10] <- z = a0 x b13 + a1 x b03 + z        
    xor    r10, r10 
    mov    rdx, [rcx+24]
    MULADD64x384 [reg_p1+48], r11, r12, r13, r14, r8, r9, r10, r15, rbx 
    mov    rdx, [rcx+72]
    MULADD64x384 [reg_p1], r11, r12, r13, r14, r8, r9, r10, r15, rbx 
    mov    [reg_p3+24], r11        // Result c3
    
    // [r12:r14, r8:r11] <- z = a0 x b14 + a1 x b04 + z        
    xor    r11, r11 
    mov    rdx, [rcx+32]
    MULADD64x384 [reg_p1+48], r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, [rcx+80]
    MULADD64x384 [reg_p1], r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    [reg_p3+32], r12        // Result c4
    
    // [r13:r14, r8:r12] <- z = a0 x b15 + a1 x b05 + z        
    xor    r12, r12 
    mov    rdx, [rcx+40]
    MULADD64x384 [reg_p1+48], r13, r14, r8, r9, r10, r11, r12, r15, rbx 
    mov    rdx, [rcx+88]
    MULADD64x384 [reg_p1], r13, r14, r8, r9, r10, r11, r12, r15, rbx 
    mov    [reg_p3+40], r13        // Result c5:c11
    mov    [reg_p3+48], r14
    mov    [reg_p3+56], r8
    mov    [reg_p3+64], r9
    mov    [reg_p3+72], r10
    mov    [reg_p3+80], r11
    mov    [reg_p3+88], r12

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
.global fp2_muln_subpart
fp2_muln_subpart:   
    push   r12
    push   r13 
    push   r14  
    push   r15  
    push   rbx
    mov    rcx, reg_p2
    
    // [r8:r14] <- z = a0 x b00 - a1 x b10
    mov    rdx, [rcx]
    mulx   r9, r8, [reg_p1]        
    xor    rax, rax   
    mulx   r10, r11, [reg_p1+8]    
    adox   r9, r11        
    mulx   r11, r12, [reg_p1+16]   
    adox   r10, r12        
    mulx   r12, r13, [reg_p1+24]   
    adox   r11, r13       
    mulx   r13, r14, [reg_p1+32]   
    adox   r12, r14      
    mulx   r14, r15, [reg_p1+40]   
    adox   r13, r15 
    adox   r14, rax
           
    mov    rdx, [rcx+48]    
    MULSUB64x384 [reg_p1+48], r8, r9, r10, r11, r12, r13, r14, r15, rbx
    mov    [reg_p3], r8            // Result c0
    
    // [r9:r14, r8] <- z = a0 x b01 - a1 x b11 + z 
    xor    r8, r8 
	bt     r14, 63
    sbb    r8, 0
    mov    rdx, [rcx+8]
    MULADD64x384 [reg_p1], r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    rdx, [rcx+56]    
    MULSUB64x384 [reg_p1+48], r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    [reg_p3+8], r9          // Result c1
    
    // [r10:r14, r8:r9] <- z = a0 x b02 - a1 x b12 + z 
    xor    r9, r9 
	bt     r8, 63
    sbb    r9, 0
    mov    rdx, [rcx+16]
    MULADD64x384 [reg_p1], r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, [rcx+64]    
    MULSUB64x384 [reg_p1+48], r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    [reg_p3+16], r10        // Result c2
    
    // [r11:r14, r8:r10] <- z = a0 x b03 - a1 x b13 + z
    xor    r10, r10 
	bt     r9, 63
    sbb    r10, 0
    mov    rdx, [rcx+24]
    MULADD64x384 [reg_p1], r11, r12, r13, r14, r8, r9, r10, r15, rbx
    mov    rdx, [rcx+72]    
    MULSUB64x384 [reg_p1+48], r11, r12, r13, r14, r8, r9, r10, r15, rbx
    mov    [reg_p3+24], r11        // Result c3
    
    // [r12:r14, r8:r11] <- z = a0 x b04 - a1 x b14 + z 
    xor    r11, r11 
	bt     r10, 63
    sbb    r11, 0
    mov    rdx, [rcx+32]
    MULADD64x384 [reg_p1], r12, r13, r14, r8, r9, r10, r11, r15, rbx
    mov    rdx, [rcx+80]    
    MULSUB64x384 [reg_p1+48], r12, r13, r14, r8, r9, r10, r11, r15, rbx
    mov    [reg_p3+32], r12        // Result c4
    
    // [r13:r14, r8:r12] <- z = a0 x b05 - a1 x b15 + z 
    xor    r12, r12 
	bt     r11, 63
    sbb    r12, 0
    mov    rdx, [rcx+40]
    MULADD64x384 [reg_p1], r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, [rcx+88]    
    MULSUB64x384 [reg_p1+48], r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    [reg_p3+40], r13        // Result c5
    xor    rax, rax 
	bt     r12, 63
    sbb    rax, 0                                    

    // Final correction if partial result < 0
    mov    r13, [rip+p0]
    mov    rbx, [rip+p1]
    mov    rcx, [rip+p2]
    mov    rdx, [rip+p3]
    mov    r15, [rip+p4]
    mov    rsi, [rip+p5]
    and    r13, rax
    and    rbx, rax
    and    rcx, rax
    and    rdx, rax
    and    r15, rax
    and    rsi, rax
    add    r14, r13
    adc    r8, rbx
    adc    r9, rcx
    adc    r10, rdx
    adc    r11, r15
    adc    r12, rsi
	
    mov    [reg_p3+48], r14          
    mov    [reg_p3+56], r8        
    mov    [reg_p3+64], r9         
    mov    [reg_p3+72], r10      
    mov    [reg_p3+80], r11     
    mov    [reg_p3+88], r12
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
    push   r13 
    push   r14  
    push   r15  
    push   rbx
	push   rbp
    mov    rcx, reg_p2
    
    // [r8:r14] <- z = a0 x b00 - a1 x b10
    mov    rdx, [rcx]
    mulx   r9, r8, [reg_p1]        
    xor    rax, rax   
    mulx   r10, r11, [reg_p1+8]    
    adox   r9, r11        
    mulx   r11, r12, [reg_p1+16]   
    adox   r10, r12        
    mulx   r12, r13, [reg_p1+24]   
    adox   r11, r13       
    mulx   r13, r14, [reg_p1+32]   
    adox   r12, r14      
    mulx   r14, r15, [reg_p1+40]   
    adox   r13, r15 
    adox   r14, rax
           
    mov    rdx, [rcx+48]    
    MULSUB64x384 [reg_p1+48], r8, r9, r10, r11, r12, r13, r14, r15, rbx
    mov    [reg_p3], r8            // Result c0
    
    // [r9:r14, r8] <- z = a0 x b01 - a1 x b11 + z 
    xor    r8, r8 
	bt     r14, 63
    sbb    r8, 0
    mov    rdx, [rcx+8]
    MULADD64x384 [reg_p1], r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    rdx, [rcx+56]    
    MULSUB64x384 [reg_p1+48], r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    [reg_p3+8], r9          // Result c1
    
    // [r10:r14, r8:r9] <- z = a0 x b02 - a1 x b12 + z 
    xor    r9, r9 
	bt     r8, 63
    sbb    r9, 0
    mov    rdx, [rcx+16]
    MULADD64x384 [reg_p1], r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, [rcx+64]    
    MULSUB64x384 [reg_p1+48], r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    [reg_p3+16], r10        // Result c2
    
    // [r11:r14, r8:r10] <- z = a0 x b03 - a1 x b13 + z
    xor    r10, r10 
	bt     r9, 63
    sbb    r10, 0
    mov    rdx, [rcx+24]
    MULADD64x384 [reg_p1], r11, r12, r13, r14, r8, r9, r10, r15, rbx
    mov    rdx, [rcx+72]    
    MULSUB64x384 [reg_p1+48], r11, r12, r13, r14, r8, r9, r10, r15, rbx
    mov    [reg_p3+24], r11        // Result c3
    
    // [r12:r14, r8:r11] <- z = a0 x b04 - a1 x b14 + z 
    xor    r11, r11 
	bt     r10, 63
    sbb    r11, 0
    mov    rdx, [rcx+32]
    MULADD64x384 [reg_p1], r12, r13, r14, r8, r9, r10, r11, r15, rbx
    mov    rdx, [rcx+80]    
    MULSUB64x384 [reg_p1+48], r12, r13, r14, r8, r9, r10, r11, r15, rbx
    mov    [reg_p3+32], r12        // Result c4
    
    // [r13:r14, r8:r12] <- z = a0 x b05 - a1 x b15 + z 
    xor    r12, r12 
	bt     r11, 63
    sbb    r12, 0
    mov    rdx, [rcx+40]
    MULADD64x384 [reg_p1], r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, [rcx+88]    
    MULSUB64x384 [reg_p1+48], r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    [reg_p3+40], r13        // Result c5
    xor    rax, rax 
	bt     r12, 63
    sbb    rax, 0                                    

    // Final correction if partial result < 0
    mov    r13, [rip+pdiv4]
    mov    rbx, [rip+pdiv4+8]
    mov    rcx, [rip+pdiv4+16]
    mov    rdx, [rip+pdiv4+24]
    mov    r15, [rip+pdiv4+32]
    mov    rsi, [rip+pdiv4+40]
    mov    rbp, [rip+pdiv4+48]
    and    r13, rax
    and    rbx, rax
    and    rcx, rax
    and    rdx, rax
    and    r15, rax
    and    rsi, rax
    and    rbp, rax
	mov    rax, [reg_p3+40] 
	add    rax, r13
    adc    r14, rbx
    adc    r8, rcx
    adc    r9, rdx
    adc    r10, r15
    adc    r11, rsi
    adc    r12, rbp
	
    mov    [reg_p3+40], rax  
    mov    [reg_p3+48], r14          
    mov    [reg_p3+56], r8        
    mov    [reg_p3+64], r9         
    mov    [reg_p3+72], r10      
    mov    [reg_p3+80], r11     
    mov    [reg_p3+88], r12
	pop    rbp
    pop    rbx
    pop    r15
    pop    r14
    pop    r13
    pop    r12
    ret
	
#if 0
///////////////////////////////////////////////////////////////// MACRO
// Doubling some coefficients
/////////////////////////////////////////////////////////////////
.global fpdbl377_asm
fpdbl377_asm:  
  mov    r8, [reg_p1]
  mov    r9, [reg_p1+8]
  mov    r10, [reg_p1+16]
  mov    r11, [reg_p1+24]
  mov    rax, [reg_p1+32]
  mov    rcx, [reg_p1+40]
  add    r8, r8
  adc    r9, r9
  adc    r10, r10
  adc    r11, r11
  adc    rax, rax
  adc    rcx, rcx
  mov    [reg_p2], r8
  mov    [reg_p2+8], r9 
  mov    [reg_p2+16], r10 
  mov    [reg_p2+24], r11
  mov    [reg_p2+32], rax 
  mov    [reg_p2+40], rcx
  ret

///////////////////////////////////////////////////////////////// MACRO
// z = z - a x bi
// Inputs: base memory pointer M1 (a),
//         bi pre-stored in rdx,
//         accumulator z in [Z0:Z5]    ***************************************** CHANGE THIS DESCRIPTION
// Output: [Z0:Z6]
// Temps:  regs T0:T1
/////////////////////////////////////////////////////////////////
.macro MULADD384x384 A0, B0, A1, B1, A2, B2, A3, B3, A4, B4, A5, B5, C   
    push   r12
    push   r13 
    push   r14  
    push   r15  
    push   rbx  
    push   rbp
    mov    rcx, reg_p2
	  
    // [r8:r14] <- z = a10 x b20
    mov    rdx, \B0
    mulx   r9, r8, \A0        
    xor    rax, rax   
    mulx   r10, r11, 8\A0    
    adox   r9, r11        
    mulx   r11, r12, 16\A0  
    adox   r10, r12        
    mulx   r12, r13, 24\A0 
    adox   r11, r13       
    mulx   r13, r14, 32\A0
    adox   r12, r14      
    mulx   r14, r15, 40\A0  
    adox   r13, r15 
    adox   r14, rax
                     
    mov    rdx, \B1    
    MULADD64x384 \A1, r8, r9, r10, r11, r12, r13, r14, r15, rbx            
    mov    rdx, \B2    
    MULADD64x384 \A2, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B3    
    MULADD64x384 \A3, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B4    
    MULADD64x384 \A4, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B5   
    MULADD64x384 \A5, r8, r9, r10, r11, r12, r13, r14, r15, rbx
    // [r9:r14] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   rbp, rdx, r8             // rdx <- z0
    MULADD64x384 [rip+p0], r8, r9, r10, r11, r12, r13, r14, r15, rbx
	xor    r8, r8
	//mov    r8, 0
	//bt     r14, 63
    //sbb    r8, 0
    
    // [r9:r14, r8] <- z = a0 x b01 - a1 x b11 + z 
    mov    rdx, 8\B0
    MULADD64x384 \A0, r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    rdx, 8\B1
    MULADD64x384 \A1, r9, r10, r11, r12, r13, r14, r8, r15, rbx         
    mov    rdx, 8\B2    
    MULADD64x384 \A2, r9, r10, r11, r12, r13, r14, r8, r15, rbx  
    mov    rdx, 8\B3
    MULADD64x384 \A3, r9, r10, r11, r12, r13, r14, r8, r15, rbx 
    mov    rdx, 8\B4
    MULADD64x384 \A4, r9, r10, r11, r12, r13, r14, r8, r15, rbx 
    mov    rdx, 8\B5
    MULADD64x384 \A5, r9, r10, r11, r12, r13, r14, r8, r15, rbx
    // [r10:r14, r8] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbp, rdx, r9             // rdx <- z0
    MULADD64x384 [rip+p0], r9, r10, r11, r12, r13, r14, r8, r15, rbx
	xor    r9, r9
    //mov    r9, 0
	//bt     r8, 63
    //sbb    r9, 0
    
    // [r10:r14, r8:r9] <- z = a0 x b02 - a1 x b12 + z
    mov    rdx, 16\B0
    MULADD64x384 \A0, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B1
    MULADD64x384 \A1, r10, r11, r12, r13, r14, r8, r9, r15, rbx  
    mov    rdx, 16\B2    
    MULADD64x384 \A2, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B3
    MULADD64x384 \A3, r10, r11, r12, r13, r14, r8, r9, r15, rbx 
    mov    rdx, 16\B4
    MULADD64x384 \A4, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B5
    MULADD64x384 \A5, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    // [r11:r14, r8:r9] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbp, rdx, r10           // rdx <- z0
    MULADD64x384 [rip+p0], r10, r11, r12, r13, r14, r8, r9, r15, rbx
	xor    r10, r10
    //mov    r10, 0
	//bt     r9, 63
    //sbb    r10, 0
    
    // [r11:r14, r8:r10] <- z = a0 x b03 - a1 x b13 + z
    mov    rdx, 24\B0
    MULADD64x384 \A0, r11, r12, r13, r14, r8, r9, r10, r15, rbx
    mov    rdx, 24\B1
    MULADD64x384 \A1, r11, r12, r13, r14, r8, r9, r10, r15, rbx         
    mov    rdx, 24\B2    
    MULADD64x384 \A2, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B3
    MULADD64x384 \A3, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B4
    MULADD64x384 \A4, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B5
    MULADD64x384 \A5, r11, r12, r13, r14, r8, r9, r10, r15, rbx 
    // [r12:r14, r8:r10] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbp, rdx, r11           // rdx <- z0
    MULADD64x384 [rip+p0], r11, r12, r13, r14, r8, r9, r10, r15, rbx
	xor    r11, r11
    //mov    r11, 0
	//bt     r10, 63
    //sbb    r11, 0
    
    // [r12:r14, r8:r11] <- z = a0 x b04 - a1 x b14 + z 
    mov    rdx, 32\B0
    MULADD64x384 \A0, r12, r13, r14, r8, r9, r10, r11, r15, rbx
    mov    rdx, 32\B1
    MULADD64x384 \A1, r12, r13, r14, r8, r9, r10, r11, r15, rbx         
    mov    rdx, 32\B2   
    MULADD64x384 \A2, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B3 
    MULADD64x384 \A3, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B4
    MULADD64x384 \A4, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B5  
    MULADD64x384 \A5, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    // [r13:r14, r8:r11] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbp, rdx, r12           // rdx <- z0
    MULADD64x384 [rip+p0], r12, r13, r14, r8, r9, r10, r11, r15, rbx
	xor    r12, r12
    //mov    r12, 0
	//bt     r11, 63
    //sbb    r12, 0
    
    // [r13:r14, r8:r12] <- z = a0 x b05 - a1 x b15 + z 
    mov    rdx, 40\B0
    MULADD64x384 \A0, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B1
    MULADD64x384 \A1, r13, r14, r8, r9, r10, r11, r12, r15, rbx      
    mov    rdx, 40\B2
    MULADD64x384 \A2, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B3
    MULADD64x384 \A3, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B4
    MULADD64x384 \A4, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B5
    MULADD64x384 \A5, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    // [r14, r8:r12] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbp, rdx, r13           // rdx <- z0
    MULADD64x384 [rip+p0], r13, r14, r8, r9, r10, r11, r12, r15, rbx
    //mov    rax, 0
	//bt     r12, 63
    //sbb    rax, 0                                    /////////////// COULD BE SIMPLIFIED  
	/*
    // Correction if result < 0
	mov    r13, [rip+p0]
	mov    r15, [rip+p0+8]
	mov    rbx, [rip+p0+16]
	mov    rdi, [rip+p0+24]
	mov    rdx, [rip+p0+32]
	mov    rsi, [rip+p0+40]
	and    r13, rax
	and    r15, rax
	and    rbx, rax
	and    rdi, rax
	and    rdx, rax
	and    rsi, rax
	add    r14, r13
	adc    r8, r15
	adc    r9, rbx
	adc    r10, rdi
	adc    r11, rdx
	adc    r12, rsi
	*/
	// Final correction                        ////////////// COULD THIS ME REMOVED? RANGE TO [0, 2p]?
	xor    rax, rax
	mov    r13, [rip+p0]
	mov    r15, [rip+p1]
	mov    rbx, [rip+p2]
	mov    rcx, [rip+p3]
	mov    rdx, [rip+p4]
	mov    rsi, [rip+p5]
	sub    r14, r13
	sbb    r8, r15
	sbb    r9, rbx
	sbb    r10, rcx
	sbb    r11, rdx
	sbb    r12, rsi
	sbb    rax, 0
	and    r13, rax
	and    r15, rax
	and    rbx, rax
	and    rcx, rax
	and    rdx, rax
	and    rsi, rax
	add    r14, r13
	adc    r8, r15
	adc    r9, rbx
	adc    r10, rcx
	adc    r11, rdx
	adc    r12, rsi
    
    mov    \C, r14          
    mov    8\C, r8         
    mov    16\C, r9         
    mov    24\C, r10      
    mov    32\C, r11      
    mov    40\C, r12
    pop    rbp
    pop    rbx
    pop    r15
    pop    r14
    pop    r13
    pop    r12
.endm
  
//***********************************************************************
//  Multiplication in GF(p^6), first term
//  Operation: c [reg_p3] = a0 x b0 + E(a1 x b2 + a2 x b1)
//  Inputs: a = [a2, a1, a0] stored in [reg_p1] 
//          b = [b2, b1, b0] stored in [reg_p2] 
//  Output: c stored in [reg_p3]
//*********************************************************************** 
  .global fp6mul377c0_asm
fp6mul377c0_asm: 
	MULADD384x384 [reg_p1], [rcx], [reg_p3+48], [rcx+240], [reg_p3+96], [rcx+192], [reg_p3+144], [rcx+144], [reg_p3+192], [rcx+96], [reg_p3+240], [rcx+48], [reg_p3] 
	ret
	
  .global fp6mul377c1_asm
fp6mul377c1_asm:
	MULADD384x384 [reg_p1], [rcx+48], [reg_p1+48], [rcx], [reg_p3+96], [rcx+240], [reg_p3+144], [rcx+192], [reg_p3+192], [rcx+144], [reg_p3+240], [rcx+96], [reg_p3] 
    ret
	
  .global fp6mul377c2_asm
fp6mul377c2_asm: 
	MULADD384x384 [reg_p1], [rcx+96], [reg_p1+48], [rcx+48], [reg_p1+96], [rcx], [reg_p3+144], [rcx+240], [reg_p3+192], [rcx+192], [reg_p3+240], [rcx+144], [reg_p3] 
    ret
	
  .global fp6mul377c3_asm
fp6mul377c3_asm:
	MULADD384x384 [reg_p1], [rcx+144], [reg_p1+48], [rcx+96], [reg_p1+96], [rcx+48], [reg_p1+144], [rcx], [reg_p3+192], [rcx+240], [reg_p3+240], [rcx+192], [reg_p3] 
    ret
	
  .global fp6mul377c4_asm
fp6mul377c4_asm:
	MULADD384x384 [reg_p1], [rcx+192], [reg_p1+48], [rcx+144], [reg_p1+96], [rcx+96], [reg_p1+144], [rcx+48], [reg_p1+192], [rcx], [reg_p3+240], [rcx+240], [reg_p3] 
    ret
	
  .global fp6mul377c5_asm
fp6mul377c5_asm: 
	MULADD384x384 [reg_p1], [rcx+240], [reg_p1+48], [rcx+192], [reg_p1+96], [rcx+144], [reg_p1+144], [rcx+96], [reg_p1+192], [rcx+48], [reg_p1+240], [rcx], [reg_p3] 
    ret
#endif	

///////////////////////////////////////////////////////////////// MACRO
// Precomputing some values
/////////////////////////////////////////////////////////////////
.global precomp381_asm
precomp381_asm: 
  push   r12
  push   r13 

  // bi + bii
  mov    r8, [reg_p1]
  mov    r9, [reg_p1+8]
  mov    r10, [reg_p1+16]
  mov    rax, [reg_p1+48]
  mov    rcx, [reg_p1+56]
  mov    rdx, [reg_p1+64]
  add    rax, r8
  adc    rcx, r9
  adc    rdx, r10
  mov    [reg_p3], rax
  mov    [reg_p3+8], rcx
  mov    [reg_p3+16], rdx
  mov    r11, [reg_p1+24]
  mov    r12, [reg_p1+32]
  mov    r13, [reg_p1+40]
  mov    rax, [reg_p1+72]
  mov    rcx, [reg_p1+80]
  mov    rdx, [reg_p1+88]
  adc    rax, r11
  adc    rcx, r12
  adc    rdx, r13
  mov    [reg_p3+24], rax
  mov    [reg_p3+32], rcx
  mov    [reg_p3+40], rdx

  // bi - bii
  xor    rax, rax
  sub    r8, [reg_p1+48] 
  sbb    r9, [reg_p1+56] 
  sbb    r10, [reg_p1+64] 
  sbb    r11, [reg_p1+72]
  sbb    r12, [reg_p1+80] 
  sbb    r13, [reg_p1+88]
  sbb    rax, 0
  mov    rcx, [rip+p0]
  mov    rdx, [rip+p1]
  mov    rsi, [rip+p2]
  and    rcx, rax
  and    rdx, rax
  and    rsi, rax
  add    r8, rcx
  adc    r9, rdx
  adc    r10, rsi
  mov    [reg_p3+48], r8
  mov    [reg_p3+56], r9
  mov    [reg_p3+64], r10
  setc   r8b
  mov    rcx, [rip+p3]
  mov    rdx, [rip+p4]
  mov    rsi, [rip+p5]
  and    rcx, rax
  and    rdx, rax
  and    rsi, rax
  bt     r8, 0
  adc    r11, rcx
  adc    r12, rdx 
  adc    r13, rsi
  mov    [reg_p3+72], r11
  mov    [reg_p3+80], r12
  mov    [reg_p3+88], r13 

  pop    r13
  pop    r12  
  ret

///////////////////////////////////////////////////////////////// MACRO
// z = z - a x bi
// Inputs: base memory pointer M1 (a),
//         bi pre-stored in rdx,
//         accumulator z in [Z0:Z5]    ***************************************** CHANGE THIS DESCRIPTION
// Output: [Z0:Z6]
// Temps:  regs T0:T1
/////////////////////////////////////////////////////////////////
.macro FPMULADDSUB384x384 A0, B0, A1, B1, A2, B2, A3, B3, A4, B4, A5, B5, C
    mov    rcx, reg_p2
	  
    // [r8:r14] <- z = a00 x b00
    mov    rdx, \B0
    mulx   r9, r8, \A0        
    xor    rax, rax      
    push   r12
    mulx   r10, r11, 8\A0  
    push   r13   
    adox   r9, r11        
    mulx   r11, r12, 16\A0 
    push   r14  
    adox   r10, r12        
    mulx   r12, r13, 24\A0  
    push   r15 
    adox   r11, r13       
    mulx   r13, r14, 32\A0 
    push   rbx
    adox   r12, r14      
    mulx   r14, r15, 40\A0  
    adox   r13, r15 
    adox   r14, rax
                     
    mov    rdx, \B1    
    MULSUB64x384 \A1, r8, r9, r10, r11, r12, r13, r14, r15, rbx            
    mov    rdx, \B2    
    MULADD64x384 \A2, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B3    
    MULSUB64x384 \A3, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B4    
    MULADD64x384 \A4, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B5   
    MULSUB64x384 \A5, r8, r9, r10, r11, r12, r13, r14, r15, rbx
    // [r9:r14] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   rbx, rdx, r8             // rdx <- z0
    MULADD64x384 [rip+p0], r8, r9, r10, r11, r12, r13, r14, r15, rbx
	mov    r8, 0
	bt     r14, 63
    sbb    r8, 0
    
    // [r9:r14, r8] <- z = a0 x b01 - a1 x b11 + z 
    mov    rdx, 8\B0
    MULADD64x384 \A0, r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    rdx, 8\B1
    MULSUB64x384 \A1, r9, r10, r11, r12, r13, r14, r8, r15, rbx         
    mov    rdx, 8\B2    
    MULADD64x384 \A2, r9, r10, r11, r12, r13, r14, r8, r15, rbx  
    mov    rdx, 8\B3
    MULSUB64x384 \A3, r9, r10, r11, r12, r13, r14, r8, r15, rbx 
    mov    rdx, 8\B4
    MULADD64x384 \A4, r9, r10, r11, r12, r13, r14, r8, r15, rbx 
    mov    rdx, 8\B5
    MULSUB64x384 \A5, r9, r10, r11, r12, r13, r14, r8, r15, rbx
    // [r10:r14, r8] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r9             // rdx <- z0
    MULADD64x384 [rip+p0], r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    r9, 0
	bt     r8, 63
    sbb    r9, 0
    
    // [r10:r14, r8:r9] <- z = a0 x b02 - a1 x b12 + z
    mov    rdx, 16\B0
    MULADD64x384 \A0, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B1
    MULSUB64x384 \A1, r10, r11, r12, r13, r14, r8, r9, r15, rbx  
    mov    rdx, 16\B2    
    MULADD64x384 \A2, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B3
    MULSUB64x384 \A3, r10, r11, r12, r13, r14, r8, r9, r15, rbx 
    mov    rdx, 16\B4
    MULADD64x384 \A4, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B5
    MULSUB64x384 \A5, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    // [r11:r14, r8:r9] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r10           // rdx <- z0
    MULADD64x384 [rip+p0], r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    r10, 0
	bt     r9, 63
    sbb    r10, 0
    
    // [r11:r14, r8:r10] <- z = a0 x b03 - a1 x b13 + z
    mov    rdx, 24\B0
    MULADD64x384 \A0, r11, r12, r13, r14, r8, r9, r10, r15, rbx
    mov    rdx, 24\B1
    MULSUB64x384 \A1, r11, r12, r13, r14, r8, r9, r10, r15, rbx         
    mov    rdx, 24\B2    
    MULADD64x384 \A2, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B3
    MULSUB64x384 \A3, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B4
    MULADD64x384 \A4, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B5
    MULSUB64x384 \A5, r11, r12, r13, r14, r8, r9, r10, r15, rbx 
    // [r12:r14, r8:r10] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r11           // rdx <- z0
    MULADD64x384 [rip+p0], r11, r12, r13, r14, r8, r9, r10, r15, rbx
    mov    r11, 0
	bt     r10, 63
    sbb    r11, 0
    
    // [r12:r14, r8:r11] <- z = a0 x b04 - a1 x b14 + z 
    mov    rdx, 32\B0
    MULADD64x384 \A0, r12, r13, r14, r8, r9, r10, r11, r15, rbx
    mov    rdx, 32\B1
    MULSUB64x384 \A1, r12, r13, r14, r8, r9, r10, r11, r15, rbx         
    mov    rdx, 32\B2   
    MULADD64x384 \A2, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B3 
    MULSUB64x384 \A3, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B4
    MULADD64x384 \A4, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B5  
    MULSUB64x384 \A5, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    // [r13:r14, r8:r11] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r12           // rdx <- z0
    MULADD64x384 [rip+p0], r12, r13, r14, r8, r9, r10, r11, r15, rbx
    mov    r12, 0
	bt     r11, 63
    sbb    r12, 0
    
    // [r13:r14, r8:r12] <- z = a0 x b05 - a1 x b15 + z 
    mov    rdx, 40\B0
    MULADD64x384 \A0, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B1
    MULSUB64x384 \A1, r13, r14, r8, r9, r10, r11, r12, r15, rbx      
    mov    rdx, 40\B2
    MULADD64x384 \A2, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B3
    MULSUB64x384 \A3, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B4
    MULADD64x384 \A4, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B5
    MULSUB64x384 \A5, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    // [r14, r8:r12] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r13           // rdx <- z0
    MULADD64x384 [rip+p0], r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rax, 0
	bt     r12, 63
    sbb    rax, 0                                    /////////////// COULD BE SIMPLIFIED  
	
    // Correction if result < 0
	mov    r13, [rip+p0]
	mov    r15, [rip+p1]
	mov    rbx, [rip+p2]
	mov    rcx, [rip+p3]
	mov    rdx, [rip+p4]
	mov    rsi, [rip+p5]
	and    r13, rax
	and    r15, rax
	and    rbx, rax
	and    rcx, rax
	and    rdx, rax
	and    rsi, rax
	add    r14, r13
	adc    r8, r15
	adc    r9, rbx
	adc    r10, rcx
	adc    r11, rdx
	adc    r12, rsi
	
	// Final correction                        ////////////// COULD THIS ME REMOVED? RANGE TO [0, 2p]?
	xor    rax, rax
	mov    r13, [rip+p0]
	mov    r15, [rip+p1]
	mov    rbx, [rip+p2]
	mov    rcx, [rip+p3]
	mov    rdx, [rip+p4]
	mov    rsi, [rip+p5]
	sub    r14, r13
	sbb    r8, r15
	sbb    r9, rbx
	sbb    r10, rcx
	sbb    r11, rdx
	sbb    r12, rsi
	sbb    rax, 0
	and    r13, rax
	and    r15, rax
	and    rbx, rax
	and    rcx, rax
	and    rdx, rax
	and    rsi, rax
	add    r14, r13
	adc    r8, r15
	adc    r9, rbx
	adc    r10, rcx
	adc    r11, rdx
	adc    r12, rsi
    
    mov    \C, r14          
    mov    8\C, r8         
    mov    16\C, r9         
    mov    24\C, r10      
    mov    32\C, r11      
    mov    40\C, r12
    pop    rbx
    pop    r15
    pop    r14
    pop    r13
    pop    r12
.endm

.macro FPMULADD384x384 A0, B0, A1, B1, A2, B2, A3, B3, A4, B4, A5, B5, C  
    mov    rcx, reg_p2
	  
    // [r8:r14] <- z = a00 x b00
    mov    rdx, \B0
    mulx   r9, r8, \A0        
    xor    rax, rax  
    push   r12  
    mulx   r10, r11, 8\A0 
    push   r13    
    adox   r9, r11        
    mulx   r11, r12, 16\A0 
    push   r14  
    adox   r10, r12        
    mulx   r12, r13, 24\A0  
    push   r15 
    adox   r11, r13       
    mulx   r13, r14, 32\A0 
    push   rbx
    adox   r12, r14      
    mulx   r14, r15, 40\A0  
    adox   r13, r15 
    adox   r14, rax
                     
    mov    rdx, \B1    
    MULADD64x384 \A1, r8, r9, r10, r11, r12, r13, r14, r15, rbx            
    mov    rdx, \B2    
    MULADD64x384 \A2, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B3    
    MULADD64x384 \A3, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B4    
    MULADD64x384 \A4, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B5   
    MULADD64x384 \A5, r8, r9, r10, r11, r12, r13, r14, r15, rbx
    // [r9:r14] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   rbx, rdx, r8             // rdx <- z0
    MULADD64x384 [rip+p0], r8, r9, r10, r11, r12, r13, r14, r15, rbx
	xor    r8, r8
    
    // [r9:r14, r8] <- z = a0 x b01 - a1 x b11 + z 
    mov    rdx, 8\B0
    MULADD64x384 \A0, r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    rdx, 8\B1
    MULADD64x384 \A1, r9, r10, r11, r12, r13, r14, r8, r15, rbx         
    mov    rdx, 8\B2    
    MULADD64x384 \A2, r9, r10, r11, r12, r13, r14, r8, r15, rbx  
    mov    rdx, 8\B3
    MULADD64x384 \A3, r9, r10, r11, r12, r13, r14, r8, r15, rbx 
    mov    rdx, 8\B4
    MULADD64x384 \A4, r9, r10, r11, r12, r13, r14, r8, r15, rbx 
    mov    rdx, 8\B5
    MULADD64x384 \A5, r9, r10, r11, r12, r13, r14, r8, r15, rbx
    // [r10:r14, r8] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r9             // rdx <- z0
    MULADD64x384 [rip+p0], r9, r10, r11, r12, r13, r14, r8, r15, rbx
	xor    r9, r9
    
    // [r10:r14, r8:r9] <- z = a0 x b02 - a1 x b12 + z
    mov    rdx, 16\B0
    MULADD64x384 \A0, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B1
    MULADD64x384 \A1, r10, r11, r12, r13, r14, r8, r9, r15, rbx  
    mov    rdx, 16\B2    
    MULADD64x384 \A2, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B3
    MULADD64x384 \A3, r10, r11, r12, r13, r14, r8, r9, r15, rbx 
    mov    rdx, 16\B4
    MULADD64x384 \A4, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B5
    MULADD64x384 \A5, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    // [r11:r14, r8:r9] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r10           // rdx <- z0
    MULADD64x384 [rip+p0], r10, r11, r12, r13, r14, r8, r9, r15, rbx
	xor    r10, r10
    
    // [r11:r14, r8:r10] <- z = a0 x b03 - a1 x b13 + z
    mov    rdx, 24\B0
    MULADD64x384 \A0, r11, r12, r13, r14, r8, r9, r10, r15, rbx
    mov    rdx, 24\B1
    MULADD64x384 \A1, r11, r12, r13, r14, r8, r9, r10, r15, rbx         
    mov    rdx, 24\B2    
    MULADD64x384 \A2, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B3
    MULADD64x384 \A3, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B4
    MULADD64x384 \A4, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B5
    MULADD64x384 \A5, r11, r12, r13, r14, r8, r9, r10, r15, rbx 
    // [r12:r14, r8:r10] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r11           // rdx <- z0
    MULADD64x384 [rip+p0], r11, r12, r13, r14, r8, r9, r10, r15, rbx
	xor    r11, r11
    
    // [r12:r14, r8:r11] <- z = a0 x b04 - a1 x b14 + z 
    mov    rdx, 32\B0
    MULADD64x384 \A0, r12, r13, r14, r8, r9, r10, r11, r15, rbx
    mov    rdx, 32\B1
    MULADD64x384 \A1, r12, r13, r14, r8, r9, r10, r11, r15, rbx         
    mov    rdx, 32\B2   
    MULADD64x384 \A2, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B3 
    MULADD64x384 \A3, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B4
    MULADD64x384 \A4, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B5  
    MULADD64x384 \A5, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    // [r13:r14, r8:r11] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r12           // rdx <- z0
    MULADD64x384 [rip+p0], r12, r13, r14, r8, r9, r10, r11, r15, rbx
	xor    r12, r12
    
    // [r13:r14, r8:r12] <- z = a0 x b05 - a1 x b15 + z 
    mov    rdx, 40\B0
    MULADD64x384 \A0, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B1
    MULADD64x384 \A1, r13, r14, r8, r9, r10, r11, r12, r15, rbx      
    mov    rdx, 40\B2
    MULADD64x384 \A2, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B3
    MULADD64x384 \A3, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B4
    MULADD64x384 \A4, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B5
    MULADD64x384 \A5, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    // [r14, r8:r12] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r13           // rdx <- z0
    MULADD64x384 [rip+p0], r13, r14, r8, r9, r10, r11, r12, r15, rbx
    
	// Final correction                        ////////////// COULD THIS ME REMOVED? RANGE TO [0, 2p]?
	xor    rax, rax
	mov    r13, [rip+p0]
	mov    r15, [rip+p1]
	mov    rbx, [rip+p2]
	mov    rcx, [rip+p3]
	mov    rdx, [rip+p4]
	mov    rsi, [rip+p5]
	sub    r14, r13
	sbb    r8, r15
	sbb    r9, rbx
	sbb    r10, rcx
	sbb    r11, rdx
	sbb    r12, rsi
	sbb    rax, 0
	and    r13, rax
	and    r15, rax
	and    rbx, rax
	and    rcx, rax
	and    rdx, rax
	and    rsi, rax
	add    r14, r13
	adc    r8, r15
	adc    r9, rbx
	adc    r10, rcx
	adc    r11, rdx
	adc    r12, rsi
    
    mov    \C, r14          
    mov    8\C, r8         
    mov    16\C, r9         
    mov    24\C, r10      
    mov    32\C, r11      
    mov    40\C, r12
    pop    rbx
    pop    r15
    pop    r14
    pop    r13
    pop    r12
.endm
  
//***********************************************************************
//  Multiplication in GF(p^6), first term
//  Operation: c [reg_p3] = a0 x b0 + E(a1 x b2 + a2 x b1)
//  Inputs: a = [a2, a1, a0] stored in [reg_p1] 
//          b = [b2, b1, b0] stored in [reg_p2] 
//  Output: c stored in [reg_p3]
//*********************************************************************** 
  .global fp6mul381c0_asm
fp6mul381c0_asm: 
	FPMULADDSUB384x384 [reg_p1], [rcx], [reg_p1+48], [rcx+48], [reg_p1+96], [reg_p3+432], [reg_p1+144], [reg_p3+384], [reg_p1+192], [reg_p3+336], [reg_p1+240], [reg_p3+288], [reg_p3] 
	ret
	
  .global fp6mul381c1_asm
fp6mul381c1_asm:
	FPMULADD384x384 [reg_p1], [rcx+48], [reg_p1+48], [rcx], [reg_p1+96], [reg_p3+384], [reg_p1+144], [reg_p3+432], [reg_p1+192], [reg_p3+288], [reg_p1+240], [reg_p3+336], [reg_p3+48] 
    ret
	
  .global fp6mul381c2_asm
fp6mul381c2_asm: 
	FPMULADDSUB384x384 [reg_p1], [rcx+96], [reg_p1+48], [rcx+144], [reg_p1+96], [rcx], [reg_p1+144], [rcx+48], [reg_p1+192], [reg_p3+432], [reg_p1+240], [reg_p3+384], [reg_p3+96] 
    ret
	
  .global fp6mul381c3_asm
fp6mul381c3_asm:
	FPMULADD384x384 [reg_p1], [rcx+144], [reg_p1+48], [rcx+96], [reg_p1+96], [rcx+48], [reg_p1+144], [rcx], [reg_p1+192], [reg_p3+384], [reg_p1+240], [reg_p3+432], [reg_p3+144] 
    ret
	
  .global fp6mul381c4_asm
fp6mul381c4_asm:
	FPMULADDSUB384x384 [reg_p1], [rcx+192], [reg_p1+48], [rcx+240], [reg_p1+96], [rcx+96], [reg_p1+144], [rcx+144], [reg_p1+192], [rcx], [reg_p1+240], [rcx+48], [reg_p3+192] 
    ret
	
  .global fp6mul381c5_asm
fp6mul381c5_asm: 
	FPMULADD384x384 [reg_p1], [rcx+240], [reg_p1+48], [rcx+192], [reg_p1+96], [rcx+144], [reg_p1+144], [rcx+96], [reg_p1+192], [rcx+48], [reg_p1+240], [rcx], [reg_p3+240] 
    ret


#if 0
///////////////////////////// IMPLEMENTATION WITH NO REDUCTION
////////////////////////////////////////////////////////// NOT AS FAST AS BASIC VERSION W/O LAZYR

///////////////////////////////////////////////////////////////// MACRO
// z = z - a x bi
// Inputs: base memory pointer M1 (a),
//         bi pre-stored in rdx,
//         accumulator z in [Z0:Z5]    ***************************************** CHANGE THIS DESCRIPTION
// Output: [Z0:Z6]
// Temps:  regs T0:T1
/////////////////////////////////////////////////////////////////
.macro MULADDSUB384x384 A0, B0, A1, B1, A2, B2, A3, B3, A4, B4, A5, B5, C
    mov    rcx, reg_p2
	  
    // [r8:r14] <- z = a00 x b00
    mov    rdx, \B0
    mulx   r9, r8, \A0        
    xor    rax, rax      
    push   r12
    mulx   r10, r11, 8\A0  
    push   r13   
    adox   r9, r11        
    mulx   r11, r12, 16\A0 
    push   r14  
    adox   r10, r12        
    mulx   r12, r13, 24\A0  
    push   r15 
    adox   r11, r13       
    mulx   r13, r14, 32\A0 
    push   rbx
    adox   r12, r14      
    mulx   r14, r15, 40\A0  
    adox   r13, r15 
    adox   r14, rax
                     
    mov    rdx, \B1    
    MULSUB64x384 \A1, r8, r9, r10, r11, r12, r13, r14, r15, rbx            
    mov    rdx, \B2    
    MULADD64x384 \A2, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B3    
    MULSUB64x384 \A3, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B4    
    MULADD64x384 \A4, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B5   
    MULSUB64x384 \A5, r8, r9, r10, r11, r12, r13, r14, r15, rbx
    mov    \C, r8 
    
    // [r9:r14, r8] <- z = a0 x b01 - a1 x b11 + z 
    mov    rdx, 8\B0
    MULADD64x384 \A0, r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    rdx, 8\B1
    MULSUB64x384 \A1, r9, r10, r11, r12, r13, r14, r8, r15, rbx         
    mov    rdx, 8\B2    
    MULADD64x384 \A2, r9, r10, r11, r12, r13, r14, r8, r15, rbx  
    mov    rdx, 8\B3
    MULSUB64x384 \A3, r9, r10, r11, r12, r13, r14, r8, r15, rbx 
    mov    rdx, 8\B4
    MULADD64x384 \A4, r9, r10, r11, r12, r13, r14, r8, r15, rbx 
    mov    rdx, 8\B5
    MULSUB64x384 \A5, r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    8\C, r9
    
    // [r10:r14, r8:r9] <- z = a0 x b02 - a1 x b12 + z
    mov    rdx, 16\B0
    MULADD64x384 \A0, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B1
    MULSUB64x384 \A1, r10, r11, r12, r13, r14, r8, r9, r15, rbx  
    mov    rdx, 16\B2    
    MULADD64x384 \A2, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B3
    MULSUB64x384 \A3, r10, r11, r12, r13, r14, r8, r9, r15, rbx 
    mov    rdx, 16\B4
    MULADD64x384 \A4, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B5
    MULSUB64x384 \A5, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    16\C, r10
    
    // [r11:r14, r8:r10] <- z = a0 x b03 - a1 x b13 + z
    mov    rdx, 24\B0
    MULADD64x384 \A0, r11, r12, r13, r14, r8, r9, r10, r15, rbx
    mov    rdx, 24\B1
    MULSUB64x384 \A1, r11, r12, r13, r14, r8, r9, r10, r15, rbx         
    mov    rdx, 24\B2    
    MULADD64x384 \A2, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B3
    MULSUB64x384 \A3, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B4
    MULADD64x384 \A4, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B5
    MULSUB64x384 \A5, r11, r12, r13, r14, r8, r9, r10, r15, rbx 
    mov    24\C, r11
    
    // [r12:r14, r8:r11] <- z = a0 x b04 - a1 x b14 + z 
    mov    rdx, 32\B0
    MULADD64x384 \A0, r12, r13, r14, r8, r9, r10, r11, r15, rbx
    mov    rdx, 32\B1
    MULSUB64x384 \A1, r12, r13, r14, r8, r9, r10, r11, r15, rbx         
    mov    rdx, 32\B2   
    MULADD64x384 \A2, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B3 
    MULSUB64x384 \A3, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B4
    MULADD64x384 \A4, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B5  
    MULSUB64x384 \A5, r12, r13, r14, r8, r9, r10, r11, r15, rbx
    mov    32\C, r12
    
    // [r13:r14, r8:r12] <- z = a0 x b05 - a1 x b15 + z 
    mov    rdx, 40\B0
    MULADD64x384 \A0, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B1
    MULSUB64x384 \A1, r13, r14, r8, r9, r10, r11, r12, r15, rbx      
    mov    rdx, 40\B2
    MULADD64x384 \A2, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B3
    MULSUB64x384 \A3, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B4
    MULADD64x384 \A4, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B5
    MULSUB64x384 \A5, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    40\C, r13       // Result c5
    xor    rax, rax 
	bt     r12, 63
    sbb    rax, 0             
	
    // Correction if result < 0
	mov    r13, [rip+p0]
	mov    r15, [rip+p1]
	mov    rbx, [rip+p2]
	mov    rcx, [rip+p3]
	mov    rdx, [rip+p4]
	mov    rsi, [rip+p5]
	and    r13, rax
	and    r15, rax
	and    rbx, rax
	and    rcx, rax
	and    rdx, rax
	and    rsi, rax
	add    r14, r13
	adc    r8, r15
	adc    r9, rbx
	adc    r10, rcx
	adc    r11, rdx
	adc    r12, rsi
	
	// Final correction                        ////////////// COULD THIS ME REMOVED? RANGE TO [0, 2p]?
	xor    rax, rax
	mov    r13, [rip+p0]
	mov    r15, [rip+p1]
	mov    rbx, [rip+p2]
	mov    rcx, [rip+p3]
	mov    rdx, [rip+p4]
	mov    rsi, [rip+p5]
	sub    r14, r13
	sbb    r8, r15
	sbb    r9, rbx
	sbb    r10, rcx
	sbb    r11, rdx
	sbb    r12, rsi
	sbb    rax, 0
	and    r13, rax
	and    r15, rax
	and    rbx, rax
	and    rcx, rax
	and    rdx, rax
	and    rsi, rax
	add    r14, r13
	adc    r8, r15
	adc    r9, rbx
	adc    r10, rcx
	adc    r11, rdx
	adc    r12, rsi
    
    mov    48\C, r14          
    mov    56\C, r8         
    mov    64\C, r9         
    mov    72\C, r10      
    mov    80\C, r11      
    mov    88\C, r12
    pop    rbx
    pop    r15
    pop    r14
    pop    r13
    pop    r12
.endm

.macro MULADD384x384 A0, B0, A1, B1, A2, B2, A3, B3, A4, B4, A5, B5, C  
    mov    rcx, reg_p2
	  
    // [r8:r14] <- z = a00 x b00
    mov    rdx, \B0
    mulx   r9, r8, \A0        
    xor    rax, rax  
    push   r12  
    mulx   r10, r11, 8\A0 
    push   r13    
    adox   r9, r11        
    mulx   r11, r12, 16\A0 
    push   r14  
    adox   r10, r12        
    mulx   r12, r13, 24\A0  
    push   r15 
    adox   r11, r13       
    mulx   r13, r14, 32\A0 
    push   rbx
    adox   r12, r14      
    mulx   r14, r15, 40\A0  
    adox   r13, r15 
    adox   r14, rax
                     
    mov    rdx, \B1    
    MULADD64x384 \A1, r8, r9, r10, r11, r12, r13, r14, r15, rbx            
    mov    rdx, \B2    
    MULADD64x384 \A2, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B3    
    MULADD64x384 \A3, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B4    
    MULADD64x384 \A4, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B5   
    MULADD64x384 \A5, r8, r9, r10, r11, r12, r13, r14, r15, rbx
    mov    \C, r8
    
    // [r9:r14, r8] <- z = a0 x b01 - a1 x b11 + z 
    mov    rdx, 8\B0
    MULADD64x384 \A0, r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    rdx, 8\B1
    MULADD64x384 \A1, r9, r10, r11, r12, r13, r14, r8, r15, rbx         
    mov    rdx, 8\B2    
    MULADD64x384 \A2, r9, r10, r11, r12, r13, r14, r8, r15, rbx  
    mov    rdx, 8\B3
    MULADD64x384 \A3, r9, r10, r11, r12, r13, r14, r8, r15, rbx 
    mov    rdx, 8\B4
    MULADD64x384 \A4, r9, r10, r11, r12, r13, r14, r8, r15, rbx 
    mov    rdx, 8\B5
    MULADD64x384 \A5, r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    8\C, r9
    
    // [r10:r14, r8:r9] <- z = a0 x b02 - a1 x b12 + z
    mov    rdx, 16\B0
    MULADD64x384 \A0, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B1
    MULADD64x384 \A1, r10, r11, r12, r13, r14, r8, r9, r15, rbx  
    mov    rdx, 16\B2    
    MULADD64x384 \A2, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B3
    MULADD64x384 \A3, r10, r11, r12, r13, r14, r8, r9, r15, rbx 
    mov    rdx, 16\B4
    MULADD64x384 \A4, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B5
    MULADD64x384 \A5, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    16\C, r10
    
    // [r11:r14, r8:r10] <- z = a0 x b03 - a1 x b13 + z
    mov    rdx, 24\B0
    MULADD64x384 \A0, r11, r12, r13, r14, r8, r9, r10, r15, rbx
    mov    rdx, 24\B1
    MULADD64x384 \A1, r11, r12, r13, r14, r8, r9, r10, r15, rbx         
    mov    rdx, 24\B2    
    MULADD64x384 \A2, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B3
    MULADD64x384 \A3, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B4
    MULADD64x384 \A4, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B5
    MULADD64x384 \A5, r11, r12, r13, r14, r8, r9, r10, r15, rbx
    mov    24\C, r11
    
    // [r12:r14, r8:r11] <- z = a0 x b04 - a1 x b14 + z 
    mov    rdx, 32\B0
    MULADD64x384 \A0, r12, r13, r14, r8, r9, r10, r11, r15, rbx
    mov    rdx, 32\B1
    MULADD64x384 \A1, r12, r13, r14, r8, r9, r10, r11, r15, rbx         
    mov    rdx, 32\B2   
    MULADD64x384 \A2, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B3 
    MULADD64x384 \A3, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B4
    MULADD64x384 \A4, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B5  
    MULADD64x384 \A5, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    32\C, r12
    
    // [r13:r14, r8:r12] <- z = a0 x b05 - a1 x b15 + z 
    mov    rdx, 40\B0
    MULADD64x384 \A0, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B1
    MULADD64x384 \A1, r13, r14, r8, r9, r10, r11, r12, r15, rbx      
    mov    rdx, 40\B2
    MULADD64x384 \A2, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B3
    MULADD64x384 \A3, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B4
    MULADD64x384 \A4, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B5
    MULADD64x384 \A5, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    40\C, r13
    
    mov    48\C, r14          
    mov    56\C, r8         
    mov    64\C, r9         
    mov    72\C, r10      
    mov    80\C, r11      
    mov    88\C, r12
    pop    rbx
    pop    r15
    pop    r14
    pop    r13
    pop    r12
.endm
  
//***********************************************************************
//  Multiplication in GF(p^6), no reduction
//  Operation: c [reg_p3] = a0 x b0 + E(a1 x b2 + a2 x b1)
//  Inputs: a = [a2, a1, a0] stored in [reg_p1] 
//          b = [b2, b1, b0] stored in [reg_p2] 
//  Output: c stored in [reg_p3]
//*********************************************************************** 
  .global fp6mulnr381c0_asm
fp6mulnr381c0_asm: 
	MULADDSUB384x384 [reg_p1], [rcx], [reg_p1+48], [rcx+48], [reg_p1+96], [reg_p3+720], [reg_p1+144], [reg_p3+672], [reg_p1+192], [reg_p3+624], [reg_p1+240], [reg_p3+576], [reg_p3] 
	ret
	
  .global fp6mulnr381c1_asm
fp6mulnr381c1_asm:
	MULADD384x384 [reg_p1], [rcx+48], [reg_p1+48], [rcx], [reg_p1+96], [reg_p3+672], [reg_p1+144], [reg_p3+720], [reg_p1+192], [reg_p3+576], [reg_p1+240], [reg_p3+624], [reg_p3+96] 
    ret
	
  .global fp6mulnr381c2_asm
fp6mulnr381c2_asm: 
	MULADDSUB384x384 [reg_p1], [rcx+96], [reg_p1+48], [rcx+144], [reg_p1+96], [rcx], [reg_p1+144], [rcx+48], [reg_p1+192], [reg_p3+720], [reg_p1+240], [reg_p3+672], [reg_p3+192] 
    ret
	
  .global fp6mulnr381c3_asm
fp6mulnr381c3_asm:
	MULADD384x384 [reg_p1], [rcx+144], [reg_p1+48], [rcx+96], [reg_p1+96], [rcx+48], [reg_p1+144], [rcx], [reg_p1+192], [reg_p3+672], [reg_p1+240], [reg_p3+720], [reg_p3+288] 
    ret
	
  .global fp6mulnr381c4_asm
fp6mulnr381c4_asm:
	MULADDSUB384x384 [reg_p1], [rcx+192], [reg_p1+48], [rcx+240], [reg_p1+96], [rcx+96], [reg_p1+144], [rcx+144], [reg_p1+192], [rcx], [reg_p1+240], [rcx+48], [reg_p3+384] 
    ret
	
  .global fp6mulnr381c5_asm
fp6mulnr381c5_asm: 
	MULADD384x384 [reg_p1], [rcx+240], [reg_p1+48], [rcx+192], [reg_p1+96], [rcx+144], [reg_p1+144], [rcx+96], [reg_p1+192], [rcx+48], [reg_p1+240], [rcx], [reg_p3+480] 
    ret
	
///////////////////////////// IMPLEMENTATION FULL ARITH FOR FP12MUL
////////////////////////////////////////////////////////// NOT AS FAST AS VERSION USING FULL ARITH FOR FP6
///////////////////////////////////////////////////////////////// MACRO
// z = z - a x bi
// Inputs: base memory pointer M1 (a),
//         bi pre-stored in rdx,
//         accumulator z in [Z0:Z5]    ***************************************** CHANGE THIS DESCRIPTION
// Output: [Z0:Z6]
// Temps:  regs T0:T1
/////////////////////////////////////////////////////////////////
.macro FP12MULADDSUB384x384 A0, B0, A1, B1, A2, B2, A3, B3, A4, B4, A5, B5, C
    mov    rcx, reg_p2
	  
    // [r8:r14] <- z = a00 x b00
    mov    rdx, \B0
    mulx   r9, r8, \A0        
    xor    rax, rax      
    push   r12
    mulx   r10, r11, 8\A0  
    push   r13   
    adox   r9, r11        
    mulx   r11, r12, 16\A0 
    push   r14  
    adox   r10, r12        
    mulx   r12, r13, 24\A0  
    push   r15 
    adox   r11, r13       
    mulx   r13, r14, 32\A0 
    push   rbx
    adox   r12, r14      
    mulx   r14, r15, 40\A0  
    adox   r13, r15 
    adox   r14, rax
                     
    mov    rdx, \B1    
    MULSUB64x384 \A1, r8, r9, r10, r11, r12, r13, r14, r15, rbx            
    mov    rdx, \B2    
    MULADD64x384 \A2, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B3    
    MULSUB64x384 \A3, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B4    
    MULADD64x384 \A4, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B5   
    MULSUB64x384 \A5, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B4    
    MULADD64x384 \A4, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B5   
    MULSUB64x384 \A5, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B4    
    MULADD64x384 \A4, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B5   
    MULSUB64x384 \A5, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B4    
    MULADD64x384 \A4, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B5   
    MULSUB64x384 \A5, r8, r9, r10, r11, r12, r13, r14, r15, rbx
    // [r9:r14] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   rbx, rdx, r8             // rdx <- z0
    MULADD64x384 [rip+p0], r8, r9, r10, r11, r12, r13, r14, r15, rbx
	mov    r8, 0
	bt     r14, 63
    sbb    r8, 0
    
    // [r9:r14, r8] <- z = a0 x b01 - a1 x b11 + z 
    mov    rdx, 8\B0
    MULADD64x384 \A0, r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    rdx, 8\B1
    MULSUB64x384 \A1, r9, r10, r11, r12, r13, r14, r8, r15, rbx         
    mov    rdx, 8\B2    
    MULADD64x384 \A2, r9, r10, r11, r12, r13, r14, r8, r15, rbx  
    mov    rdx, 8\B3
    MULSUB64x384 \A3, r9, r10, r11, r12, r13, r14, r8, r15, rbx 
    mov    rdx, 8\B4
    MULADD64x384 \A4, r9, r10, r11, r12, r13, r14, r8, r15, rbx 
    mov    rdx, 8\B5
    MULSUB64x384 \A5, r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    rdx, 8\B4
    MULADD64x384 \A4, r9, r10, r11, r12, r13, r14, r8, r15, rbx 
    mov    rdx, 8\B5
    MULSUB64x384 \A5, r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    rdx, 8\B4
    MULADD64x384 \A4, r9, r10, r11, r12, r13, r14, r8, r15, rbx 
    mov    rdx, 8\B5
    MULSUB64x384 \A5, r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    rdx, 8\B4
    MULADD64x384 \A4, r9, r10, r11, r12, r13, r14, r8, r15, rbx 
    mov    rdx, 8\B5
    MULSUB64x384 \A5, r9, r10, r11, r12, r13, r14, r8, r15, rbx
    // [r10:r14, r8] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r9             // rdx <- z0
    MULADD64x384 [rip+p0], r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    r9, 0
	bt     r8, 63
    sbb    r9, 0
    
    // [r10:r14, r8:r9] <- z = a0 x b02 - a1 x b12 + z
    mov    rdx, 16\B0
    MULADD64x384 \A0, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B1
    MULSUB64x384 \A1, r10, r11, r12, r13, r14, r8, r9, r15, rbx  
    mov    rdx, 16\B2    
    MULADD64x384 \A2, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B3
    MULSUB64x384 \A3, r10, r11, r12, r13, r14, r8, r9, r15, rbx 
    mov    rdx, 16\B4
    MULADD64x384 \A4, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B5
    MULSUB64x384 \A5, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B4
    MULADD64x384 \A4, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B5
    MULSUB64x384 \A5, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B4
    MULADD64x384 \A4, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B5
    MULSUB64x384 \A5, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B4
    MULADD64x384 \A4, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B5
    MULSUB64x384 \A5, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    // [r11:r14, r8:r9] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r10           // rdx <- z0
    MULADD64x384 [rip+p0], r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    r10, 0
	bt     r9, 63
    sbb    r10, 0
    
    // [r11:r14, r8:r10] <- z = a0 x b03 - a1 x b13 + z
    mov    rdx, 24\B0
    MULADD64x384 \A0, r11, r12, r13, r14, r8, r9, r10, r15, rbx
    mov    rdx, 24\B1
    MULSUB64x384 \A1, r11, r12, r13, r14, r8, r9, r10, r15, rbx         
    mov    rdx, 24\B2    
    MULADD64x384 \A2, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B3
    MULSUB64x384 \A3, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B4
    MULADD64x384 \A4, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B5
    MULSUB64x384 \A5, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B4
    MULADD64x384 \A4, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B5
    MULSUB64x384 \A5, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B4
    MULADD64x384 \A4, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B5
    MULSUB64x384 \A5, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B4
    MULADD64x384 \A4, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B5
    MULSUB64x384 \A5, r11, r12, r13, r14, r8, r9, r10, r15, rbx 
    // [r12:r14, r8:r10] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r11           // rdx <- z0
    MULADD64x384 [rip+p0], r11, r12, r13, r14, r8, r9, r10, r15, rbx
    mov    r11, 0
	bt     r10, 63
    sbb    r11, 0
    
    // [r12:r14, r8:r11] <- z = a0 x b04 - a1 x b14 + z 
    mov    rdx, 32\B0
    MULADD64x384 \A0, r12, r13, r14, r8, r9, r10, r11, r15, rbx
    mov    rdx, 32\B1
    MULSUB64x384 \A1, r12, r13, r14, r8, r9, r10, r11, r15, rbx         
    mov    rdx, 32\B2   
    MULADD64x384 \A2, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B3 
    MULSUB64x384 \A3, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B4
    MULADD64x384 \A4, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B5  
    MULSUB64x384 \A5, r12, r13, r14, r8, r9, r10, r11, r15, rbx  
    mov    rdx, 32\B4
    MULADD64x384 \A4, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B5  
    MULSUB64x384 \A5, r12, r13, r14, r8, r9, r10, r11, r15, rbx  
    mov    rdx, 32\B4
    MULADD64x384 \A4, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B5  
    MULSUB64x384 \A5, r12, r13, r14, r8, r9, r10, r11, r15, rbx  
    mov    rdx, 32\B4
    MULADD64x384 \A4, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B5  
    MULSUB64x384 \A5, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    // [r13:r14, r8:r11] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r12           // rdx <- z0
    MULADD64x384 [rip+p0], r12, r13, r14, r8, r9, r10, r11, r15, rbx
    mov    r12, 0
	bt     r11, 63
    sbb    r12, 0
    
    // [r13:r14, r8:r12] <- z = a0 x b05 - a1 x b15 + z 
    mov    rdx, 40\B0
    MULADD64x384 \A0, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B1
    MULSUB64x384 \A1, r13, r14, r8, r9, r10, r11, r12, r15, rbx      
    mov    rdx, 40\B2
    MULADD64x384 \A2, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B3
    MULSUB64x384 \A3, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B4
    MULADD64x384 \A4, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B5
    MULSUB64x384 \A5, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B4
    MULADD64x384 \A4, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B5
    MULSUB64x384 \A5, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B4
    MULADD64x384 \A4, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B5
    MULSUB64x384 \A5, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B4
    MULADD64x384 \A4, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B5
    MULSUB64x384 \A5, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    // [r14, r8:r12] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r13           // rdx <- z0
    MULADD64x384 [rip+p0], r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rax, 0
	bt     r12, 63
    sbb    rax, 0                                    /////////////// COULD BE SIMPLIFIED  
	
    // Correction if result < 0
	mov    r13, [rip+p0]
	mov    r15, [rip+p1]
	mov    rbx, [rip+p2]
	mov    rcx, [rip+p3]
	mov    rdx, [rip+p4]
	mov    rsi, [rip+p5]
	and    r13, rax
	and    r15, rax
	and    rbx, rax
	and    rcx, rax
	and    rdx, rax
	and    rsi, rax
	add    r14, r13
	adc    r8, r15
	adc    r9, rbx
	adc    r10, rcx
	adc    r11, rdx
	adc    r12, rsi
	
	// Final correction                        ////////////// COULD THIS ME REMOVED? RANGE TO [0, 2p]?
	xor    rax, rax
	mov    r13, [rip+p0]
	mov    r15, [rip+p1]
	mov    rbx, [rip+p2]
	mov    rcx, [rip+p3]
	mov    rdx, [rip+p4]
	mov    rsi, [rip+p5]
	sub    r14, r13
	sbb    r8, r15
	sbb    r9, rbx
	sbb    r10, rcx
	sbb    r11, rdx
	sbb    r12, rsi
	sbb    rax, 0
	and    r13, rax
	and    r15, rax
	and    rbx, rax
	and    rcx, rax
	and    rdx, rax
	and    rsi, rax
	add    r14, r13
	adc    r8, r15
	adc    r9, rbx
	adc    r10, rcx
	adc    r11, rdx
	adc    r12, rsi
    
    mov    \C, r14          
    mov    8\C, r8         
    mov    16\C, r9         
    mov    24\C, r10      
    mov    32\C, r11      
    mov    40\C, r12
    pop    rbx
    pop    r15
    pop    r14
    pop    r13
    pop    r12
.endm

.macro FP12MULADD384x384 A0, B0, A1, B1, A2, B2, A3, B3, A4, B4, A5, B5, C  
    mov    rcx, reg_p2
	  
    // [r8:r14] <- z = a00 x b00
    mov    rdx, \B0
    mulx   r9, r8, \A0        
    xor    rax, rax  
    push   r12  
    mulx   r10, r11, 8\A0 
    push   r13    
    adox   r9, r11        
    mulx   r11, r12, 16\A0 
    push   r14  
    adox   r10, r12        
    mulx   r12, r13, 24\A0  
    push   r15 
    adox   r11, r13       
    mulx   r13, r14, 32\A0 
    push   rbx
    adox   r12, r14      
    mulx   r14, r15, 40\A0  
    adox   r13, r15 
    adox   r14, rax
                     
    mov    rdx, \B1    
    MULADD64x384 \A1, r8, r9, r10, r11, r12, r13, r14, r15, rbx            
    mov    rdx, \B2    
    MULADD64x384 \A2, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B3    
    MULADD64x384 \A3, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B4    
    MULADD64x384 \A4, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B5   
    MULADD64x384 \A5, r8, r9, r10, r11, r12, r13, r14, r15, rbx         
    mov    rdx, \B4    
    MULADD64x384 \A4, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B5   
    MULADD64x384 \A5, r8, r9, r10, r11, r12, r13, r14, r15, rbx         
    mov    rdx, \B4    
    MULADD64x384 \A4, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B5   
    MULADD64x384 \A5, r8, r9, r10, r11, r12, r13, r14, r15, rbx         
    mov    rdx, \B4    
    MULADD64x384 \A4, r8, r9, r10, r11, r12, r13, r14, r15, rbx          
    mov    rdx, \B5   
    MULADD64x384 \A5, r8, r9, r10, r11, r12, r13, r14, r15, rbx
    // [r9:r14] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   rbx, rdx, r8             // rdx <- z0
    MULADD64x384 [rip+p0], r8, r9, r10, r11, r12, r13, r14, r15, rbx
	xor    r8, r8
    
    // [r9:r14, r8] <- z = a0 x b01 - a1 x b11 + z 
    mov    rdx, 8\B0
    MULADD64x384 \A0, r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    rdx, 8\B1
    MULADD64x384 \A1, r9, r10, r11, r12, r13, r14, r8, r15, rbx         
    mov    rdx, 8\B2    
    MULADD64x384 \A2, r9, r10, r11, r12, r13, r14, r8, r15, rbx  
    mov    rdx, 8\B3
    MULADD64x384 \A3, r9, r10, r11, r12, r13, r14, r8, r15, rbx 
    mov    rdx, 8\B4
    MULADD64x384 \A4, r9, r10, r11, r12, r13, r14, r8, r15, rbx 
    mov    rdx, 8\B5
    MULADD64x384 \A5, r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    rdx, 8\B4
    MULADD64x384 \A4, r9, r10, r11, r12, r13, r14, r8, r15, rbx 
    mov    rdx, 8\B5
    MULADD64x384 \A5, r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    rdx, 8\B4
    MULADD64x384 \A4, r9, r10, r11, r12, r13, r14, r8, r15, rbx 
    mov    rdx, 8\B5
    MULADD64x384 \A5, r9, r10, r11, r12, r13, r14, r8, r15, rbx
    mov    rdx, 8\B4
    MULADD64x384 \A4, r9, r10, r11, r12, r13, r14, r8, r15, rbx 
    mov    rdx, 8\B5
    MULADD64x384 \A5, r9, r10, r11, r12, r13, r14, r8, r15, rbx
    // [r10:r14, r8] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r9             // rdx <- z0
    MULADD64x384 [rip+p0], r9, r10, r11, r12, r13, r14, r8, r15, rbx
	xor    r9, r9
    
    // [r10:r14, r8:r9] <- z = a0 x b02 - a1 x b12 + z
    mov    rdx, 16\B0
    MULADD64x384 \A0, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B1
    MULADD64x384 \A1, r10, r11, r12, r13, r14, r8, r9, r15, rbx  
    mov    rdx, 16\B2    
    MULADD64x384 \A2, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B3
    MULADD64x384 \A3, r10, r11, r12, r13, r14, r8, r9, r15, rbx 
    mov    rdx, 16\B4
    MULADD64x384 \A4, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B5
    MULADD64x384 \A5, r10, r11, r12, r13, r14, r8, r9, r15, rbx 
    mov    rdx, 16\B4
    MULADD64x384 \A4, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B5
    MULADD64x384 \A5, r10, r11, r12, r13, r14, r8, r9, r15, rbx 
    mov    rdx, 16\B4
    MULADD64x384 \A4, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B5
    MULADD64x384 \A5, r10, r11, r12, r13, r14, r8, r9, r15, rbx 
    mov    rdx, 16\B4
    MULADD64x384 \A4, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    mov    rdx, 16\B5
    MULADD64x384 \A5, r10, r11, r12, r13, r14, r8, r9, r15, rbx
    // [r11:r14, r8:r9] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r10           // rdx <- z0
    MULADD64x384 [rip+p0], r10, r11, r12, r13, r14, r8, r9, r15, rbx
	xor    r10, r10
    
    // [r11:r14, r8:r10] <- z = a0 x b03 - a1 x b13 + z
    mov    rdx, 24\B0
    MULADD64x384 \A0, r11, r12, r13, r14, r8, r9, r10, r15, rbx
    mov    rdx, 24\B1
    MULADD64x384 \A1, r11, r12, r13, r14, r8, r9, r10, r15, rbx         
    mov    rdx, 24\B2    
    MULADD64x384 \A2, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B3
    MULADD64x384 \A3, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B4
    MULADD64x384 \A4, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B5
    MULADD64x384 \A5, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B4
    MULADD64x384 \A4, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B5
    MULADD64x384 \A5, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B4
    MULADD64x384 \A4, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B5
    MULADD64x384 \A5, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B4
    MULADD64x384 \A4, r11, r12, r13, r14, r8, r9, r10, r15, rbx  
    mov    rdx, 24\B5
    MULADD64x384 \A5, r11, r12, r13, r14, r8, r9, r10, r15, rbx 
    // [r12:r14, r8:r10] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r11           // rdx <- z0
    MULADD64x384 [rip+p0], r11, r12, r13, r14, r8, r9, r10, r15, rbx
	xor    r11, r11
    
    // [r12:r14, r8:r11] <- z = a0 x b04 - a1 x b14 + z 
    mov    rdx, 32\B0
    MULADD64x384 \A0, r12, r13, r14, r8, r9, r10, r11, r15, rbx
    mov    rdx, 32\B1
    MULADD64x384 \A1, r12, r13, r14, r8, r9, r10, r11, r15, rbx         
    mov    rdx, 32\B2   
    MULADD64x384 \A2, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B3 
    MULADD64x384 \A3, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B4
    MULADD64x384 \A4, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B5  
    MULADD64x384 \A5, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B4
    MULADD64x384 \A4, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B5  
    MULADD64x384 \A5, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B4
    MULADD64x384 \A4, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B5  
    MULADD64x384 \A5, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B4
    MULADD64x384 \A4, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    mov    rdx, 32\B5  
    MULADD64x384 \A5, r12, r13, r14, r8, r9, r10, r11, r15, rbx 
    // [r13:r14, r8:r11] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r12           // rdx <- z0
    MULADD64x384 [rip+p0], r12, r13, r14, r8, r9, r10, r11, r15, rbx
	xor    r12, r12
    
    // [r13:r14, r8:r12] <- z = a0 x b05 - a1 x b15 + z 
    mov    rdx, 40\B0
    MULADD64x384 \A0, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B1
    MULADD64x384 \A1, r13, r14, r8, r9, r10, r11, r12, r15, rbx      
    mov    rdx, 40\B2
    MULADD64x384 \A2, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B3
    MULADD64x384 \A3, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B4
    MULADD64x384 \A4, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B5
    MULADD64x384 \A5, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B4
    MULADD64x384 \A4, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B5
    MULADD64x384 \A5, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B4
    MULADD64x384 \A4, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B5
    MULADD64x384 \A5, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B4
    MULADD64x384 \A4, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    mov    rdx, 40\B5
    MULADD64x384 \A5, r13, r14, r8, r9, r10, r11, r12, r15, rbx
    // [r14, r8:r12] <- z = (z0 x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rbx, rdx, r13           // rdx <- z0
    MULADD64x384 [rip+p0], r13, r14, r8, r9, r10, r11, r12, r15, rbx
    
	// Final correction                        ////////////// COULD THIS ME REMOVED? RANGE TO [0, 2p]?
	xor    rax, rax
	mov    r13, [rip+p0]
	mov    r15, [rip+p1]
	mov    rbx, [rip+p2]
	mov    rcx, [rip+p3]
	mov    rdx, [rip+p4]
	mov    rsi, [rip+p5]
	sub    r14, r13
	sbb    r8, r15
	sbb    r9, rbx
	sbb    r10, rcx
	sbb    r11, rdx
	sbb    r12, rsi
	sbb    rax, 0
	and    r13, rax
	and    r15, rax
	and    rbx, rax
	and    rcx, rax
	and    rdx, rax
	and    rsi, rax
	add    r14, r13
	adc    r8, r15
	adc    r9, rbx
	adc    r10, rcx
	adc    r11, rdx
	adc    r12, rsi
    
    mov    \C, r14          
    mov    8\C, r8         
    mov    16\C, r9         
    mov    24\C, r10      
    mov    32\C, r11      
    mov    40\C, r12
    pop    rbx
    pop    r15
    pop    r14
    pop    r13
    pop    r12
.endm
  
//***********************************************************************
//  Multiplication in GF(p^12), first term
//  Operation: c [reg_p3] = a0 x b0 + E(a1 x b2 + a2 x b1)
//  Inputs: a = [a2, a1, a0] stored in [reg_p1] 
//          b = [b2, b1, b0] stored in [reg_p2] 
//  Output: c stored in [reg_p3]
//*********************************************************************** 
  .global fp12mul381c0_asm
fp12mul381c0_asm: 
	FP12MULADDSUB384x384 [reg_p1], [rcx], [reg_p1+48], [rcx+48], [reg_p1+96], [reg_p3+432], [reg_p1+144], [reg_p3+384], [reg_p1+192], [reg_p3+336], [reg_p1+240], [reg_p3+288], [reg_p3] 
	ret
	
  .global fp12mul381c1_asm
fp12mul381c1_asm:
	FP12MULADD384x384 [reg_p1], [rcx+48], [reg_p1+48], [rcx], [reg_p1+96], [reg_p3+384], [reg_p1+144], [reg_p3+432], [reg_p1+192], [reg_p3+288], [reg_p1+240], [reg_p3+336], [reg_p3+48] 
    ret
	
  .global fp12mul381c2_asm
fp12mul381c2_asm: 
	FP12MULADDSUB384x384 [reg_p1], [rcx+96], [reg_p1+48], [rcx+144], [reg_p1+96], [rcx], [reg_p1+144], [rcx+48], [reg_p1+192], [reg_p3+432], [reg_p1+240], [reg_p3+384], [reg_p3+96] 
    ret
	
  .global fp12mul381c3_asm
fp12mul381c3_asm:
	FP12MULADD384x384 [reg_p1], [rcx+144], [reg_p1+48], [rcx+96], [reg_p1+96], [rcx+48], [reg_p1+144], [rcx], [reg_p1+192], [reg_p3+384], [reg_p1+240], [reg_p3+432], [reg_p3+144] 
    ret
	
  .global fp12mul381c4_asm
fp12mul381c4_asm:
	FP12MULADDSUB384x384 [reg_p1], [rcx+192], [reg_p1+48], [rcx+240], [reg_p1+96], [rcx+96], [reg_p1+144], [rcx+144], [reg_p1+192], [rcx], [reg_p1+240], [rcx+48], [reg_p3+192] 
    ret
	
  .global fp12mul381c5_asm
fp12mul381c5_asm: 
	FP12MULADD384x384 [reg_p1], [rcx+240], [reg_p1+48], [rcx+192], [reg_p1+96], [rcx+144], [reg_p1+144], [rcx+96], [reg_p1+192], [rcx+48], [reg_p1+240], [rcx], [reg_p3+240] 
    ret
#endif
	
.att_syntax prefix



 //////////////////*************** NOTE: no improvement detected at the pairing level when using fp2_mulm_low or fp2_muln_low in assembly

 #if 0

.global fp2_mulm_low
.global fp2_muln_low

/*
 * Function: fp2_mulm_low
 * Inputs: rdi = c, rsi = a, rcx = b
 * Output: c = a * b
 */
fp2_mulm_low:
	push %r12
	push %r13
	push %r14
	push %r15
	push %rbx

	subq $288, %rsp
	movq %rdx, %rcx

	/* rsp[0..11] = t0 = a0 * b0 */
	FP_MULN_LOW %rsp, %r8, %r9, %r10, %rsi, %rcx

	addq $96, %rsp
	addq $48, %rsi
	addq $48, %rcx
	/* rsp[12..23] = t4 = a1 * b1 */
	FP_MULN_LOW %rsp, %r8, %r9, %r10, %rsi, %rcx
	subq $48, %rsi
	subq $48, %rcx
	
	/* t2 = rsp[24..29] = a0 + a1 */
	addq    $96, %rsp
	movq	0(%rsi), %r8
	addq	48(%rsi), %r8
	movq	8(%rsi), %r9
	adcq	56(%rsi), %r9
	movq	16(%rsi), %r10
	adcq	64(%rsi), %r10
	movq	24(%rsi), %r11
	adcq	72(%rsi), %r11
	movq	32(%rsi), %r12
	adcq	80(%rsi), %r12
	movq	40(%rsi), %r13
	adcq	88(%rsi), %r13
	movq    %r8, 0(%rsp)
	movq    %r9, 8(%rsp)
	movq    %r10, 16(%rsp)
	movq    %r11, 24(%rsp)
	movq    %r12, 32(%rsp)
	movq    %r13, 40(%rsp)

	/* t1 = (rsi, r15, r14, r13, r12, r11) = b0 + b1 */
	movq	0(%rcx), %r11
	addq	48(%rcx), %r11
	movq	8(%rcx), %r12
	adcq	56(%rcx), %r12
	movq	16(%rcx), %r13
	adcq	64(%rcx), %r13
	movq	24(%rcx), %r14
	adcq	72(%rcx), %r14
	movq	32(%rcx), %r15
	adcq	80(%rcx), %r15
	movq	40(%rcx), %rsi
	adcq	88(%rcx), %rsi

	/* rdi[0..11] = t3 = (a0 + a1) * (b0 + b1) */
	FP_MULD_LOW %rdi, %r8, %r9, %r10, %rsp, %r11, %r12, %r13, %r14, %r15, %rsi
	subq $192, %rsp

	/* rsp[24..29] = t2 = t0 + t4 = (a0 * b0) + (a1 * b1) */
	xorq	%rdx, %rdx
	xorq	%rsi, %rsi
	xorq	%r14, %r14
	movq	0(%rsp), %r8
	addq	96(%rsp), %r8
	movq	%r8, 192(%rsp)
	.irp i, 8, 16, 24, 32, 40, 48, 56, 64, 72, 80, 88
		movq	\i(%rsp), %r8
		adcq	(96+\i)(%rsp), %r8
		movq	%r8, (192+\i)(%rsp)
	.endr
	
	/* rsp[0..11] = t1 = t0 - t4 = (a0 * b0) - (a1 * b1). If t1 < 0 then t1 = t1 + 2^384 * p */
	xorq	%rax,%rax
	xorq	%rbx,%rbx
	xorq	%rcx,%rcx
	movq	0(%rsp), %r8
	subq	96(%rsp), %r8
	movq	%r8, 0(%rsp)
	.irp i, 8, 16, 24, 32, 40
		movq	\i(%rsp), %r8
		sbbq	(96+\i)(%rsp), %r8
		movq	%r8, \i(%rsp)
	.endr
	movq    48(%rsp), %r8
	sbbq    144(%rsp), %r8
	movq    56(%rsp), %r9
	sbbq    152(%rsp), %r9
	movq    64(%rsp), %r10
	sbbq    160(%rsp), %r10
	movq    72(%rsp), %r11
	sbbq    168(%rsp), %r11
	movq    80(%rsp), %r12
	sbbq    176(%rsp), %r12
	movq    88(%rsp), %r13
	sbbq    184(%rsp), %r13

	movq	$P0, %r15
	cmovc 	%r15, %rax
	movq	$P1, %r15
	cmovc 	%r15, %rbx
	movq	$P2, %r15
	cmovc 	%r15, %rcx
	movq	$P3, %r15
	cmovc 	%r15, %rdx
	movq	$P4, %r15
	cmovc 	%r15, %rsi
	movq	$P5, %r15
	cmovc 	%r15, %r14
    addq	%rax, %r8
	movq	%r8, 48(%rsp)
    adcq	%rbx, %r9
	movq	%r9, 56(%rsp)
    adcq	%rcx, %r10
	movq	%r10, 64(%rsp)
    adcq	%rdx, %r11
	movq	%r11, 72(%rsp)
    adcq	%rsi, %r12
	movq	%r12, 80(%rsp)
    adcq	%r14, %r13
	movq	%r13, 88(%rsp)

	/* rsp[0..8] = t4 = t3 - t2 = (a0 + a1) * (b0 + b1) - (a0 * b0) - (a1 * b1) */
	movq	0(%rdi), %r8
	subq	192(%rsp), %r8
	movq	%r8, 96(%rsp)
	.irp i, 8, 16, 24, 32, 40, 48, 56, 64, 72, 80, 88
		movq	(\i)(%rdi), %r8
		sbbq	(192+\i)(%rsp), %r8
		movq	%r8, (96+\i)(%rsp)
	.endr
	
	/* c0 = rdc(t1) */
	leaq 	p0(%rip), %r12
	FP_RDCN_LOW %rdi, %r8, %r9, %r10, %rsp, %r12
	
	/* c1 = rdc(t4) */
	leaq 	p0(%rip), %r12
	addq $48, %rdi
	addq $96, %rsp
	FP_RDCN_LOW %rdi, %r8, %r9, %r10, %rsp, %r12

	addq $192, %rsp
	pop %rbx
	pop %r15
	pop %r14
	pop %r13
	pop %r12
	ret	

/*
 * Function: fp2_muln_low
 * Inputs: rdi = c, rsi = a, rcx = b
 * Output: c = a * b
 */
fp2_muln_low:
	push %r12
	push %r13
	push %r14
	push %r15
	push %rbx

	subq $288, %rsp
	movq %rdx, %rcx

	/* rsp[0..11] = t0 = a0 * b0 */
	FP_MULN_LOW %rsp, %r8, %r9, %r10, %rsi, %rcx

	addq $96, %rsp
	addq $48, %rsi
	addq $48, %rcx
	/* rsp[12..23] = t4 = a1 * b1 */
	FP_MULN_LOW %rsp, %r8, %r9, %r10, %rsi, %rcx
	subq $48, %rsi
	subq $48, %rcx
	
	/* t2 = rsp[24..29] = a0 + a1 */
	addq    $96, %rsp
	movq	0(%rsi), %r8
	addq	48(%rsi), %r8
	movq	8(%rsi), %r9
	adcq	56(%rsi), %r9
	movq	16(%rsi), %r10
	adcq	64(%rsi), %r10
	movq	24(%rsi), %r11
	adcq	72(%rsi), %r11
	movq	32(%rsi), %r12
	adcq	80(%rsi), %r12
	movq	40(%rsi), %r13
	adcq	88(%rsi), %r13
	movq    %r8, 0(%rsp)
	movq    %r9, 8(%rsp)
	movq    %r10, 16(%rsp)
	movq    %r11, 24(%rsp)
	movq    %r12, 32(%rsp)
	movq    %r13, 40(%rsp)

	/* t1 = (rsi, r15, r14, r13, r12, r11) = b0 + b1 */
	movq	0(%rcx), %r11
	addq	48(%rcx), %r11
	movq	8(%rcx), %r12
	adcq	56(%rcx), %r12
	movq	16(%rcx), %r13
	adcq	64(%rcx), %r13
	movq	24(%rcx), %r14
	adcq	72(%rcx), %r14
	movq	32(%rcx), %r15
	adcq	80(%rcx), %r15
	movq	40(%rcx), %rsi
	adcq	88(%rcx), %rsi

	/* rdi[0..11] = t3 = (a0 + a1) * (b0 + b1) */
	FP_MULD_LOW %rdi, %r8, %r9, %r10, %rsp, %r11, %r12, %r13, %r14, %r15, %rsi
	subq $192, %rsp

	/* rsp[24..29] = t2 = t0 + t4 = (a0 * b0) + (a1 * b1) */
	xorq	%rdx, %rdx
	xorq	%rsi, %rsi
	xorq	%r14, %r14
	movq	0(%rsp), %r8
	addq	96(%rsp), %r8
	movq	%r8, 192(%rsp)
	.irp i, 8, 16, 24, 32, 40, 48, 56, 64, 72, 80, 88
		movq	\i(%rsp), %r8
		adcq	(96+\i)(%rsp), %r8
		movq	%r8, (192+\i)(%rsp)
	.endr
	
	/* c1 = t3 - t2 = (a0 + a1) * (b0 + b1) - (a0 * b0) - (a1 * b1) */
	movq	96(%rdi), %r8
	subq	192(%rsp), %r8
	movq	%r8, 96(%rdi)
	.irp i, 8, 16, 24, 32, 40, 48, 56, 64, 72, 80, 88
		movq	(96+\i)(%rdi), %r8
		sbbq	(192+\i)(%rsp), %r8
		movq	%r8, (96+\i)(%rdi)
	.endr
	
	/* c0 = t0 - t4 = (a0 * b0) - (a1 * b1). If c0 < 0 then c0 = c0 + 2^384 * p */
	xorq	%rax,%rax
	xorq	%rbx,%rbx
	xorq	%rcx,%rcx
	movq	0(%rsp), %r8
	subq	96(%rsp), %r8
	movq	%r8, 0(%rdi)
	.irp i, 8, 16, 24, 32, 40
		movq	\i(%rsp), %r8
		sbbq	(96+\i)(%rsp), %r8
		movq	%r8, \i(%rdi)
	.endr
	movq    48(%rsp), %r8
	sbbq    144(%rsp), %r8
	movq    56(%rsp), %r9
	sbbq    152(%rsp), %r9
	movq    64(%rsp), %r10
	sbbq    160(%rsp), %r10
	movq    72(%rsp), %r11
	sbbq    168(%rsp), %r11
	movq    80(%rsp), %r12
	sbbq    176(%rsp), %r12
	movq    88(%rsp), %r13
	sbbq    184(%rsp), %r13

	movq	$P0, %r15
	cmovc 	%r15, %rax
	movq	$P1, %r15
	cmovc 	%r15, %rbx
	movq	$P2, %r15
	cmovc 	%r15, %rcx
	movq	$P3, %r15
	cmovc 	%r15, %rdx
	movq	$P4, %r15
	cmovc 	%r15, %rsi
	movq	$P5, %r15
	cmovc 	%r15, %r14
    addq	%rax, %r8
	movq	%r8, 48(%rdi)
    adcq	%rbx, %r9
	movq	%r9, 56(%rdi)
    adcq	%rcx, %r10
	movq	%r10, 64(%rdi)
    adcq	%rdx, %r11
	movq	%r11, 72(%rdi)
    adcq	%rsi, %r12
	movq	%r12, 80(%rdi)
    adcq	%r14, %r13
	movq	%r13, 88(%rdi)

	addq $288, %rsp
	pop %rbx
	pop %r15
	pop %r14
	pop %r13
	pop %r12
	ret

#endif