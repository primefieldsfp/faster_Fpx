  
.intel_syntax noprefix

// Registers that are used for parameter passing:
#define reg_p1  rsi
#define reg_p2  rdi
    

.text

///////////////////////////////////////////////////////////////// MACRO
// z = a x b + c x d (mod p)
// Inputs: base memory pointers M0 (a,c), M1 (b,d)
//         bi pre-stored in rdx,
//         accumulator z in [Z0:Z7], pre-stores a0 x b
// Output: [Z0:Z7]
// Temps:  regs T0:T1
/////////////////////////////////////////////////////////////////
.macro FPMUL512x512 M00, M10, Z0, Z1, Z2, Z3, Z4, Z5, Z6, Z7, Z8, T0, T1 
    // [Z1:Z8] <- z = ((z0 x u0 mod 2^64) x p509 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   \T0, rdx, \Z0            // rdx <- z0
    MULADD64x512 [rip+p0], \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \T0, \T1, \T0
    
    // [Z1:Z8 , Z0] <- z = a01 x a1 + z
    mov    rdx, 8\M10
    MULADD64x512 \M00, \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \T0, \T1, \Z0
    // [Z2:Z8 , Z0] <- z = ((z0 x u0 mod 2^64) x p509 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   \T0, rdx, \Z1            // rdx <- z0
    MULADD64x512 [rip+p0], \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \T0, \T1, \T0
    
    // [Z2:Z8 , Z0:Z1] <- z = a02 x a1 + z  
    mov    rdx, 16\M10
    MULADD64x512 \M00, \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \T0, \T1, \Z1 
    // [Z3:Z8 , Z0:Z1] <- z = ((z0 x u0 mod 2^64) x p509 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   \T0, rdx, \Z2            // rdx <- z0
    MULADD64x512 [rip+p0], \Z2, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \T0, \T1, \T0
    
    // [Z3:Z8 , Z0:Z2] <- z = a03 x a1 + z
    mov    rdx, 24\M10
    MULADD64x512 \M00, \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \T0, \T1, \Z2 
    // [Z4:Z8 , Z0:Z2] <- z = ((z0 x u0 mod 2^64) x p509 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   \T0, rdx, \Z3            // rdx <- z0
    MULADD64x512 [rip+p0], \Z3, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \T0, \T1, \T0
    
    // [Z4:Z8 , Z0:Z3] <- z = a04 x a1 + z 
    mov    rdx, 32\M10
    MULADD64x512 \M00, \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \T0, \T1, \Z3 
    // [Z5:Z8 , Z0:Z3] <- z = ((z0 x u0 mod 2^64) x p509 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   \T0, rdx, \Z4            // rdx <- z0
    MULADD64x512 [rip+p0], \Z4, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \T0, \T1, \T0
    
    // [Z5:Z8 , Z0:Z4] <- z = a05 x a1 + z    
    mov    rdx, 40\M10
    MULADD64x512 \M00, \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \T0, \T1, \Z4 
    // [Z6:Z8 , Z0:Z4] <- z = ((z0 x u0 mod 2^64) x p509 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   \T0, rdx, \Z5            // rdx <- z0
    MULADD64x512 [rip+p0], \Z5, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \T0, \T1, \T0
    
    // [Z6:Z8 , Z0:Z5] <- z = a06 x a1 + z  
    mov    rdx, 48\M10
    MULADD64x512 \M00, \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \T0, \T1, \Z5
    // [Z7, Z0:Z5] <- z = ((z0 x u0 mod 2^64) x p509 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   \T0, rdx, \Z6            // rdx <- z0
    MULADD64x512 [rip+p0], \Z6, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \T0, \T1, \T0 
    
    // [Z7:Z8 , Z0:Z6] <- z = a06 x a1 + z  
    mov    rdx, 56\M10
    MULADD64x512 \M00, \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \T0, \T1, \Z6 
    // [Z8, Z0:Z6] <- z = ((z0 x u0 mod 2^64) x p509 + z)/2^64
	mov    rdx, [rip+u0]
	mulx   \T0, rdx, \Z7            // rdx <- z0
    MULADD64x512 [rip+p0], \Z7, \Z8, \Z0, \Z1, \Z2, \Z3, \Z4, \Z5, \Z6, \T0, \T1, \T0     

	// Final correction
    xor    rsi, rsi
    mov    \T0, [rip+p0]
    mov    \T1, [rip+p1]
    mov    \Z7, [rip+p2]
    mov    rdx, [rip+p3]
    sub    \Z8, \T0
    sbb    \Z0, \T1
    sbb    \Z1, \Z7
    sbb    \Z2, rdx
    sbb    \Z3, [rip+p4]
    sbb    \Z4, [rip+p5]
    sbb    \Z5, [rip+p6]
    sbb    \Z6, [rip+p7]
    sbb    rsi, 0
    and    \T0, rsi
    and    \T1, rsi
    and    \Z7, rsi
    and    rdx, rsi
    add    \Z8, \T0
    adc    \Z0, \T1
    adc    \Z1, \Z7
    adc    \Z2, rdx
    mov    [reg_p2], \Z8     
    mov    [reg_p2+8], \Z0 
    mov    [reg_p2+16], \Z1 
    mov    [reg_p2+24], \Z2
    setc   cl
    mov    \Z0, [rip+p4]
    mov    \Z1, [rip+p5]
    mov    \Z2, [rip+p6]
    mov    rdx, [rip+p7]
    and    \Z0, rsi
    and    \Z1, rsi
    and    \Z2, rsi
    and    rdx, rsi
    bt     rcx, 0
    adc    \Z3, \Z0
    adc    \Z4, \Z1
    adc    \Z5, \Z2
    adc    \Z6, rdx

    mov    [reg_p2+32], \Z3  
    mov    [reg_p2+40], \Z4 
    mov    [reg_p2+48], \Z5 
    mov    [reg_p2+56], \Z6
