  
.intel_syntax noprefix

// Registers that are used for parameter passing:
#define reg_p1  rsi
#define reg_p2  rdi
    

.text
     
//***********************************************************************
//  Squaring in GF(p^2), complex part
//  Operation: c [reg_p2] = 2a0 x a1
//  Input:  a = [a1, a0] stored in [reg_p1] 
//  Output: c stored in [reg_p2]
//*********************************************************************** 
.global fp2_sqrm_addpart
fp2_sqrm_addpart:   
    push   r12
    push   r13 
    push   r14  
    push   r15  
    push   rbx
	sub    rsp, 48
	
    // rsp[0..5] <- z = 2 x a0	
	mov    r8, [reg_p1]
	mov    r9, [reg_p1+8]
	mov    r10, [reg_p1+16]
	mov    r11, [reg_p1+24]
	mov    r12, [reg_p1+32]
	mov    r13, [reg_p1+40] 
	add    r8, r8
	adc    r9, r9
	adc    r10, r10
	adc    r11, r11
	adc    r12, r12
	adc    r13, r13
	mov    [rsp], r8
	mov    [rsp+8], r9
	mov    [rsp+16], r10
	mov    [rsp+24], r11
	mov    [rsp+32], r12
	mov    [rsp+40], r13
    
    // [r8:r14] <- z = 2 x a00 x a1
    mov    rdx, [rsp]
    mulx   r9, r8, [reg_p1+48]    
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
                   
    // [r9:r14] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   rcx, rdx, r8             // rdx <- z0
    MULADD64x384 [rip+p0], r8, r9, r10, r11, r12, r13, r14, r15, rbx
    
    // [r9:r14, r8] <- z = 2 x a01 x a1 + z        
    xor    r8, r8 
    mov    rdx, [rsp+8]
    MULADD64x384 [reg_p1+48], r9, r10, r11, r12, r13, r14, r8, r15, rbx
    // [r10:r14, r8] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rcx, rdx, r9             // rdx <- z0
    MULADD64x384 [rip+p0], r9, r10, r11, r12, r13, r14, r8, r15, rbx
    
    // [r10:r14, r8:r9] <- z = 2 x a02 x a1 + z        
    xor    r9, r9 
    mov    rdx, [rsp+16]
    MULADD64x384 [reg_p1+48], r10, r11, r12, r13, r14, r8, r9, r15, rbx
    // [r11:r14, r8:r9] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rcx, rdx, r10           // rdx <- z0
    MULADD64x384 [rip+p0], r10, r11, r12, r13, r14, r8, r9, r15, rbx
    
    // [r11:r14, r8:r10] <- z = 2 x a03 x a1 + z        
    xor    r10, r10 
    mov    rdx, [rsp+24]
    MULADD64x384 [reg_p1+48], r11, r12, r13, r14, r8, r9, r10, r15, rbx
    // [r12:r14, r8:r10] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rcx, rdx, r11           // rdx <- z0
    MULADD64x384 [rip+p0], r11, r12, r13, r14, r8, r9, r10, r15, rbx
    
    // [r12:r14, r8:r11] <- z = 2 x a04 x a1 + z        
    xor    r11, r11 
    mov    rdx, [rsp+32]
    MULADD64x384 [reg_p1+48], r12, r13, r14, r8, r9, r10, r11, r15, rbx
    // [r13:r14, r8:r11] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rcx, rdx, r12           // rdx <- z0
    MULADD64x384 [rip+p0], r12, r13, r14, r8, r9, r10, r11, r15, rbx
    
    // [r13:r14, r8:r12] <- z = 2 x a05 x a1 + z        
    xor    r12, r12 
    mov    rdx, [rsp+40]
    MULADD64x384 [reg_p1+48], r13, r14, r8, r9, r10, r11, r12, r15, rbx
    // [r14, r8:r12] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rcx, rdx, r13           // rdx <- z0
    MULADD64x384 [rip+p0], r13, r14, r8, r9, r10, r11, r12, r15, rbx           

	// Final correction                        
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
    
    mov    [reg_p2], r14          
    mov    [reg_p2+8], r8         
    mov    [reg_p2+16], r9         
    mov    [reg_p2+24], r10      
    mov    [reg_p2+32], r11      
    mov    [reg_p2+40], r12 
	add    rsp, 48
    pop    rbx
    pop    r15
    pop    r14
    pop    r13
    pop    r12
    ret
     