.endm
     
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
    sub    rsp, 64
	
    // rsp[0..7] <- z = 2 x a0	
    mov    r8, [reg_p1]
    mov    r9, [reg_p1+8]
    mov    r10, [reg_p1+16]
    mov    r11, [reg_p1+24]
    mov    r12, [reg_p1+32]
    mov    r13, [reg_p1+40] 
    mov    r14, [reg_p1+48]
    mov    r15, [reg_p1+56] 
    add    r8, r8
    adc    r9, r9
    adc    r10, r10
    adc    r11, r11
    adc    r12, r12
    adc    r13, r13
    adc    r14, r14
    adc    r15, r15
    mov    [rsp+8], r9
    mov    [rsp+16], r10
    mov    [rsp+24], r11
    mov    [rsp+32], r12
    mov    [rsp+40], r13
    mov    [rsp+48], r14
    mov    [rsp+56], r15
    
    // [r8:r15, rax] <- z = 2 x a00 x a1    
    mov    rdx, r8
    mulx   r9, r8, [reg_p1+64]
    xor    rax, rax 
    mulx   r10, r11, [reg_p1+72] 
    adcx   r9, r11        
    mulx   r11, r12, [reg_p1+80] 
    adcx   r10, r12        
    mulx   r12, r13, [reg_p1+88] 
    adcx   r11, r13       
    mulx   r13, r14, [reg_p1+96]
    adcx   r12, r14      
    mulx   r14, r15, [reg_p1+104]
    adcx   r13, r15      
    mulx   r15, rcx, [reg_p1+112] 
    adcx   r14, rcx       
    mulx   rax, rbx, [reg_p1+120]
    adcx   r15, rbx     
    adc    rax, 0      

    FPMUL512x512 [reg_p1+64], [rsp], r8, r9, r10, r11, r12, r13, r14, r15, rax, rbx, rcx
         
    add    rsp, 64     
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
    sub    rsp, 128
    
    // rsp[0..7] <- z = a0 + a1
    mov    r8, [reg_p1]
    add    r8, [reg_p1+64]
    mov    r9, [reg_p1+8]
    adc    r9, [reg_p1+72]
    mov    r10, [reg_p1+16]
    adc    r10, [reg_p1+80]
    mov    r11, [reg_p1+24]
    adc    r11, [reg_p1+88]
    mov    r12, [reg_p1+32]
    adc    r12, [reg_p1+96]
    mov    r13, [reg_p1+40]
    adc    r13, [reg_p1+104]
    mov    r14, [reg_p1+48]
    adc    r14, [reg_p1+112]
    mov    r15, [reg_p1+56]
    adc    r15, [reg_p1+120]
    mov    [rsp], r8                         
    mov    [rsp+8], r9
    mov    [rsp+16], r10
    mov    [rsp+24], r11
    mov    [rsp+32], r12
    mov    [rsp+40], r13
    mov    [rsp+48], r14
    mov    [rsp+56], r15
	
    // rsp[8..15] <- a0 - a1 + p509
    mov    r8, [reg_p1]
    sub    r8, [reg_p1+64]
    mov    r10, [reg_p1+8]
    sbb    r10, [reg_p1+72]
    mov    r12, [reg_p1+16]
    sbb    r12, [reg_p1+80]
    mov    r13, [reg_p1+24]
    sbb    r13, [reg_p1+88]
    mov    r14, [reg_p1+32]
    sbb    r14, [reg_p1+96]
    mov    r15, [reg_p1+40]
    sbb    r15, [reg_p1+104]
    mov    rcx, [reg_p1+48]
    sbb    rcx, [reg_p1+112]
    mov    rax, [reg_p1+56]
    sbb    rax, [reg_p1+120]
    add    r8, [rip+p0]                   
    adc    r10, [rip+p1]
    adc    r12, [rip+p2]
    adc    r13, [rip+p3]
    adc    r14, [rip+p4]
    adc    r15, [rip+p5]
    adc    rcx, [rip+p6]
    adc    rax, [rip+p7]
    mov    [rsp+64], r8                 
    mov    [rsp+72], r10
    mov    [rsp+80], r12
    mov    [rsp+88], r13
    mov    [rsp+96], r14
    mov    [rsp+104], r15
    mov    [rsp+112], rcx
    mov    [rsp+120], rax
    
    // [r8:r15, rax] <- z = (a0 + a1)_00 x (a0 - a1)_0 + z
    mov    rdx, [rsp]
    mulx   r9, r8, r8    
    xor    rbx, rbx   
    mulx   r10, r11, r10   
    adcx   r9, r11        
    mulx   r11, r12, r12   
    adcx   r10, r12        
    mulx   r12, r13, r13   
    adcx   r11, r13       
    mulx   r13, r14, r14   
    adcx   r12, r14      
    mulx   r14, r15, r15   
    adcx   r13, r15     
    mulx   r15, rcx, rcx   
    adcx   r14, rcx    
    mulx   rax, rcx, rax    
    adcx   r15, rcx          
    adc    rax, 0       

    FPMUL512x512 [rsp+64], [rsp], r8, r9, r10, r11, r12, r13, r14, r15, rax, rbx, rcx
         
    add    rsp, 128     
    pop    rbx
    pop    r15
    pop    r14
    pop    r13
    pop    r12
    ret

.att_syntax prefix