//***********************************************************************
//  Squaring in GF(p^2), non-complex part
//  Operation: c [reg_p3] = (a0 + a1) x (a0 - a1)
//  Inputs: a = [a1, a0] stored in [reg_p1] 
//          b = [b1, b0] stored in [reg_p2] 
//  Output: c stored in [reg_p3]
//***********************************************************************
.global fp2_sqrm_subpart
fp2_sqrm_subpart:   
    push   r12
    push   r13 
    push   r14  
    push   r15  
    push   rbx
	sub    rsp, 96
    
    // rsp[0..5] <- z = a0 + a1
	mov    r8, [reg_p1]
	add    r8, [reg_p1+48]
	mov    r9, [reg_p1+8]
	adc    r9, [reg_p1+56]
	mov    r10, [reg_p1+16]
	adc    r10, [reg_p1+64]
	mov    r11, [reg_p1+24]
	adc    r11, [reg_p1+72]
	mov    r12, [reg_p1+32]
	adc    r12, [reg_p1+80]
	mov    r13, [reg_p1+40]
	adc    r13, [reg_p1+88]
	mov    [rsp], r8                         
	mov    [rsp+8], r9
	mov    [rsp+16], r10
	mov    [rsp+24], r11
	mov    [rsp+32], r12
	mov    [rsp+40], r13
	
	// rsp[6..11] <- a0 - a1 + p381
	mov    r8, [reg_p1]
	sub    r8, [reg_p1+48]
	mov    r10, [reg_p1+8]
	sbb    r10, [reg_p1+56]
	mov    r12, [reg_p1+16]
	sbb    r12, [reg_p1+64]
	mov    r13, [reg_p1+24]
	sbb    r13, [reg_p1+72]
	mov    r14, [reg_p1+32]
	sbb    r14, [reg_p1+80]
	mov    r15, [reg_p1+40]
	sbb    r15, [reg_p1+88]
	add    r8, [rip+p0]                    
	adc    r10, [rip+p1]
	adc    r12, [rip+p2]
	adc    r13, [rip+p3]
	adc    r14, [rip+p4]
	adc    r15, [rip+p5]
	mov    [rsp+48], r8                 
	mov    [rsp+56], r10
	mov    [rsp+64], r12
	mov    [rsp+72], r13
	mov    [rsp+80], r14
	mov    [rsp+88], r15
    
    // [r8:r14] <- z = (a0 + a1)_00 x (a0 - a1)_0 + z
    mov    rdx, [rsp]
    mulx   r9, r8, r8    
    xor    rax, rax   
    mulx   r10, r11, r10   
    adox   r9, r11        
    mulx   r11, r12, r12   
    adox   r10, r12        
    mulx   r12, r13, r13   
    adox   r11, r13       
    mulx   r13, r14, r14   
    adox   r12, r14      
    mulx   r14, r15, r15   
    adox   r13, r15 
    adox   r14, rax 
                   
    // [r9:r14] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64                               
	mov    rdx, [rip+u0]
	mulx   rcx, rdx, r8             // rdx <- z0
    MULADD64x384 [rip+p0], r8, r9, r10, r11, r12, r13, r14, r15, rbx
    
    // [r9:r14, r8] <- z = 2 x a01 x a1 + z        
    xor    r8, r8 
    mov    rdx, [rsp+8]
    MULADD64x384 [rsp+48], r9, r10, r11, r12, r13, r14, r8, r15, rbx
    // [r10:r14, r8] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rcx, rdx, r9             // rdx <- z0
    MULADD64x384 [rip+p0], r9, r10, r11, r12, r13, r14, r8, r15, rbx
    
    // [r10:r14, r8:r9] <- z = 2 x a02 x a1 + z        
    xor    r9, r9 
    mov    rdx, [rsp+16]
    MULADD64x384 [rsp+48], r10, r11, r12, r13, r14, r8, r9, r15, rbx
    // [r11:r14, r8:r9] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rcx, rdx, r10           // rdx <- z0
    MULADD64x384 [rip+p0], r10, r11, r12, r13, r14, r8, r9, r15, rbx
    
    // [r11:r14, r8:r10] <- z = 2 x a03 x a1 + z        
    xor    r10, r10 
    mov    rdx, [rsp+24]
    MULADD64x384 [rsp+48], r11, r12, r13, r14, r8, r9, r10, r15, rbx
    // [r12:r14, r8:r10] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rcx, rdx, r11           // rdx <- z0
    MULADD64x384 [rip+p0], r11, r12, r13, r14, r8, r9, r10, r15, rbx
    
    // [r12:r14, r8:r11] <- z = 2 x a04 x a1 + z        
    xor    r11, r11 
    mov    rdx, [rsp+32]
    MULADD64x384 [rsp+48], r12, r13, r14, r8, r9, r10, r11, r15, rbx
    // [r13:r14, r8:r11] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rcx, rdx, r12           // rdx <- z0
    MULADD64x384 [rip+p0], r12, r13, r14, r8, r9, r10, r11, r15, rbx
    
    // [r13:r14, r8:r12] <- z = 2 x a05 x a1 + z        
    xor    r12, r12 
    mov    rdx, [rsp+40]
    MULADD64x384 [rsp+48], r13, r14, r8, r9, r10, r11, r12, r15, rbx
    // [r14, r8:r12] <- z = ((z0 x u0 mod 2^64) x p381 + z)/2^64
	mov    rdx, [rip+u0]                                            
	mulx   rcx, rdx, r13           // rdx <- z0
    MULADD64x384 [rip+p0], r13, r14, r8, r9, r10, r11, r12, r15, rbx           

	// Final correction                        
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
    
    mov    [reg_p2], r14          
    mov    [reg_p2+8], r8         
    mov    [reg_p2+16], r9         
    mov    [reg_p2+24], r10      
    mov    [reg_p2+32], r11      
    mov    [reg_p2+40], r12
	add    rsp, 96
    pop    rbx
    pop    r15
    pop    r14
    pop    r13
    pop    r12
    ret
    
.att_syntax prefix
