//*******************************************************************************************
// SIDH: an efficient supersingular isogeny cryptography library
//
// Abstract: field arithmetic in x64 assembly for P610 on Linux 
//*******************************************************************************************  

.intel_syntax noprefix 

// Format function and variable names for Mac OS X
#if defined(__APPLE__)
    #define fmt(f)    _##f
#else
    #define fmt(f)    f
#endif

// Registers that are used for parameter passing:
#define reg_p1  rdi
#define reg_p2  rsi
#define reg_p3  rdx


.text
//***********************************************************************
//  Field addition
//  Operation: c [reg_p3] = a [reg_p1] + b [reg_p2]
//*********************************************************************** 
.global fmt(fpadd610_asm)
fmt(fpadd610_asm):
  push   r12
  push   r13
  push   r14
  push   r15
  
  mov    r8, [reg_p1]
  mov    r9, [reg_p1+8]
  mov    r10, [reg_p1+16]
  mov    r11, [reg_p1+24]
  mov    r12, [reg_p1+32]
  mov    r13, [reg_p1+40]
  mov    r14, [reg_p1+48]
  mov    r15, [reg_p1+56] 
  mov    rcx, [reg_p1+64]
  mov    rdi, [reg_p1+72]
  add    r8, [reg_p2] 
  adc    r9, [reg_p2+8] 
  adc    r10, [reg_p2+16] 
  adc    r11, [reg_p2+24] 
  adc    r12, [reg_p2+32] 
  adc    r13, [reg_p2+40] 
  adc    r14, [reg_p2+48] 
  adc    r15, [reg_p2+56]
  adc    rcx, [reg_p2+64]
  adc    rdi, [reg_p2+72]

  mov    rax, [rip+fmt(p610x2)]
  sub    r8, rax
  mov    rax, [rip+fmt(p610x2)+8]
  sbb    r9, rax
  sbb    r10, rax
  sbb    r11, rax
  mov    rax, [rip+fmt(p610x2)+32]
  sbb    r12, rax
  mov    rax, [rip+fmt(p610x2)+40]
  sbb    r13, rax
  mov    rax, [rip+fmt(p610x2)+48]
  sbb    r14, rax
  mov    rax, [rip+fmt(p610x2)+56]
  sbb    r15, rax
  mov    rax, [rip+fmt(p610x2)+64]
  sbb    rcx, rax
  mov    rax, [rip+fmt(p610x2)+72]
  sbb    rdi, rax
  mov    [reg_p3+64], rcx
  mov    [reg_p3+72], rdi
  mov    rax, 0
  sbb    rax, 0
  
  mov    rsi, [rip+fmt(p610x2)]
  and    rsi, rax
  mov    rdi, [rip+fmt(p610x2)+8]
  and    rdi, rax
  
  add    r8, rsi  
  adc    r9, rdi 
  adc    r10, rdi 
  adc    r11, rdi
  mov    [reg_p3], r8 
  mov    [reg_p3+8], r9 
  mov    [reg_p3+16], r10 
  mov    [reg_p3+24], r11 
  setc   cl
  
  mov    rdi, [rip+fmt(p610x2)+32]
  and    rdi, rax
  mov    rsi, [rip+fmt(p610x2)+40]
  and    rsi, rax
  mov    r8, [rip+fmt(p610x2)+48]
  and    r8, rax
  mov    r9, [rip+fmt(p610x2)+56]
  and    r9, rax
  mov    r10, [rip+fmt(p610x2)+64]
  and    r10, rax
  mov    r11, [rip+fmt(p610x2)+72]
  and    r11, rax
  
  bt     rcx, 0
  adc    r12, rdi
  adc    r13, rsi  
  adc    r14, r8
  adc    r15, r9
  mov    rsi, [reg_p3+64]
  mov    rdi, [reg_p3+72]
  adc    rsi, r10  
  adc    rdi, r11
  mov    [reg_p3+32], r12  
  mov    [reg_p3+40], r13
  mov    [reg_p3+48], r14
  mov    [reg_p3+56], r15  
  mov    [reg_p3+64], rsi
  mov    [reg_p3+72], rdi

  pop    r15
  pop    r14
  pop    r13
  pop    r12
  ret


//***********************************************************************
//  Field subtraction
//  Operation: c [reg_p3] = a [reg_p1] - b [reg_p2]
//*********************************************************************** 
.global fmt(fpsub610_asm)
fmt(fpsub610_asm):
  push   r12
  push   r13
  push   r14
  push   r15
  
  mov    r8, [reg_p1]
  mov    r9, [reg_p1+8]
  mov    r10, [reg_p1+16]
  mov    r11, [reg_p1+24]
  mov    r12, [reg_p1+32]
  mov    r13, [reg_p1+40]
  mov    r14, [reg_p1+48]
  mov    r15, [reg_p1+56] 
  mov    rcx, [reg_p1+64] 
  mov    rdi, [reg_p1+72]
  sub    r8, [reg_p2] 
  sbb    r9, [reg_p2+8] 
  sbb    r10, [reg_p2+16] 
  sbb    r11, [reg_p2+24] 
  sbb    r12, [reg_p2+32] 
  sbb    r13, [reg_p2+40] 
  sbb    r14, [reg_p2+48] 
  sbb    r15, [reg_p2+56]
  sbb    rcx, [reg_p2+64]
  sbb    rdi, [reg_p2+72]
  mov    [reg_p3+64], rcx
  mov    [reg_p3+72], rdi
  mov    rax, 0
  sbb    rax, 0
    
  mov    rsi, [rip+fmt(p610x2)]
  and    rsi, rax
  mov    rdi, [rip+fmt(p610x2)+8]
  and    rdi, rax
  
  add    r8, rsi  
  adc    r9, rdi 
  adc    r10, rdi 
  adc    r11, rdi
  mov    [reg_p3], r8 
  mov    [reg_p3+8], r9 
  mov    [reg_p3+16], r10 
  mov    [reg_p3+24], r11 
  setc   cl
  
  mov    rdi, [rip+fmt(p610x2)+32]
  and    rdi, rax
  mov    rsi, [rip+fmt(p610x2)+40]
  and    rsi, rax
  mov    r8, [rip+fmt(p610x2)+48]
  and    r8, rax
  mov    r9, [rip+fmt(p610x2)+56]
  and    r9, rax
  mov    r10, [rip+fmt(p610x2)+64]
  and    r10, rax
  mov    r11, [rip+fmt(p610x2)+72]
  and    r11, rax
  
  bt     rcx, 0
  adc    r12, rdi
  adc    r13, rsi  
  adc    r14, r8
  adc    r15, r9
  mov    rsi, [reg_p3+64]
  mov    rdi, [reg_p3+72]
  adc    rsi, r10  
  adc    rdi, r11
  mov    [reg_p3+32], r12  
  mov    [reg_p3+40], r13
  mov    [reg_p3+48], r14
  mov    [reg_p3+56], r15  
  mov    [reg_p3+64], rsi
  mov    [reg_p3+72], rdi
  
  pop    r15
  pop    r14
  pop    r13
  pop    r12
  ret 


///////////////////////////////////////////////////////////////// MACRO
.macro SUB610_PX  P0
  push   r12
  push   r13
  push   r14
  push   r15
  
  mov    r8, [reg_p1]
  mov    r9, [reg_p1+8]
  mov    r10, [reg_p1+16]
  mov    r11, [reg_p1+24]
  mov    r12, [reg_p1+32]
  mov    r13, [reg_p1+40]
  mov    r14, [reg_p1+48]
  mov    r15, [reg_p1+56]
  mov    rax, [reg_p1+64]
  mov    rcx, [reg_p1+72]
  sub    r8, [reg_p2] 
  sbb    r9, [reg_p2+8] 
  sbb    r10, [reg_p2+16] 
  sbb    r11, [reg_p2+24] 
  sbb    r12, [reg_p2+32] 
  sbb    r13, [reg_p2+40]
  sbb    r14, [reg_p2+48] 
  sbb    r15, [reg_p2+56] 
  sbb    rax, [reg_p2+64] 
  sbb    rcx, [reg_p2+72] 

  mov    rdi, [rip+\P0]
  mov    rsi, [rip+\P0+8]
  add    r8, rdi  
  adc    r9, rsi  
  adc    r10, rsi 
  adc    r11, rsi 
  mov    rdi, [rip+\P0+32]
  mov    rsi, [rip+\P0+40]
  adc    r12, rdi   
  adc    r13, rsi   
  mov    [reg_p3], r8
  mov    [reg_p3+8], r9 
  mov    [reg_p3+16], r10 
  mov    [reg_p3+24], r11
  mov    [reg_p3+32], r12 
  mov    [reg_p3+40], r13
  mov    rdi, [rip+\P0+48]
  mov    rsi, [rip+\P0+56]
  adc    r14, rdi  
  adc    r15, rsi  
  mov    rdi, [rip+\P0+64]
  mov    rsi, [rip+\P0+72]
  adc    rax, rdi 
  adc    rcx, rsi  
  mov    [reg_p3+48], r14
  mov    [reg_p3+56], r15 
  mov    [reg_p3+64], rax 
  mov    [reg_p3+72], rcx
  
  pop    r15
  pop    r14
  pop    r13
  pop    r12
  .endm


//***********************************************************************
//  Multiprecision subtraction with correction with 2*p610
//  Operation: c [reg_p3] = a [reg_p1] - b [reg_p2] + 2*p610
//*********************************************************************** 
.global fmt(mp_sub610_p2_asm)
fmt(mp_sub610_p2_asm):

  SUB610_PX  fmt(p610x2)
  ret


//***********************************************************************
//  Multiprecision subtraction with correction with 4*p610
//  Operation: c [reg_p3] = a [reg_p1] - b [reg_p2] + 4*p610
//*********************************************************************** 
.global fmt(mp_sub610_p4_asm)
fmt(mp_sub610_p4_asm):

  SUB610_PX  fmt(p610x4)
  ret


#ifdef _MULX_

/////////////////////////////////////////////////////////////////////////// MACRO
// Schoolbook integer multiplication
// Inputs:  memory pointers M0 and M1
// Outputs: memory pointer C
// Temps:   regs T0:T7
///////////////////////////////////////////////////////////////////////////
#ifdef _ADX_

.macro MUL320_SCHOOL M0, M1, C, T0, T1, T2, T3, T4, T5, T6, T7 
    mov    rdx, \M0
    mulx   \T0, \T1, \M1    
    mulx   \T2, \T3, 8\M1
    mov    \C, \T1             // C0_final 
    xor    rax, rax
    mulx   \T4, \T5, 16\M1 
    adox   \T0, \T3               
    adox   \T2, \T5     
    mulx   \T1, \T3, 24\M1
    adox   \T4, \T3         
    mulx   \T5, \T6, 32\M1 
    adox   \T1, \T6     
    adox   \T5, rax        
    
    mov    rdx, 8\M0 
    mulx   \T6, \T7, \M1 
    xor    rax, rax
    adcx   \T0, \T7 
    mov    8\C, \T0            // C1_final 
    adcx   \T2, \T6     
    mulx   \T6, \T7, 8\M1
    adox   \T2, \T7 
    adcx   \T4, \T6        
    mulx   \T0, \T6, 16\M1 
    adox   \T4, \T6  
    adcx   \T0, \T1     
    mulx   \T1, \T7, 24\M1   
    adcx   \T1, \T5 
    adox   \T0, \T7   
    mulx   \T5, \T6, 32\M1 
    adcx   \T5, rax         
    adox   \T1, \T6  
    adox   \T5, rax         
    
    mov    rdx, 16\M0 
    mulx   \T6, \T7, \M1
    xor    rax, rax 
    adcx   \T2, \T7 
    mov    16\C, \T2           // C2_final 
    adcx   \T4, \T6     
    mulx   \T6, \T7, 8\M1
    adox   \T4, \T7 
    adcx   \T0, \T6        
    mulx   \T2, \T6, 16\M1
    adox   \T0, \T6 
    adcx   \T1, \T2     
    mulx   \T2, \T7, 24\M1   
    adcx   \T5, \T2          
    adox   \T1, \T7   
    mulx   \T2, \T6, 32\M1   
    adcx   \T2, rax 
    adox   \T5, \T6 
    adox   \T2, rax           
    
    mov    rdx, 24\M0 
    mulx   \T6, \T7, \M1
    xor    rax, rax 
    adcx   \T4, \T7 
    mov    24\C, \T4           // C3_final 
    adcx   \T0, \T6     
    mulx   \T6, \T7, 8\M1
    adox   \T0, \T7
    adcx   \T1, \T6        
    mulx   \T4, \T6, 16\M1
    adox   \T1, \T6  
    adcx   \T5, \T4     
    mulx   \T4, \T7, 24\M1   
    adcx   \T2, \T4        
    adox   \T5, \T7   
    mulx   \T4, \T6, 32\M1   
    adcx   \T4, rax 
    adox   \T2, \T6  
    adox   \T4, rax         
    
    mov    rdx, 32\M0 
    mulx   \T6, \T7, \M1 
    xor    rax, rax
    adcx   \T0, \T7 
    mov    32\C, \T0           // C4_final 
    adcx   \T1, \T6     
    mulx   \T6, \T7, 8\M1
    adox   \T1, \T7 
    adcx   \T5, \T6        
    mulx   \T0, \T6, 16\M1 
    adox   \T5, \T6 
    adcx   \T2, \T0     
    mulx   \T0, \T7, 24\M1   
    adcx   \T4, \T0 
    adox   \T2, \T7  
    mulx   \T0, \T6, 32\M1   
    adcx   \T0, rax           
    adox   \T4, \T6 
    adox   \T0, rax 

    mov    40\C, \T1 
    mov    48\C, \T5 
    mov    56\C, \T2 
    mov    64\C, \T4
    mov    72\C, \T0
.endm

#else

.macro MUL320_SCHOOL M0, M1, C, T0, T1, T2, T3, T4, T5, T6, T7
    mov    rdx, \M0
    mulx   \T0, \T1, \M1    
    mulx   \T2, \T3, 8\M1
    mov    \C, \T1             // C0_final 
    mulx   \T4, \T5, 16\M1 
    add    \T0, \T3               
    adc    \T2, \T5     
    mulx   \T1, \T3, 24\M1
    adc    \T3, \T4         
    mulx   \T5, \T6, 32\M1 
    adc    \T1, \T6     
    adc    \T5, 0        
    
    mov    rdx, 8\M0 
    mulx   \T6, \T7, \M1 
    add    \T0, \T7 
    mov    8\C, \T0            // C1_final 
    adc    \T2, \T6     
    mulx   \T6, \T7, 8\M1
    adc    \T3, \T6        
    mulx   \T0, \T4, 16\M1
    adc    \T0, \T1     
    mulx   \T1, \T6, 24\M1   
    adc    \T5, \T1  
    mulx   \T1, rax, 32\M1     
    adc    \T1, 0 
        
    add    \T2, \T7 
    adc    \T3, \T4  
    adc    \T0, \T6  
    adc    \T5, rax  
    adc    \T1, 0         
    
    mov    rdx, 16\M0 
    mulx   \T4, \T6, \M1 
    add    \T2, \T6 
    mov    16\C, \T2           // C2_final 
    adc    \T3, \T4     
    mulx   \T6, \T7, 8\M1
    adc    \T0, \T6        
    mulx   \T2, \T4, 16\M1 
    adc    \T2, \T5     
    mulx   \T5, \T6, 24\M1   
    adc    \T1, \T5 
    mulx   \T5, rax, 32\M1     
    adc    \T5, 0 
        
    add    \T3, \T7
    adc    \T0, \T4  
    adc    \T2, \T6  
    adc    \T1, rax 
    adc    \T5, 0          
    
    mov    rdx, 24\M0
    mulx   \T4, \T6, \M1 
    add    \T3, \T6 
    mov    24\C, \T3           // C3_final 
    adc    \T0, \T4     
    mulx   \T6, \T7, 8\M1
    adc    \T2, \T6        
    mulx   \T3, \T4, 16\M1 
    adc    \T1, \T3     
    mulx   \T3, \T6, 24\M1   
    adc    \T3, \T5 
    mulx   \T5, rax, 32\M1     
    adc    \T5, 0
        
    add    \T0, \T7
    adc    \T2, \T4  
    adc    \T1, \T6  
    adc    \T3, rax 
    adc    \T5, 0       
    
    mov    rdx, 32\M0 
    mulx   \T4, \T6, \M1 
    add    \T0, \T6 
    mov    32\C, \T0           // C4_final 
    adc    \T2, \T4     
    mulx   \T6, \T7, 8\M1
    adc    \T1, \T6        
    mulx   \T0, \T4, 16\M1 
    adc    \T3, \T0     
    mulx   \T0, \T6, 24\M1   
    adc    \T0, \T5 
    mulx   \T5, rax, 32\M1     
    adc    \T5, 0
        
    add    \T2, \T7 
    adc    \T1, \T4  
    adc    \T3, \T6 
    adc    \T0, rax 
    adc    \T5, 0 
    mov    40\C, \T2 
    mov    48\C, \T1 
    mov    56\C, \T3 
    mov    64\C, \T0
    mov    72\C, \T5 
.endm

#endif


//*****************************************************************************
//  610-bit multiplication using Karatsuba (one level), schoolbook (two levels)
//***************************************************************************** 
.global fmt(mul610_asm)
fmt(mul610_asm):    
    push   r12
    push   r13 
    push   r14 
    push   r15
    mov    rcx, reg_p3 

    // [rsp] <- AH + AL, rax <- mask
    xor    rax, rax
    mov    r8, [reg_p1]
    mov    r9, [reg_p1+8]
    mov    r10, [reg_p1+16]
    mov    r11, [reg_p1+24] 
    mov    r12, [reg_p1+32] 
    push   rbx 
    sub    rsp, 112
    add    r8, [reg_p1+40]
    adc    r9, [reg_p1+48]
    adc    r10, [reg_p1+56]
    adc    r11, [reg_p1+64]
    adc    r12, [reg_p1+72]
    sbb    rax, 0
    mov    [rsp], r8
    mov    [rsp+8], r9
    mov    [rsp+16], r10
    mov    [rsp+24], r11
    mov    [rsp+32], r12

    // [rsp+40] <- BH + BL, rdx <- mask
    xor    rdx, rdx
    mov    r8, [reg_p2]
    mov    r9, [reg_p2+8]
    mov    rbx, [reg_p2+16]
    mov    r13, [reg_p2+24] 
    mov    r14, [reg_p2+32]    
    add    r8, [reg_p2+40]
    adc    r9, [reg_p2+48]
    adc    rbx, [reg_p2+56]
    adc    r13, [reg_p2+64]
    adc    r14, [reg_p2+72]
    sbb    rdx, 0
    mov    [rsp+40], r8
    mov    [rsp+48], r9
    mov    [rsp+56], rbx
    mov    [rsp+64], r13
    mov    [rsp+72], r14     
    
    // [rcx] <- masked (BH + BL)
    and    r8, rax
    and    r9, rax
    and    rbx, rax
    and    r13, rax
    and    r14, rax    
    mov    [rcx], r8
    mov    [rcx+8], r9

    // r8-r12 <- masked (AH + AL)
    mov    r8, [rsp]
    mov    r9, [rsp+8]
    and    r8, rdx
    and    r9, rdx
    and    r10, rdx
    and    r11, rdx
    and    r12, rdx

    // [rsp+80] <- masked (AH + AL) + masked (BH + BL)
    mov    rax, [rcx]
    mov    rdx, [rcx+8]
    add    r8, rax
    adc    r9, rdx
    adc    r10, rbx
    adc    r11, r13
    adc    r12, r14        
    mov    [rsp+80], r8
    mov    [rsp+88], r9
    mov    [rsp+96], r10
    mov    [rsp+104], r11

    // [rcx] <- AL x BL
    MUL320_SCHOOL  [reg_p1], [reg_p2], [rcx], r8, r9, r10, r11, rbx, r13, r14, r15     // Result C0-C4 

    // [rcx+80] <- (AH+AL) x (BH+BL), low part 
    MUL320_SCHOOL  [rsp], [rsp+40], [rcx+80], r8, r9, r10, r11, rbx, r13, r14, r15

    // [rsp] <- AH x BH 
    MUL320_SCHOOL  [reg_p1+40], [reg_p2+40], [rsp], r8, r9, r10, r11, rbx, r13, r14, r15
    
    // r8-r12 <- (AH+AL) x (BH+BL), final step
    mov    r8, [rsp+80]
    mov    r9, [rsp+88]
    mov    r10, [rsp+96]
    mov    r11, [rsp+104]
    mov    rax, [rcx+120]
    add    r8, rax
    mov    rax, [rcx+128]
    adc    r9, rax
    mov    rax, [rcx+136]
    adc    r10, rax
    mov    rax, [rcx+144]
    adc    r11, rax
    mov    rax, [rcx+152]
    adc    r12, rax
    
    // rdi,rdx,rbx,r13,r14,r8-r12 <- (AH+AL) x (BH+BL) - ALxBL
    mov    rdi, [rcx+80]
    sub    rdi, [rcx]
    mov    rdx, [rcx+88]
    sbb    rdx, [rcx+8]
    mov    rbx, [rcx+96]
    sbb    rbx, [rcx+16]
    mov    r13, [rcx+104]
    sbb    r13, [rcx+24]
    mov    r14, [rcx+112]     
    sbb    r14, [rcx+32]  
    sbb    r8, [rcx+40]
    sbb    r9, [rcx+48]
    sbb    r10, [rcx+56]
    sbb    r11, [rcx+64]
    sbb    r12, [rcx+72]
    
    // rdi,rdx,rbx,r13,r14,r8-r12 <- (AH+AL) x (BH+BL) - ALxBL - AHxBH
    sub    rdi, [rsp]
    sbb    rdx, [rsp+8]
    sbb    rbx, [rsp+16]
    sbb    r13, [rsp+24]
    sbb    r14, [rsp+32]  
    sbb    r8, [rsp+40]
    sbb    r9, [rsp+48]
    sbb    r10, [rsp+56]
    sbb    r11, [rsp+64]
    sbb    r12, [rsp+72]
    
    mov    rax, [rcx+40]
    add    rax, rdi
    mov    [rcx+40], rax    // Result C5-C9
    mov    rax, [rcx+48]
    adc    rax, rdx
    mov    [rcx+48], rax 
    mov    rax, [rcx+56]
    adc    rax, rbx
    mov    [rcx+56], rax 
    mov    rax, [rcx+64]
    adc    rax, r13
    mov    [rcx+64], rax 
    mov    rax, [rcx+72]
    adc    rax, r14           
    mov    [rcx+72], rax 
    mov    rax, [rsp]
    adc    r8, rax 
    mov    [rcx+80], r8    // Result C10-C19
    mov    rax, [rsp+8]
    adc    r9, rax
    mov    [rcx+88], r9 
    mov    rax, [rsp+16]
    adc    r10, rax
    mov    [rcx+96], r10 
    mov    rax, [rsp+24]
    adc    r11, rax
    mov    [rcx+104], r11 
    mov    rax, [rsp+32]
    adc    r12, rax
    mov    [rcx+112], r12 
    mov    r8, [rsp+40]
    mov    r9, [rsp+48]
    mov    r10, [rsp+56]
    mov    r11, [rsp+64]
    mov    r12, [rsp+72]
    adc    r8, 0
    adc    r9, 0
    adc    r10, 0
    adc    r11, 0
    adc    r12, 0
    add    rsp, 112   
    mov    [rcx+120], r8 
    mov    [rcx+128], r9 
    mov    [rcx+136], r10 
    mov    [rcx+144], r11 
    mov    [rcx+152], r12 
      
    pop    rbx
    pop    r15
    pop    r14
    pop    r13
    pop    r12
    ret

#else

//***********************************************************************
//  Integer multiplication
//  Based on Karatsuba method
//  Operation: c [reg_p3] = a [reg_p1] * b [reg_p2]
//  NOTE: a=c or b=c are not allowed
//***********************************************************************
.global fmt(mul610_asm)
fmt(mul610_asm):

  ret

# error "CONFIGURATION NOT SUPPORTED. TRY USE_MULX=TRUE"

#endif


#ifdef _MULX_

///////////////////////////////////////////////////////////////// MACRO
// Schoolbook integer multiplication
// Inputs:  memory pointers M0 and M1
// Outputs: regs T0:T7
// Temps:   regs T8
/////////////////////////////////////////////////////////////////

#ifdef _ADX_
.macro MUL128x384_SCHOOL M0, M1, T0, T1, T2, T3, T4, T5, T6, T7, T8
    mov    rdx, \M0
    mulx   \T1, \T0, \M1       // T0 <- C0_final    
    mulx   \T2, \T4, 8\M1
    xor    rax, rax
    mulx   \T3, \T5, 16\M1 
    adox   \T1, \T4               
    adox   \T2, \T5     
    mulx   \T4, \T7, 24\M1
    adox   \T3, \T7         
    mulx   \T5, \T6, 32\M1 
    adox   \T4, \T6         
    mulx   \T7, \T8, 40\M1           
    adox   \T5, \T8         
    adox   \T7, rax   
    
    mov    rdx, 8\M0 
    mulx   \T8, \T6, \M1 
    adcx   \T1, \T6            // T1 <- C1_final 
    adcx   \T2, \T8    
    mulx   \T6, \T8, 8\M1
    adox   \T2, \T8  
    adcx   \T3, \T6        
    mulx   \T6, \T8, 16\M1
    adox   \T3, \T8
    adcx   \T4, \T6     
    mulx   \T6, \T8, 24\M1
    adox   \T4, \T8     
    adcx   \T5, \T6  
    mulx   \T6, \T8, 32\M1 
    adox   \T5, \T8 
    adcx   \T6, \T7 
    mulx   \T7, \T8, 40\M1
    adcx   \T7, rax  
    adox   \T6, \T8          
    adox   \T7, rax
.endm

#else

.macro MUL128x384_SCHOOL M0, M1, T0, T1, T2, T3, T4, T5, T6, T7, T8
    mov    rdx, \M0
    mulx   \T1, \T0, \M1       // T0 <- C0_final 
    mulx   \T2, \T3, 8\M1
    add    \T1, \T3               
    adc    \T2, 0  

    mov    rdx, 8\M0   
    xor    \T5, \T5
    mulx   \T3, \T4, \M1 
    add    \T1, \T4               
    adc    \T2, \T3  
    adc    \T5, 0  
      
    xor    \T6, \T6
    mulx   \T3, \T4, 8\M1
    add    \T2, \T4  
    adc    \T3, \T5           
    adc    \T6, 0 
        
    mov    rdx, \M0         
    mulx   \T4, \T5, 16\M1 
    add    \T2, \T5  
    adc    \T3, \T4           
    adc    \T6, 0  
        
    xor    \T7, \T7        
    mulx   \T4, \T5, 24\M1 
    add    \T3, \T5  
    adc    \T4, \T6           
    adc    \T7, 0  

    mov    rdx, 8\M0 
    mulx   \T5, \T6, 16\M1 
    add    \T3, \T6               
    adc    \T4, \T5  
    adc    \T7, 0    
        
    xor    \T6, \T6        
    mulx   \T5, \T8, 24\M1 
    add    \T4, \T8  
    adc    \T5, \T7           
    adc    \T6, 0  
        
    mov    rdx, \M0        
    mulx   \T7, \T8, 32\M1 
    add    \T4, \T8  
    adc    \T5, \T7           
    adc    \T6, 0      
        
    xor    \T7, \T7        
    mulx   \T8, rax, 40\M1 
    add    \T5, rax  
    adc    \T6, \T8          
    adc    \T7, 0  
        
    mov    rdx, 8\M0        
    mulx   \T8, rax, 32\M1 
    add    \T5, rax  
    adc    \T6, \T8         
    adc    \T7, 0   
        
    mov    rdx, 8\M0        
    mulx   \T8, rax, 40\M1 
    add    \T6, rax  
    adc    \T7, \T8  
.endm
#endif

  
//**************************************************************************************
//  Montgomery reduction
//  Based on method described in Faz-Hernandez et al. https://eprint.iacr.org/2017/1015  
//  Operation: c [reg_p2] = a [reg_p1]
//  NOTE: a=c is not allowed
//************************************************************************************** 
.global fmt(rdc610_asm)
fmt(rdc610_asm):
    push   r12
    push   r13 
    push   r14 
    push   r15  

    // a[0-1] x p610p1_nz --> result: r8:r15 
    MUL128x384_SCHOOL [reg_p1], [rip+fmt(p610p1)+32], r8, r9, r10, r11, r12, r13, r14, r15, rcx     

    xor    rcx, rcx
    add    r8, [reg_p1+32]  
    adc    r9, [reg_p1+40]  
    adc    r10, [reg_p1+48]   
    adc    r11, [reg_p1+56]   
    adc    r12, [reg_p1+64]   
    adc    r13, [reg_p1+72]   
    adc    r14, [reg_p1+80]  
    adc    r15, [reg_p1+88]   
    adc    rcx, [reg_p1+96] 
    mov    [reg_p1+32], r8  
    mov    [reg_p1+40], r9  
    mov    [reg_p1+48], r10  
    mov    [reg_p1+56], r11  
    mov    [reg_p1+64], r12  
    mov    [reg_p1+72], r13  
    mov    [reg_p1+80], r14
    mov    [reg_p1+88], r15  
    mov    [reg_p1+96], rcx  
    mov    r8, [reg_p1+104]  
    mov    r9, [reg_p1+112]  
    mov    r10, [reg_p1+120]
    mov    r11, [reg_p1+128]
    mov    r12, [reg_p1+136]
    mov    r13, [reg_p1+144]
    mov    r14, [reg_p1+152]
    adc    r8, 0
    adc    r9, 0
    adc    r10, 0
    adc    r11, 0
    adc    r12, 0
    adc    r13, 0
    adc    r14, 0
    mov    [reg_p1+104], r8  
    mov    [reg_p1+112], r9  
    mov    [reg_p1+120], r10  
    mov    [reg_p1+128], r11  
    mov    [reg_p1+136], r12 
    mov    [reg_p1+144], r13 
    mov    [reg_p1+152], r14

    // a[2-3] x p610p1_nz --> result: r8:r15
    MUL128x384_SCHOOL [reg_p1+16], [rip+fmt(p610p1)+32], r8, r9, r10, r11, r12, r13, r14, r15, rcx 

    xor    rcx, rcx
    add    r8, [reg_p1+48]  
    adc    r9, [reg_p1+56]  
    adc    r10, [reg_p1+64]   
    adc    r11, [reg_p1+72]  
    adc    r12, [reg_p1+80]   
    adc    r13, [reg_p1+88]   
    adc    r14, [reg_p1+96]  
    adc    r15, [reg_p1+104]
    adc    rcx, [reg_p1+112]
    mov    [reg_p1+48], r8  
    mov    [reg_p1+56], r9  
    mov    [reg_p1+64], r10  
    mov    [reg_p1+72], r11   
    mov    [reg_p1+80], r12  
    mov    [reg_p1+88], r13  
    mov    [reg_p1+96], r14
    mov    [reg_p1+104], r15
    mov    [reg_p1+112], rcx
    mov    r8, [reg_p1+120]
    mov    r9, [reg_p1+128]
    mov    r10, [reg_p1+136] 
    mov    r11, [reg_p1+144] 
    mov    r12, [reg_p1+152] 
    adc    r8, 0
    adc    r9, 0
    adc    r10, 0  
    adc    r11, 0 
    adc    r12, 0  
    mov    [reg_p1+120], r8  
    mov    [reg_p1+128], r9  
    mov    [reg_p1+136], r10 
    mov    [reg_p1+144], r11 
    mov    [reg_p1+152], r12 

    // a[4-5] x p610p1_nz --> result: r8:r15
    MUL128x384_SCHOOL [reg_p1+32], [rip+fmt(p610p1)+32], r8, r9, r10, r11, r12, r13, r14, r15, rcx 

    xor    rcx, rcx
    add    r8, [reg_p1+64]  
    adc    r9, [reg_p1+72]  
    adc    r10, [reg_p1+80]   
    adc    r11, [reg_p1+88]  
    adc    r12, [reg_p1+96]   
    adc    r13, [reg_p1+104]   
    adc    r14, [reg_p1+112]  
    adc    r15, [reg_p1+120]
    adc    rcx, [reg_p1+128]
    mov    [reg_p1+64], r8  
    mov    [reg_p1+72], r9  
    mov    [reg_p1+80], r10  
    mov    [reg_p1+88], r11   
    mov    [reg_p1+96], r12  
    mov    [reg_p1+104], r13  
    mov    [reg_p1+112], r14
    mov    [reg_p1+120], r15
    mov    [reg_p1+128], rcx
    mov    r8, [reg_p1+136]
    mov    r9, [reg_p1+144]
    mov    r10, [reg_p1+152] 
    adc    r8, 0
    adc    r9, 0
    adc    r10, 0 
    mov    [reg_p1+136], r8  
    mov    [reg_p1+144], r9  
    mov    [reg_p1+152], r10 

    // a[6-7] x p610p1_nz --> result: r8:r15
    MUL128x384_SCHOOL [reg_p1+48], [rip+fmt(p610p1)+32], r8, r9, r10, r11, r12, r13, r14, r15, rcx 

    xor    rcx, rcx
    add    r8, [reg_p1+80]  
    adc    r9, [reg_p1+88]  
    adc    r10, [reg_p1+96]   
    adc    r11, [reg_p1+104]  
    adc    r12, [reg_p1+112]   
    adc    r13, [reg_p1+120]   
    adc    r14, [reg_p1+128]  
    adc    r15, [reg_p1+136]
    adc    rcx, [reg_p1+144]
    mov    [reg_p2], r8         // C0_final
    mov    [reg_p2+8], r9       // C1_final
    mov    [reg_p1+96], r10  
    mov    [reg_p1+104], r11   
    mov    [reg_p1+112], r12  
    mov    [reg_p1+120], r13  
    mov    [reg_p1+128], r14
    mov    [reg_p1+136], r15
    mov    [reg_p1+144], rcx
    mov    r8, [reg_p1+152] 
    adc    r8, 0
    mov    [reg_p1+152], r8

    // a[8-9] x p610p1_nz --> result: r8:r15
    MUL128x384_SCHOOL [reg_p1+64], [rip+fmt(p610p1)+32], r8, r9, r10, r11, r12, r13, r14, r15, rcx
    
    // Final result C2:C9
    add    r8, [reg_p1+96]  
    adc    r9, [reg_p1+104]  
    adc    r10, [reg_p1+112]   
    adc    r11, [reg_p1+120]  
    adc    r12, [reg_p1+128]   
    adc    r13, [reg_p1+136]   
    adc    r14, [reg_p1+144]   
    adc    r15, [reg_p1+152] 
    mov    [reg_p2+16], r8
    mov    [reg_p2+24], r9  
    mov    [reg_p2+32], r10   
    mov    [reg_p2+40], r11  
    mov    [reg_p2+48], r12  
    mov    [reg_p2+56], r13 
    mov    [reg_p2+64], r14 
    mov    [reg_p2+72], r15

    pop    r15
    pop    r14
    pop    r13
    pop    r12
    ret

  #else
  
//***********************************************************************
//  Montgomery reduction
//  Based on comba method
//  Operation: c [reg_p2] = a [reg_p1]
//  NOTE: a=c is not allowed
//*********************************************************************** 
.global fmt(rdc610_asm)
fmt(rdc610_asm):

  ret

# error "CONFIGURATION NOT SUPPORTED. TRY USE_MULX=TRUE"

  #endif


//***********************************************************************
//  610-bit multiprecision addition
//  Operation: c [reg_p3] = a [reg_p1] + b [reg_p2]
//*********************************************************************** 
.global fmt(mp_add610_asm)
fmt(mp_add610_asm):  
  mov    r8, [reg_p1]
  mov    r9, [reg_p1+8]
  mov    r10, [reg_p1+16]
  mov    r11, [reg_p1+24]
  mov    rax, [reg_p1+32]
  add    r8, [reg_p2] 
  adc    r9, [reg_p2+8] 
  adc    r10, [reg_p2+16] 
  adc    r11, [reg_p2+24] 
  adc    rax, [reg_p2+32] 
  mov    [reg_p3], r8
  mov    [reg_p3+8], r9
  mov    [reg_p3+16], r10
  mov    [reg_p3+24], r11
  mov    [reg_p3+32], rax

  mov    r8, [reg_p1+40]
  mov    r9, [reg_p1+48] 
  mov    r10, [reg_p1+56]
  mov    r11, [reg_p1+64] 
  mov    rax, [reg_p1+72] 
  adc    r8, [reg_p2+40] 
  adc    r9, [reg_p2+48]
  adc    r10, [reg_p2+56] 
  adc    r11, [reg_p2+64]
  adc    rax, [reg_p2+72]
  mov    [reg_p3+40], r8
  mov    [reg_p3+48], r9
  mov    [reg_p3+56], r10
  mov    [reg_p3+64], r11
  mov    [reg_p3+72], rax
  ret


//***********************************************************************
//  2x610-bit multiprecision subtraction/addition
//  Operation: c [x2] = a [x0] - b [x1]. If c < 0, add p610*2^640
//*********************************************************************** 
.global fmt(mp_subadd610x2_asm)
fmt(mp_subadd610x2_asm):
  push   r12
  push   r13 
  push   r14 
  push   r15
  push   rbx
  xor    rax, rax
  mov    r8, [reg_p1]
  mov    r9, [reg_p1+8]
  mov    r10, [reg_p1+16]
  mov    r11, [reg_p1+24]
  mov    rcx, [reg_p1+32]
  sub    r8, [reg_p2] 
  sbb    r9, [reg_p2+8] 
  sbb    r10, [reg_p2+16] 
  sbb    r11, [reg_p2+24] 
  sbb    rcx, [reg_p2+32] 
  mov    [reg_p3], r8
  mov    [reg_p3+8], r9
  mov    [reg_p3+16], r10
  mov    [reg_p3+24], r11
  mov    [reg_p3+32], rcx

  mov    r8, [reg_p1+40]
  mov    r9, [reg_p1+48]
  mov    r10, [reg_p1+56] 
  mov    r11, [reg_p1+64]
  mov    rcx, [reg_p1+72] 
  sbb    r8, [reg_p2+40] 
  sbb    r9, [reg_p2+48] 
  sbb    r10, [reg_p2+56]
  sbb    r11, [reg_p2+64] 
  sbb    rcx, [reg_p2+72]
  mov    [reg_p3+40], r8
  mov    [reg_p3+48], r9
  mov    [reg_p3+56], r10
  mov    [reg_p3+64], r11
  mov    [reg_p3+72], rcx
  
  mov    r8, [reg_p1+80]
  mov    r9, [reg_p1+88] 
  mov    r10, [reg_p1+96]
  mov    r11, [reg_p1+104]
  mov    rcx, [reg_p1+112]
  sbb    r8, [reg_p2+80]
  sbb    r9, [reg_p2+88]
  sbb    r10, [reg_p2+96] 
  sbb    r11, [reg_p2+104] 
  sbb    rcx, [reg_p2+112]
  mov    [reg_p3+80], r8 
  mov    [reg_p3+88], r9
  mov    [reg_p3+96], r10
  mov    [reg_p3+104], r11
  mov    [reg_p3+112], rcx
  
  mov    r8, [reg_p1+120]
  mov    r9, [reg_p1+128]
  mov    r10, [reg_p1+136]
  mov    r11, [reg_p1+144]
  mov    rcx, [reg_p1+152]
  sbb    r8, [reg_p2+120] 
  sbb    r9, [reg_p2+128] 
  sbb    r10, [reg_p2+136] 
  sbb    r11, [reg_p2+144] 
  sbb    rcx, [reg_p2+152]
  sbb    rax, 0
  
  // Add p610 anded with the mask in rax 
  mov    r12, [rip+fmt(p610)]
  mov    r13, [rip+fmt(p610)+32]
  mov    r14, [rip+fmt(p610)+40]
  mov    r15, [rip+fmt(p610)+48]
  mov    rdi, [rip+fmt(p610)+56]
  mov    rsi, [rip+fmt(p610)+64]
  mov    rbx, [rip+fmt(p610)+72]
  and    r12, rax
  and    r13, rax
  and    r14, rax
  and    r15, rax
  and    rdi, rax
  and    rsi, rax
  and    rbx, rax
  mov    rax, [reg_p3+80]
  add    rax, r12
  mov    [reg_p3+80], rax
  mov    rax, [reg_p3+88]
  adc    rax, r12
  mov    [reg_p3+88], rax
  mov    rax, [reg_p3+96]
  adc    rax, r12
  mov    [reg_p3+96], rax
  adc    r12, [reg_p3+104]
  adc    r13, [reg_p3+112]
  mov    [reg_p3+104], r12
  mov    [reg_p3+112], r13
  adc    r8, r14
  adc    r9, r15
  adc    r10, rdi
  adc    r11, rsi
  adc    rcx, rbx
  
  mov    [reg_p3+120], r8
  mov    [reg_p3+128], r9
  mov    [reg_p3+136], r10
  mov    [reg_p3+144], r11
  mov    [reg_p3+152], rcx
  pop    rbx
  pop    r15
  pop    r14
  pop    r13
  pop    r12
  ret


//***********************************************************************
//  Double 2x610-bit multiprecision subtraction
//  Operation: c [reg_p3] = c [reg_p3] - a [reg_p1] - b [reg_p2]
//*********************************************************************** 
.global fmt(mp_dblsub610x2_asm)
fmt(mp_dblsub610x2_asm):
  push   r12
  push   r13
  push   r14
  push   r15
  
  mov    r8, [reg_p3]
  mov    r9, [reg_p3+8]
  mov    r10, [reg_p3+16]
  mov    r11, [reg_p3+24]
  mov    r12, [reg_p3+32]
  mov    r13, [reg_p3+40]
  mov    r14, [reg_p3+48]
  mov    r15, [reg_p3+56]
  sub    r8, [reg_p1]
  sbb    r9, [reg_p1+8] 
  sbb    r10, [reg_p1+16] 
  sbb    r11, [reg_p1+24] 
  sbb    r12, [reg_p1+32] 
  sbb    r13, [reg_p1+40] 
  sbb    r14, [reg_p1+48] 
  sbb    r15, [reg_p1+56]
  setc   al
  sub    r8, [reg_p2]
  sbb    r9, [reg_p2+8] 
  sbb    r10, [reg_p2+16] 
  sbb    r11, [reg_p2+24] 
  sbb    r12, [reg_p2+32] 
  sbb    r13, [reg_p2+40] 
  sbb    r14, [reg_p2+48] 
  sbb    r15, [reg_p2+56]
  setc   cl
  mov    [reg_p3], r8
  mov    [reg_p3+8], r9
  mov    [reg_p3+16], r10
  mov    [reg_p3+24], r11
  mov    [reg_p3+32], r12
  mov    [reg_p3+40], r13
  mov    [reg_p3+48], r14
  mov    [reg_p3+56], r15
    
  mov    r8, [reg_p3+64]
  mov    r9, [reg_p3+72]
  mov    r10, [reg_p3+80]
  mov    r11, [reg_p3+88]
  mov    r12, [reg_p3+96]
  mov    r13, [reg_p3+104]
  mov    r14, [reg_p3+112]
  mov    r15, [reg_p3+120]
  bt     rax, 0 
  sbb    r8, [reg_p1+64] 
  sbb    r9, [reg_p1+72] 
  sbb    r10, [reg_p1+80] 
  sbb    r11, [reg_p1+88] 
  sbb    r12, [reg_p1+96] 
  sbb    r13, [reg_p1+104] 
  sbb    r14, [reg_p1+112] 
  sbb    r15, [reg_p1+120]
  setc   al 
  bt     rcx, 0  
  sbb    r8, [reg_p2+64] 
  sbb    r9, [reg_p2+72] 
  sbb    r10, [reg_p2+80] 
  sbb    r11, [reg_p2+88] 
  sbb    r12, [reg_p2+96] 
  sbb    r13, [reg_p2+104] 
  sbb    r14, [reg_p2+112] 
  sbb    r15, [reg_p2+120]
  setc   cl 
  mov    [reg_p3+64], r8
  mov    [reg_p3+72], r9
  mov    [reg_p3+80], r10
  mov    [reg_p3+88], r11
  mov    [reg_p3+96], r12
  mov    [reg_p3+104], r13
  mov    [reg_p3+112], r14
  mov    [reg_p3+120], r15
  
  mov    r8, [reg_p3+128]
  mov    r9, [reg_p3+136]
  mov    r10, [reg_p3+144]
  mov    r11, [reg_p3+152]
  bt     rax, 0 
  sbb    r8, [reg_p1+128] 
  sbb    r9, [reg_p1+136] 
  sbb    r10, [reg_p1+144] 
  sbb    r11, [reg_p1+152]
  bt     rcx, 0 
  sbb    r8, [reg_p2+128] 
  sbb    r9, [reg_p2+136] 
  sbb    r10, [reg_p2+144] 
  sbb    r11, [reg_p2+152]
  mov    [reg_p3+128], r8
  mov    [reg_p3+136], r9
  mov    [reg_p3+144], r10
  mov    [reg_p3+152], r11
  
  pop    r15
  pop    r14
  pop    r13
  pop    r12
  ret


///////////////////////////////////////////////////////////////// MACRO
// z = a x bi + z
// Inputs: base memory pointer M1 (a),
//         bi pre-stored in rdx,
//         accumulator z in [M0:M2, Z3:Z10]
// Output: [M0:M2, Z3:Z10]
// Temps:  regs T0:T1
/////////////////////////////////////////////////////////////////
.macro MULADD64x640 M1, M, Z3, Z4, Z5, Z6, Z7, Z8, Z9, Z10, T0, T1, T2, C
    mulx   \T0, \T1, \M1     // A0*B0
	xor    \C, \C
    adox   \T1, \M
    adox   \T0, 8\M  
	mov    \M, \T1
    mulx   \T1, \T2, 8\M1    // A0*B1
    adcx   \T0, \T2
    adox   \T1, 16\M  
	mov    8\M, \T0   
    mulx   \T0, \T2, 16\M1   // A0*B2
    adcx   \T1, \T2
    adox   \Z3, \T0 
	mov    16\M, \T1  
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
    mulx   \T0, \T1, 64\M1   // A0*B8         
    adcx   \Z8, \T1
    adox   \Z9, \T0
    mulx   \T0, \T1, 72\M1   // A0*B9         
    adcx   \Z9, \T1
    adox   \Z10, \T0
    adc    \Z10, 0 
.endm


.macro MULADD64x640b M1, M, MM, Z3, Z4, Z5, Z6, Z7, Z8, Z9, Z10, T0, T1, T2, C
    mulx   \T0, \T1, \M1     // A0*B0
	xor    \C, \C
    adox   \T1, \M
    adox   \T0, 8\M  
	mov    24\M, \T1
    mulx   \T1, \T2, 8\M1    // A0*B1
    adcx   \T0, \T2
    adox   \T1, 16\M  
	mov    \MM, \T0   
    mulx   \T0, \T2, 16\M1   // A0*B2
    adcx   \T1, \T2
    adox   \Z3, \T0 
	mov    8\MM, \T1  
    mulx   \T0, \T1, 24\M1   // A0*B3          
    adcx   \Z3, \T1
    adox   \Z4, \T0
    mulx   \T0, \T1, 32\M1   // A0*B4    
	mov    16\MM, \Z3        
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
    mulx   \T0, \T1, 64\M1   // A0*B8         
    adcx   \Z8, \T1
    adox   \Z9, \T0
    mulx   \T0, \T1, 72\M1   // A0*B9         
    adcx   \Z9, \T1
    adox   \Z10, \T0
    adc    \Z10, 0 
.endm


.macro MULADD64x640c M1, Z0, M, Z3, Z4, Z5, Z6, Z7, Z8, Z9, Z10, T0, T1
	xor    \T0, \T0
	mov    16\M, \Z9
	mov    24\M, \Z10
    mulx   \T0, \T1, \M1     // A0*B0
	mov    \Z9, \M
	mov    \Z10, 8\M
    adox   \Z0, \T1
    adox   \Z9, \T0
    mulx   \T0, \T1, 8\M1    // A0*B1
    adcx   \Z9, \T1
    adox   \Z10, \T0  
    mulx   \T0, \T1, 16\M1   // A0*B2
	mov    \M, \Z9
    adcx   \Z10, \T1
    adox   \Z3, \T0   
    mulx   \T0, \T1, 24\M1   // A0*B3  
	mov    8\M, \Z10        
    adcx   \Z3, \T1
    adox   \Z4, \T0
    mulx   \T0, \T1, 32\M1   // A0*B4 
	mov    \Z9, 16\M
	mov    \Z10, 24\M          
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
    mulx   \T0, \T1, 64\M1   // A0*B8         
    adcx   \Z8, \T1
    adox   \Z9, \T0
    mulx   \T0, \T1, 72\M1   // A0*B9         
    adcx   \Z9, \T1
    adox   \Z10, \T0
    adc    \Z10, 0 
.endm


.macro MULADD64x384 M1, Z0, Z1, Z2, Z3, Z4, Z5, Z6, T0, T1
    mulx   \T0, \T1, \M1     // A0*B0
	xor    rax, rax
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
    adc    \Z6, 0    
.endm


.macro MULADD64x384b M1, Z0, Z1, Z2, Z3, Z4, Z5, Z6, T0, T1
	xor    \T0, \T0
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
    adc    \Z6, 0    
.endm


//***********************************************************************
//  Multiplication in GF(p^2), complex part
//  Operation: c [reg_p3] = a0 x b1 + a1 x b0
//  Inputs: a = [a1, a0] stored in [reg_p1] 
//          b = [b1, b0] stored in [reg_p2] 
//  Output: c stored in [reg_p3]
//***********************************************************************
.global fp2mul610_c1_asm
fp2mul610_c1_asm: 
    push   r12    
    push   r13       
    mov    rcx, reg_p3
    
    // [rcx0:rcx16, r11:r15, r8:r10] <- z = a0 x b10 + a1 x b00
    mov    rdx, [reg_p2]
    mulx   r9, r8, [reg_p1+80] 
    xor    rax, rax 
    mulx   r10, r11, [reg_p1+88] 
	mov    [rcx], r8
    adcx   r9, r11 
    mulx   r11, r12, [reg_p1+96]
	mov    [rcx+8], r9  
    adcx   r10, r12         
    mulx   r12, r13, [reg_p1+104] 
	mov    [rcx+16], r10  
    adcx   r11, r13       
    mulx   r13, r8, [reg_p1+112]    
    push   r14 
    adcx   r12, r8      
    mulx   r14, r9, [reg_p1+120]
    push   r15 
    adcx   r13, r9      
    mulx   r15, rax, [reg_p1+128]
    adcx   r14, rax     
    mulx   r8, r10, [reg_p1+136]       
    push   rbx
    adcx   r15, r10     
    mulx   r9, rax, [reg_p1+144]   
    push   rbp 
    adcx   r8, rax    
    mulx   r10, rbx, [reg_p1+152] 
    adcx   r9, rbx    
    adc    r10, 0 
           
    mov    rdx, [reg_p2+80]    
    MULADD64x640b [reg_p1], [rcx], [rcx], r11, r12, r13, r14, r15, r8, r9, r10, rbx, rbp, rax, rax        
    // [rsp8:rsp24, r12:r15, r8:r10] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rcx+24]                  // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r12, r13, r14, r15, r8, r9, r10, rbx, rbp

    // [rsp8:rsp24, r12:r15, r8:r11] <- z = a0 x b11 + a1 x b01 + z 
    mov    rdx, [reg_p2+8]
    MULADD64x640 [reg_p1+80], [rcx], r12, r13, r14, r15, r8, r9, r10, r11, rbx, rbp, rax, r11
    mov    rdx, [reg_p2+88]    
    MULADD64x640b [reg_p1], [rcx], [rcx], r12, r13, r14, r15, r8, r9, r10, r11, rbx, rbp, rax, rax
    // [rsp16:rsp32, r13:r15, r8:r11] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rcx+24]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r13, r14, r15, r8, r9, r10, r11, rbx, rbp

    // [rsp16:rsp32, r13:r15, r8:r12] <- z = a0 x b12 + a1 x b02 + z 
    mov    rdx, [reg_p2+16]
    MULADD64x640 [reg_p1+80], [rcx], r13, r14, r15, r8, r9, r10, r11, r12, rbx, rbp, rax, r12
    mov    rdx, [reg_p2+96]    
    MULADD64x640b [reg_p1], [rcx], [rcx], r13, r14, r15, r8, r9, r10, r11, r12, rbx, rbp, rax, rax
    // [rsp24:rsp40, r14:r15, r8:r12] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rcx+24]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r14, r15, r8, r9, r10, r11, r12, rbx, rbp

    // [rsp24:rsp40, r14:r15, r8:r13] <- z = a0 x b13 + a1 x b03 + z 
    mov    rdx, [reg_p2+24]
    MULADD64x640 [reg_p1+80], [rcx], r14, r15, r8, r9, r10, r11, r12, r13, rbx, rbp, rax, r13
    mov    rdx, [reg_p2+104]    
    MULADD64x640b [reg_p1], [rcx], [rcx], r14, r15, r8, r9, r10, r11, r12, r13, rbx, rbp, rax, rax
    // [rsp32:rsp48, r15, r8:r13] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rcx+24]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r15, r8, r9, r10, r11, r12, r13, rbx, rbp

    // [rsp32:rsp48, r15, r8:r14] <- z = a0 x b14 + a1 x b04 + z 
    mov    rdx, [reg_p2+32]
    MULADD64x640 [reg_p1+80], [rcx], r15, r8, r9, r10, r11, r12, r13, r14, rbx, rbp, rax, r14
    mov    rdx, [reg_p2+112]    
    MULADD64x640b [reg_p1], [rcx], [rcx], r15, r8, r9, r10, r11, r12, r13, r14, rbx, rbp, rax, rax
    // [rsp40:rsp56, r8:r14] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rcx+24]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r8, r9, r10, r11, r12, r13, r14, rbx, rbp

    // [rsp40:rsp56, r8:r15] <- z = a0 x b15 + a1 x b05 + z 
    mov    rdx, [reg_p2+40]
    MULADD64x640 [reg_p1+80], [rcx], r8, r9, r10, r11, r12, r13, r14, r15, rbx, rbp, rax, r15
    mov    rdx, [reg_p2+120]    
    MULADD64x640b [reg_p1], [rcx], [rcx], r8, r9, r10, r11, r12, r13, r14, r15, rbx, rbp, rax, rax
    // [rsp48:rsp64, r9:r15] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rcx+24]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r9, r10, r11, r12, r13, r14, r15, rbx, rbp

    // [rsp48:rsp64, r9:r15, r8] <- z = a0 x b16 + a1 x b06 + z 
    mov    rdx, [reg_p2+48]
    MULADD64x640 [reg_p1+80], [rcx], r9, r10, r11, r12, r13, r14, r15, r8, rbx, rbp, rax, r8
    mov    rdx, [reg_p2+128]    
    MULADD64x640b [reg_p1], [rcx], [rcx], r9, r10, r11, r12, r13, r14, r15, r8, rbx, rbp, rax, rax
    // [rsp56:rsp72, r10:r15, r8] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rcx+24]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r10, r11, r12, r13, r14, r15, r8, rbx, rbp

    // [rsp56:rsp72, r10:r15, r8:r9] <- z = a0 x b17 + a1 x b07 + z 
    mov    rdx, [reg_p2+56]
    MULADD64x640 [reg_p1+80], [rcx], r10, r11, r12, r13, r14, r15, r8, r9, rbx, rbp, rax, r9
    mov    rdx, [reg_p2+136]    
    MULADD64x640b [reg_p1], [rcx], [rcx], r10, r11, r12, r13, r14, r15, r8, r9, rbx, rbp, rax, rax
    // [rsp64:rsp80, r11:r15, r8:r9] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rcx+24]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r11, r12, r13, r14, r15, r8, r9, rbx, rbp

    // [rsp64:rsp80, r11:r15, r8:r10] <- z = a0 x b18 + a1 x b08 + z 
    mov    rdx, [reg_p2+64]
    MULADD64x640 [reg_p1+80], [rcx], r11, r12, r13, r14, r15, r8, r9, r10, rbx, rbp, rax, r10
    mov    rdx, [reg_p2+144]    
    MULADD64x640b [reg_p1], [rcx], [rcx], r11, r12, r13, r14, r15, r8, r9, r10, rbx, rbp, rax, rax
    // [rsp72:rsp88, r12:r15, r8:r10] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rcx+24]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r12, r13, r14, r15, r8, r9, r10, rbx, rbp

    // [rsp72:rsp88, r12:r15, r8:r11] <- z = a0 x b19 + a1 x b09 + z 
    mov    rdx, [reg_p2+72]
    MULADD64x640 [reg_p1+80], [rcx], r12, r13, r14, r15, r8, r9, r10, r11, rbx, rbp, rax, r11
    mov    rdx, [reg_p2+152]    
    MULADD64x640b [reg_p1], [rcx], [rcx], r12, r13, r14, r15, r8, r9, r10, r11, rbx, rbp, rax, rax
    // [rsp80:rsp96, r13:r15, r8:r11] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rcx+24]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r13, r14, r15, r8, r9, r10, r11, rbx, rbp
         
    mov    [rcx+24], r13 
    mov    [rcx+32], r14   
    mov    [rcx+40], r15 
    mov    [rcx+48], r8   
    mov    [rcx+56], r9      
    mov    [rcx+64], r10                  
    mov    [rcx+72], r11
    pop    rbp
    pop    rbx
    pop    r15 
    pop    r14
    pop    r13
    pop    r12
    ret

/*
/////////////////////////////////////////////////////////////////////////// MACRO
// Schoolbook integer multiplication
// Inputs:  memory pointers M0 and M1
// Outputs: memory pointer C
// Temps:   regs T0:T7
///////////////////////////////////////////////////////////////////////////
.macro MULADD320_SCHOOL M0, M1, C, Z0, Z1, Z2, Z3, Z4, Z5, T0, T1 
    mov    rdx, \M0 
    xor    \T0, \T0 
    mulx   \T0, \T1, \M1 
	adcx   \Z0, \T1 
	adox   \Z1, \T0
    mov    \C, \Z0             // C0_final 
    mulx   \T0, \T1, 8\M1
	adcx   \Z1, \T1
	adox   \Z2, \T0
    mulx   \T0, \T1, 16\M1 
    adcx   \Z2, \T1               
    adox   \Z3, \T0  
    mulx   \T0, \T1, 24\M1
    adcx   \Z3, \T1               
    adox   \Z4, \T0   
    mulx   \T0, \T1, 32\M1 
    adcx   \Z4, \T1               
    adox   \Z5, \T0   
	adc    \Z5, 0
	////////////////////// no carry here when multiplying with mH
    
    mov    rdx, 8\M0
    mulx   \T0, \T1, \M1  
    xor    \Z0, \Z0 
	adcx   \Z1, \T1 
	adox   \Z2, \T0
    mov    8\C, \Z1            // C1_final 
    mulx   \T0, \T1, 8\M1
	adcx   \Z2, \T1
	adox   \Z3, \T0
    mulx   \T0, \T1, 16\M1 
    adcx   \Z3, \T1               
    adox   \Z4, \T0  
    mulx   \T0, \T1, 24\M1
    adcx   \Z4, \T1               
    adox   \Z5, \T0   
    mulx   \T0, \T1, 32\M1 
    adcx   \Z5, \T1               
    adox   \Z0, \T0 
	adc    \Z0, 0 
    
    mov    rdx, 16\M0
    mulx   \T0, \T1, \M1  
    xor    \Z1, \Z1 
	adcx   \Z2, \T1 
	adox   \Z3, \T0
    mov    16\C, \Z3            // C2_final 
    mulx   \T0, \T1, 8\M1
	adcx   \Z3, \T1
	adox   \Z4, \T0
    mulx   \T0, \T1, 16\M1 
    adcx   \Z4, \T1               
    adox   \Z5, \T0  
    mulx   \T0, \T1, 24\M1
    adcx   \Z5, \T1               
    adox   \Z0, \T0   
    mulx   \T0, \T1, 32\M1 
    adcx   \Z0, \T1               
    adox   \Z1, \T0 
	adc    \Z1, 0  
    
    mov    rdx, 24\M0
    mulx   \T0, \T1, \M1  
    xor    \Z2, \Z2 
	adcx   \Z3, \T1 
	adox   \Z4, \T0
    mov    24\C, \Z3            // C3_final 
    mulx   \T0, \T1, 8\M1
	adcx   \Z4, \T1
	adox   \Z5, \T0
    mulx   \T0, \T1, 16\M1 
    adcx   \Z5, \T1               
    adox   \Z0, \T0  
    mulx   \T0, \T1, 24\M1
    adcx   \Z0, \T1               
    adox   \Z1, \T0   
    mulx   \T0, \T1, 32\M1 
    adcx   \Z1, \T1               
    adox   \Z2, \T0 
	adc    \Z2, 0  
    
    mov    rdx, 32\M0
    mulx   \T0, \T1, \M1  
    xor    \Z3, \Z3 
	adcx   \Z4, \T1 
	adox   \Z5, \T0
    /////////mov    32\C, \Z4            // C4_final 
    mulx   \T0, \T1, 8\M1
	adcx   \Z5, \T1
	adox   \Z0, \T0
    mulx   \T0, \T1, 16\M1 
    adcx   \Z0, \T1               
    adox   \Z1, \T0  
    mulx   \T0, \T1, 24\M1
    adcx   \Z1, \T1               
    adox   \Z2, \T0   
    mulx   \T0, \T1, 32\M1 
    adcx   \Z2, \T1               
    adox   \Z3, \T0 
	adc    \Z3, 0   

    /////////mov    40\C, \Z5 
    /////////mov    48\C, \Z0 
    /////////mov    56\C, \Z1 
    /////////mov    64\C, \Z2
    /////////mov    72\C, \Z3
.endm


.macro MULADD320_SCHOOLb M0, M1, C, Z, Z0, Z1, Z2, Z3, Z4, Z5, Z6, T0, T1, T2
    mov    rdx, \M0 
	and    \T2, rbx
    mulx   \T0, \T1, \M1 
    xor    \Z6, \Z6 
	adcx   \Z0, \T1 
	adox   \Z1, \T0
    mov    \C, \Z0             // C0_final 
    mulx   \T0, \T1, 8\M1
	adcx   \Z1, \T1
	adox   \Z2, \T0
    mulx   \T0, \T1, 16\M1 
    adcx   \Z2, \T1               
    adox   \Z3, \T0  
    mulx   \T0, \T1, 24\M1
    adcx   \Z3, \T1               
    adox   \Z4, \T0   
    mulx   \T0, \T1, 32\M1 
    adcx   \Z4, \T1               
    adox   \Z5, \T0   
	adcx   \Z5, \T2               
    adox   \Z6, \Z6   
	adc    \Z6, 0
    
    mov    rdx, 8\M0 
	and    \T2, rbx
    mulx   \T0, \T1, \M1  
    xor    \Z0, \Z0 
	adcx   \Z1, \T1 
	adox   \Z2, \T0
    mov    8\C, \Z1            // C1_final 
    mulx   \T0, \T1, 8\M1
	adcx   \Z2, \T1
	adox   \Z3, \T0
    mulx   \T0, \T1, 16\M1 
    adcx   \Z3, \T1               
    adox   \Z4, \T0  
    mulx   \T0, \T1, 24\M1
    adcx   \Z4, \T1               
    adox   \Z5, \T0   
    mulx   \T0, \T1, 32\M1 
    adcx   \Z5, \T1               
    adox   \Z6, \T0 
	adcx   \Z6, \T2               
    adox   \Z0, 48\Z   
	adc    \Z0, 0
    
    mov    rdx, 16\M0 
	and    \T2, rbx
    mulx   \T0, \T1, \M1  
    xor    \Z1, \Z1 
	adcx   \Z2, \T1 
	adox   \Z3, \T0
    mov    16\C, \Z3            // C2_final 
    mulx   \T0, \T1, 8\M1
	adcx   \Z3, \T1
	adox   \Z4, \T0
    mulx   \T0, \T1, 16\M1 
    adcx   \Z4, \T1               
    adox   \Z5, \T0  
    mulx   \T0, \T1, 24\M1
    adcx   \Z5, \T1               
    adox   \Z6, \T0   
    mulx   \T0, \T1, 32\M1 
    adcx   \Z6, \T1               
    adox   \Z0, \T0 
	adcx   \Z0, \T2               
    adox   \Z1, 56\Z   
	adc    \Z1, 0 
    
    mov    rdx, 24\M0 
	and    \T2, rbx
    mulx   \T0, \T1, \M1  
    xor    \Z2, \Z2 
	adcx   \Z3, \T1 
	adox   \Z4, \T0
    mov    24\C, \Z3            // C3_final 
    mulx   \T0, \T1, 8\M1
	adcx   \Z4, \T1
	adox   \Z5, \T0
    mulx   \T0, \T1, 16\M1 
    adcx   \Z5, \T1               
    adox   \Z6, \T0  
    mulx   \T0, \T1, 24\M1
    adcx   \Z6, \T1               
    adox   \Z0, \T0   
    mulx   \T0, \T1, 32\M1 
    adcx   \Z0, \T1               
    adox   \Z1, \T0 
	adcx   \Z1, \T2                
    adox   \Z2, 64\Z   
	adc    \Z2, 0 
    
    mov    rdx, 32\M0 
	and    \T2, rbx
    mulx   \T0, \T1, \M1  
    xor    \Z3, \Z3 
	adcx   \Z4, \T1 
	adox   \Z5, \T0
    /////////mov    32\C, \Z4            // C4_final 
    mulx   \T0, \T1, 8\M1
	adcx   \Z5, \T1
	adox   \Z6, \T0
    mulx   \T0, \T1, 16\M1 
    adcx   \Z6, \T1               
    adox   \Z0, \T0  
    mulx   \T0, \T1, 24\M1
    adcx   \Z0, \T1               
    adox   \Z1, \T0   
    mulx   \T0, \T1, 32\M1 
    adcx   \Z1, \T1               
    adox   \Z2, \T0 
	adcx   \Z2, \T2                  
    adox   \Z3, 72\Z   
	adc    \Z3, 0  

	mov    \Z4, \M1
	mov    \Z6, 8\M1
	mov    \T0, 16\M1
	mov    \T1, 24\M1
	mov    rbx, 32\M1
	and    \Z4, rax
	and    \Z6, rax
	and    \T0, rax
	and    \T1, rax
	and    rbx, rax

	add    \Z5, \Z4
	adc    \Z0, \Z6
	adc    \Z1, \T0
	adc    \Z2, \T1
	adc    \Z3, rbx

    /////////mov    40\C, \Z5 
    /////////mov    48\C, \Z0 
    /////////mov    56\C, \Z1 
    /////////mov    64\C, \Z2
    /////////mov    72\C, \Z3
.endm


///////////////////////////////////////////////////////////////// MACRO
// z = a x bi + z
// Inputs: base memory pointer M1 (a),
//         bi pre-stored in rdx,
//         accumulator z in [Z0:Z6]
// Output: [Z0:Z6]
// Temps:  regs T0:T1
/////////////////////////////////////////////////////////////////
.macro MULADD64x320 M1, Z0, Z1, Z2, Z3, Z4, Z5, Z6, T0, T1, C
    mulx   \T0, \T1, \M1     // A0*B0
    xor    \C, \C
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
    adcx   \Z6, \C
	adox   \Z6, \C 
.endm


// 2-term Karatsuba (UNFINISHED)

.global fp2mul610_c1_asm
fp2mul610_c1_asm:   
    push   r12     
    push   r13     
    push   r14 
    push   r15      
    push   rbx  
    push   rbp
	sub    rsp, 336
    mov    rcx, reg_p3
    
    // [rsp0:rsp9] <- a00 x b00
	MUL320_SCHOOL [reg_p1], [reg_p2], [rsp], r8, r9, r10, r11, r12, r13, r14, r15 
    // [rsp10:rsp19] <- a10 x b10
	MUL320_SCHOOL [reg_p1+80], [reg_p2+80], [rsp+80], r8, r9, r10, r11, r12, r13, r14, r15 
	// [rsp0:rsp9], [rsp40] <- a00 x b00 + a10 x b10 (aLbL)                                      ///////// CHECK rsp40
	xor    rax, rax
    mov    r8, [rsp] 
    mov    r9, [rsp+8]
	add    r8, [rsp+48]
	adc    r9, [rsp+56]
	mov    [rsp], r8
	mov    [rsp+8], r9 
    mov    r8, [rsp+16] 
    mov    r9, [rsp+24]
	adc    r8, [rsp+64]
	adc    r9, [rsp+72]
	mov    [rsp+16], r8
	mov    [rsp+24], r9
    mov    r8, [rsp+32] 
    mov    r9, [rsp+40]
	adc    r8, [rsp+80]
	adc    r9, [rsp+88]
	mov    [rsp+328], r8    // 5th term of aLbL in [rsp41]
	mov    [rsp+40], r9
    mov    r10, [rsp+48] 
    mov    r11, [rsp+56]
	adc    r10, [rsp+96]
	adc    r11, [rsp+104]
	mov    [rsp+48], r10
	mov    [rsp+56], r11
    mov    r12, [rsp+64] 
    mov    r13, [rsp+72]
	adc    r12, [rsp+112]
	adc    r13, [rsp+120]
	mov    [rsp+64], r12
	mov    [rsp+72], r13
	adc    rax, 0
	mov    [rsp+320], rax

	// [rsp0:rsp4] <- qL
	mov    rdx, [rip+p610p1+32]
	mulx   r14, r15, [rsp]
	add    r15, [rsp+32]
	mov    [rsp+32], r15
	
	// [r9:r13, rax] <- t = Floor((aLbL + qL x mL) / 2^(B*w))
    MULADD64x320 [rsp], r8, r9, r10, r11, r12, r13, rax, r14, r15, rbx
	
	// [rsp10:rsp19] <- t + qL x mH
	MULADD320_SCHOOL [rsp], [rip+p610p1+40], [rsp+80], r9, r10, r11, r12, r13, rax, r14, r15

	// [rsp0:rsp9] <- t = t - aLbL
	mov    r14, [rsp+80]
	sub    r14, [rsp]
	mov    r15, [rsp+88]
	sbb    r15, [rsp+8]
	mov    [rsp], r14
	mov    [rsp+8], r15
	mov    r14, [rsp+96]
	sbb    r14, [rsp+16]
	mov    r15, [rsp+104]
	sbb    r15, [rsp+24]
	mov    [rsp+16], r14
	mov    [rsp+24], r15
	sbb    r13, [rsp+328]
	sbb    rax, [rsp+40]
	sbb    r9, [rsp+48]
	sbb    r10, [rsp+56]
	sbb    r11, [rsp+64]
	sbb    r12, [rsp+72]
	mov    [rsp+32], r13
	mov    [rsp+40], rax
	mov    [rsp+48], r9
	mov    [rsp+56], r10
	mov    [rsp+64], r11
	mov    [rsp+72], r12
	
	// (a00 + a01) x (b00 + b01)
    // [rsp10:rsp14] <- a00 + a01, rax <- mask
    xor    rax, rax
    mov    r8, [reg_p1]
    mov    r9, [reg_p1+8]
    mov    r10, [reg_p1+16]
    add    r8, [reg_p1+40]
    adc    r9, [reg_p1+48]
    adc    r10, [reg_p1+56]
    mov    r11, [reg_p1+24]
    mov    r12, [reg_p1+32]
    adc    r11, [reg_p1+64]
    adc    r12, [reg_p1+72]
    sbb    rax, 0
    mov    [rsp+80], r8
    mov    [rsp+88], r9
    mov    [rsp+96], r10
    mov    [rsp+104], r11
    mov    [rsp+112], r12

    // [rsp15:rsp19] <- b00 + b01, rbx <- mask
    xor    rbx, rbx
    mov    r8, [reg_p2]
    mov    r9, [reg_p2+8]
    mov    r10, [reg_p2+16]
    add    r8, [reg_p2+40]
    adc    r9, [reg_p2+48]
    adc    r10, [reg_p2+56]
    mov    r11, [reg_p2+24]
    mov    r12, [reg_p2+32]
    adc    r11, [reg_p2+64]
    adc    r12, [reg_p2+72]
    sbb    rbx, 0
    mov    [rsp+120], r8
    mov    [rsp+128], r9
    mov    [rsp+136], r10
    mov    [rsp+144], r11
    mov    [rsp+152], r12

    // [rsp18:rsp23] <- t + (a00 + a01) x (b00 + b01)
	mov    r8, [rsp]
	mov    r9, [rsp+8]
	mov    r10, [rsp+16]
	mov    r11, [rsp+24]
	mov    r12, [rsp+32]
	mov    r13, [rsp+40]
    MULADD320_SCHOOLb  [rsp+80], [rsp+120], [rsp+80], [rsp], r8, r9, r10, r11, r12, r13, rbp, r14, r15, rbx /////// rbx is needed somewhere else  ///// [rsp+80] is ok for output?
	
	// (a00 + a01) x (b00 + b01)
    // [rsp10:rsp14] <- a10 + a11, rax <- mask
    xor    rax, rax
    mov    r8, [reg_p1+80]
    mov    r9, [reg_p1+88]
    mov    r10, [reg_p1+96]
    add    r8, [reg_p1+120]
    adc    r9, [reg_p1+128]
    adc    r10, [reg_p1+136]
    mov    r11, [reg_p1+104]
    mov    r12, [reg_p1+112]
    adc    r11, [reg_p1+144]
    adc    r12, [reg_p1+152]
    sbb    rax, 0
    mov    [rsp+80], r8
    mov    [rsp+88], r9
    mov    [rsp+96], r10
    mov    [rsp+104], r11
    mov    [rsp+112], r12

    // [rsp15:rsp19] <- b10 + b11, rbx <- mask
    xor    rbx, rbx
    mov    r8, [reg_p2+80]
    mov    r9, [reg_p2+88]
    mov    r10, [reg_p2+96]
    add    r8, [reg_p2+120]
    adc    r9, [reg_p2+128]
    adc    r10, [reg_p2+136]
    mov    r11, [reg_p2+104]
    mov    r12, [reg_p2+112]
    adc    r11, [reg_p2+144]
    adc    r12, [reg_p2+152]
    sbb    rbx, 0
    mov    [rsp+120], r8
    mov    [rsp+128], r9
    mov    [rsp+136], r10
    mov    [rsp+144], r11
    mov    [rsp+152], r12

    // [rsp18:rsp23] <- t + (a10 + a11) x (b10 + b11)
	mov    r8, [rsp]
	mov    r9, [rsp+8]
	mov    r10, [rsp+16]
	mov    r11, [rsp+24]
	mov    r12, [rsp+32]
	mov    r13, [rsp+40]
    MULADD320_SCHOOLb  [rsp+80], [rsp+120], [rsp+80], [rsp], r8, r9, r10, r11, r12, r13, rbp, r14, r15, rbx /////// rbx is needed somewhere else  ///// [rsp+80] is ok for output?
    
    // [rsp0:rsp9] <- a01 x b01
	MUL320_SCHOOL [reg_p1+40], [reg_p2+40], [rsp], r8, r9, r10, r11, r12, r13, r14, r15 
    // [rsp10:rsp19] <- a11 x b11
	MUL320_SCHOOL [reg_p1+120], [reg_p2+80], [rsp+120], r8, r9, r10, r11, r12, r13, r14, r15 
	// [rsp0:rsp9], [rsp40] <- a01 x b01 + a11 x b11 (aHbH)                                      ///////// CHECK rsp40
	xor    rax, rax
    mov    r8, [rsp] 
    mov    r9, [rsp+8]
	add    r8, [rsp+48]
	adc    r9, [rsp+56]
	mov    [rsp], r8
	mov    [rsp+8], r9 
    mov    r8, [rsp+16] 
    mov    r9, [rsp+24]
	adc    r8, [rsp+64]
	adc    r9, [rsp+72]
	mov    [rsp+16], r8
	mov    [rsp+24], r9
    mov    r8, [rsp+32] 
    mov    r9, [rsp+40]
	adc    r8, [rsp+80]
	adc    r9, [rsp+88]
	mov    [rsp+328], r8    // 5th term of aLbL in [rsp41]
	mov    [rsp+40], r9
    mov    r10, [rsp+48] 
    mov    r11, [rsp+56]
	adc    r10, [rsp+96]
	adc    r11, [rsp+104]
	mov    [rsp+48], r10
	mov    [rsp+56], r11
    mov    r12, [rsp+64] 
    mov    r13, [rsp+72]
	adc    r12, [rsp+112]
	adc    r13, [rsp+120]
	mov    [rsp+64], r12
	mov    [rsp+72], r13
	adc    rax, 0
	mov    [rsp+320], rax
	



         
	mov    [rcx], r11
	mov    [rcx+8], r12
	mov    [rcx+16], r13
	mov    [rcx+24], r8
	mov    [rcx+32], r9
	mov    [rcx+40], r10	
	mov    [rcx+48], r10	
	mov    [rcx+56], r10	
	mov    [rcx+64], r10	
	mov    [rcx+72], r10	
	add    rsp, 336
    pop    rbp
    pop    rbx
    pop    r15 
    pop    r14
    pop    r13
    pop    r12
    ret
*/

/*    
///////////////////////////////////////////////////////////////// MACRO
// Schoolbook integer multiplication
// Inputs:  memory pointers M0 and M1
// Outputs: memory pointer C
// Temps:   regs T0:T6
/////////////////////////////////////////////////////////////////
.macro MUL192_SCHOOL M0, M1, C, T0, T1, T2, T3, T4, T5, T6
    mov    rdx, \M0
    mulx   \T0, \T1, \M1     // T0:T1 = A0*B0
    mov    \C, \T1           // C0_final
    mulx   \T1, \T2, 8\M1    // T1:T2 = A0*B1
    xor    rax, rax   
    adox   \T0, \T2        
    mulx   \T2, \T3, 16\M1   // T2:T3 = A0*B2
    adox   \T1, \T3
           
    mov    rdx, 8\M0
    mulx   \T3, \T4, \M1     // T3:T4 = A1*B0
    adox   \T2, rax 
    xor    rax, rax   
    mulx   \T5, \T6, 8\M1    // T5:T6 = A1*B1
    adox   \T4, \T0
    mov    8\C, \T4          // C1_final  
    adcx   \T3, \T6      
    mulx   \T6, \T0, 16\M1   // T6:T0 = A1*B2 
    adox   \T3, \T1  
    adcx   \T5, \T0     
    adcx   \T6, rax 
    adox   \T5, \T2	
    
    mov    rdx, 16\M0
    mulx   \T1, \T0, \M1     // T1:T0 = A2*B0
    adox   \T6, rax
    xor    rax, rax 
    mulx   \T4, \T2, 8\M1    // T4:T2 = A2*B1
    adox   \T0, \T3   
    mov    16\C, \T0         // C2_final 
    adcx   \T1, \T5    
    mulx   \T0, \T3, 16\M1   // T0:T3 = A2*B2
    adcx   \T4, \T6  
    adcx   \T0, rax
    adox   \T1, \T2
    adox   \T3, \T4  
    mov    24\C, \T1         // C3_final 
    mov    32\C, \T1         // C4_final 
    adox   rax, \T0
    mov    40\C, rax         // C5_final 
.endm 


///////////////////////////////////////////////////////////////// MACRO
// Schoolbook integer multiplication
// Inputs:  memory pointers M0 and M1
// Outputs: memory pointer C and regs T1, T2, T0
// Temps:   regs T0:T6
/////////////////////////////////////////////////////////////////
.macro MUL192_SCHOOLb M0, M1, C, T0, T1, T2, T3, T4, T5, T6
    mov    rdx, \M0
    mulx   \T0, \T1, \M1     // T0:T1 = A0*B0
    mov    \C, \T1           // C0_final
    mulx   \T1, \T2, 8\M1    // T1:T2 = A0*B1
    xor    rax, rax   
    adox   \T0, \T2        
    mulx   \T2, \T3, 16\M1   // T2:T3 = A0*B2
    adox   \T1, \T3
           
    mov    rdx, 8\M0
    mulx   \T3, \T4, \M1     // T3:T4 = A1*B0
    adox   \T2, rax 
    xor    rax, rax   
    mulx   \T5, \T6, 8\M1    // T5:T6 = A1*B1
    adox   \T4, \T0
    mov    8\C, \T4          // C1_final  
    adcx   \T3, \T6      
    mulx   \T6, \T0, 16\M1   // T6:T0 = A1*B2 
    adox   \T3, \T1  
    adcx   \T5, \T0     
    adcx   \T6, rax 
    adox   \T5, \T2	
    
    mov    rdx, 16\M0
    mulx   \T1, \T0, \M1     // T1:T0 = A2*B0
    adox   \T6, rax
    xor    rax, rax 
    mulx   \T2, \T4, 8\M1    // T2:T4 = A2*B1
    adox   \T0, \T3   
    mov    16\C, \T0         // C2_final 
    adcx   \T1, \T5    
    mulx   \T0, \T3, 16\M1   // T0:T3 = A2*B2
    adcx   \T2, \T6  
    adcx   \T0, rax
    adox   \T1, \T4
    adox   \T2, \T3
    adox   \T0, rax
.endm


// 3-term Karatsuba (UNFINISHED)

.global fp2mul610_c1_asm
fp2mul610_c1_asm:   
    push   r12     
    push   r13     
    push   r14 
    push   r15      
    push   rbx  
    push   rbp
	sub    rsp, 336
    mov    rcx, reg_p3
    
    // [rsp0:rsp5] <- a00 x b00
	MUL192_SCHOOL [reg_p1], [reg_p2], [rsp], r8, r9, r10, r11, r12, r13, r14 
    // [rsp6:rsp11] <- a10 x b10
	MUL192_SCHOOL [reg_p1+80], [reg_p2+80], [rsp+48], r8, r9, r10, r11, r12, r13, r14 
	// [rsp0:rsp5], [rsp40] <- a00 x b00 + a10 x b10 (aLbL), t <- [rsp3:rsp5], [rsp40]      ///////// CHECK rsp40
	xor    rax, rax
    mov    r8, [rsp] 
    mov    r9, [rsp+8]
	add    r8, [rsp+48]
	adc    r9, [rsp+56]
	mov    [rsp], r8
	mov    [rsp+8], r9 
    mov    r8, [rsp+16] 
    mov    r9, [rsp+24]
	adc    r8, [rsp+64]
	adc    r9, [rsp+72]
	mov    [rsp+16], r8
	mov    [rsp+24], r9
    mov    r8, [rsp+32] 
    mov    r9, [rsp+40]
	adc    r8, [rsp+80]
	adc    r9, [rsp+88]
	mov    [rsp+32], r8
	mov    [rsp+40], r9
	adc    rax, 0
	mov    [rsp+320], rax
	
    // [rsp12:rsp17] <- a01 x b01
	MUL192_SCHOOL [reg_p1+24], [reg_p2+24], [rsp+48], r8, r9, r10, r11, r12, r13, r14 
    // [rsp18:rsp23] <- a11 x b11
	MUL192_SCHOOL [reg_p1+104], [reg_p2+104], [rsp+96], r8, r9, r10, r11, r12, r13, r14
	// [rsp6:rsp11], [rsp41] <- a01 x b01 + a11 x b11 (aMbM)                    ///////// CHECK rsp41
	xor    rax, rax
    mov    r8, [rsp+48] 
    mov    r9, [rsp+56]
	add    r8, [rsp+96]
	adc    r9, [rsp+104]
	mov    [rsp+48], r8
	mov    [rsp+56], r9 
    mov    r8, [rsp+64] 
    mov    r9, [rsp+72]
	adc    r8, [rsp+112]
	adc    r9, [rsp+120]
	mov    [rsp+64], r8
	mov    [rsp+72], r9
    mov    r8, [rsp+80] 
    mov    r9, [rsp+88]
	adc    r8, [rsp+128]
	adc    r9, [rsp+136]
	mov    [rsp+80], r8
	mov    [rsp+88], r9
	adc    rax, 0
	mov    [rsp+328], rax
	
	// (a00 + a01) x (b00 + b01)
    // r8-r10 <- a00 + a01, rax <- mask
    xor    rax, rax
    mov    r8, [reg_p1]
    mov    r9, [reg_p1+8]
    mov    r10, [reg_p1+16]
    add    r8, [reg_p1+24]
    adc    r9, [reg_p1+32]
    adc    r10, [reg_p1+40]
    sbb    rax, 0

    // r11-r13 <- b00 + b01, rbx <- mask
    xor    rbx, rbx
    mov    r11, [reg_p2]
    mov    r12, [reg_p2+8]
    mov    r13, [reg_p2+16]
    add    r11, [reg_p2+24]
    adc    r12, [reg_p2+32]
    adc    r13, [reg_p2+40]
    sbb    rbx, 0
    mov    [rsp+96], r8
    mov    [rsp+104], r9
    mov    [rsp+112], r10
    mov    [rsp+120], r11
    mov    [rsp+128], r12
    mov    [rsp+136], r13
    
    // r11-r13 <- masked (b00 + b01)
    and    r11, rax
    and    r12, rax
    and    r13, rax

    // r8-r10 <- masked (a00 + a01)
    and    r8, rbx
    and    r9, rbx
    and    r10, rbx

    // r8-r10, rax <- masked (a00 + a01) + masked (b00 + b01)
	xor    rax, rax
    add    r8, r11
    adc    r9, r12
    adc    r10, r13
	adc    rax, 0

    // [rsp18:rsp23] <- (a00 + a01) x (b00 + b01), low part 
    MUL192_SCHOOLb  [rsp+96], [rsp+120], [rsp+144], r15, rbx, rbp, r11, r12, r13, r14 
    //mov    [rsp+168], rbx         
    //mov    [rsp+176], rbp         
    //mov    [rsp+184], r15 
    
    // r8-r10, rax <- (a00 + a01) x (b00 + b01), final step
    add    r8, rbx
    adc    r9, rbp
    adc    r10, r15
	adc    rax, 0 
    
    // r11-r13, r8-r10, rax <- (a00 + a01) x (b00 + b01) - aLxbL
    mov    r11, [rsp+144]
    mov    r12, [rsp+152]
    mov    r13, [rsp+160]
    sub    r11, [rsp]
    sbb    r12, [rsp+8]
    sbb    r13, [rsp+16]
    sbb    r8, [rsp+24]
    sbb    r9, [rsp+32]
    sbb    r10, [rsp+40]
	sbb    rax, [rsp+320]
    
    // [rsp18:rsp23] <- r11-r13, r8-r10, rax <- (a00 + a01) x (b00 + b01) - aLxbL - aMxbM
    sub    r11, [rsp+48]
    sbb    r12, [rsp+56]
    sbb    r13, [rsp+64]
    sbb    r8, [rsp+72]
    sbb    r9, [rsp+80]
    sbb    r10, [rsp+88]
	sbb    rax, [rsp+328]
	mov    [rsp+144], r11
	mov    [rsp+152], r12
	mov    [rsp+160], r13
	mov    [rsp+168], r8
	mov    [rsp+176], r9
	mov    [rsp+184], r10		
	
	// (a10 + a11) x (b10 + b11)
    // r8-r10 <- a10 + a11, rax <- mask
    xor    rax, rax
    mov    r8, [reg_p1+80]
    mov    r9, [reg_p1+88]
    mov    r10, [reg_p1+96]
    add    r8, [reg_p1+104]
    adc    r9, [reg_p1+112]
    adc    r10, [reg_p1+120]
    sbb    rax, 0

    // r11-r13 <- b10 + b11, rbx <- mask
    xor    rbx, rbx
    mov    r11, [reg_p2+80]
    mov    r12, [reg_p2+88]
    mov    r13, [reg_p2+96]
    add    r11, [reg_p2+104]
    adc    r12, [reg_p2+112]
    adc    r13, [reg_p2+120]
    sbb    rbx, 0
    mov    [rsp+96], r8
    mov    [rsp+104], r9
    mov    [rsp+112], r10
    mov    [rsp+120], r11
    mov    [rsp+128], r12
    mov    [rsp+136], r13
    
    // r11-r13 <- masked (b10 + b11)
    and    r11, rax
    and    r12, rax
    and    r13, rax

    // r8-r10 <- masked (a10 + a11)
    and    r8, rbx
    and    r9, rbx
    and    r10, rbx

    // r8-r10, rax <- masked (a10 + a11) + masked (b10 + b11)
	xor    rax, rax
    add    r8, r11
    adc    r9, r12
    adc    r10, r13
	adc    rax, 0

    // [rsp24:rsp29] <- (a10 + a11) x (b10 + b11), low part 
    MUL192_SCHOOLb  [rsp+96], [rsp+120], [rsp+192], r15, rbx, rbp, r11, r12, r13, r14 
    //mov    [rsp+216], rbx         
    //mov    [rsp+224], rbp         
    //mov    [rsp+232], r15 
    
    // r8-r10, rax <- (a10 + a11) x (b10 + b11), final step
    add    r8, rbx
    adc    r9, rbp
    adc    r10, r15
	adc    rax, 0  
    
    // [rsp12:rsp17] <- r11-r13, r8-r10, rax <- (a00 + a01) x (b00 + b01) + (a10 + a11) x (b10 + b11) - aLxbL - aMxbM
    mov    r11, [rsp+192]
    mov    r12, [rsp+200]
    mov    r13, [rsp+208]
    add    r11, [rsp+144]
    adc    r12, [rsp+152]
    adc    r13, [rsp+160]
    adc    r8, [rsp+168]
    adc    r9, [rsp+176]
    adc    r10, [rsp+184]
	adc    rax, 0
	mov    [rsp+96], r11
	mov    [rsp+104], r12
	mov    [rsp+112], r13
	mov    [rsp+120], r8
	mov    [rsp+128], r9
	mov    [rsp+136], r10		



         
	mov    [rcx], r11
	mov    [rcx+8], r12
	mov    [rcx+16], r13
	mov    [rcx+24], r8
	mov    [rcx+32], r9
	mov    [rcx+40], r10	
	mov    [rcx+48], r10	
	mov    [rcx+56], r10	
	mov    [rcx+64], r10	
	mov    [rcx+72], r10	
	add    rsp, 336
    pop    rbp
    pop    rbx
    pop    r15 
    pop    r14
    pop    r13
    pop    r12
    ret
*/

///////////////////////////////////////////////////////////////// MACRO
// z = z - a x bi
// Inputs: base memory pointer M1 (a),
//         bi pre-stored in rdx,
//         accumulator z in [M, Z1:Z10]
// Output: [M, Z1:Z10]
// Temps:  regs T0:T1
/////////////////////////////////////////////////////////////////
.macro MULSUB64x640 M1, Z0, M, Z3, Z4, Z5, Z6, Z7, Z8, Z9, Z10, T0, T1
    mulx   \T0, \T1, \M1     // A0*B0
    sub    \Z0, \T1
	mov    \T1, \M
    sbb    \T1, \T0
	mov    24\M, \Z0
	mov    \M, \T1
    mulx   \T0, \T1, 16\M1   // A0*B2 
	mov    \Z0, 8\M
    sbb    \Z0, \T1
    sbb    \Z3, \T0 
	mov    8\M, \Z0 
    mulx   \T0, \T1, 32\M1   // A0*B4 
    sbb    \Z4, \T1
    sbb    \Z5, \T0   
    mulx   \T0, \T1, 48\M1   // A0*B6 
	mov    \Z0, \M      
    sbb    \Z6, \T1
    sbb    \Z7, \T0    
    mulx   \T0, \T1, 64\M1   // A0*B8     
    sbb    \Z8, \T1
    sbb    \Z9, \T0 
    sbb    \Z10, 0  

    mulx   \T0, \T1, 8\M1    // A0*B1
    sub    \Z0, \T1
	mov    \T1, 8\M
    sbb    \T1, \T0  
	mov    8\M, \T1
    mulx   \T0, \T1, 24\M1   // A0*B3 
    sbb    \Z3, \T1
    sbb    \Z4, \T0 
    mulx   \T0, \T1, 40\M1   // A0*B5
	mov    16\M, \Z3
    sbb    \Z5, \T1
    sbb    \Z6, \T0   
    mulx   \T0, \T1, 56\M1   // A0*B7 
    sbb    \Z7, \T1
    sbb    \Z8, \T0   
    mulx   \T0, \T1, 72\M1   // A0*B8
	mov    rdx, 24\M
    sbb    \Z9, \T1
    sbb    \Z10, \T0
.endm


//***********************************************************************
//  Multiplication in GF(p^2), non-complex part
//  Operation: c [reg_p3] = a0 x b0 - a1 x b1
//  Inputs: a = [a1, a0] stored in [reg_p1] 
//          b = [b1, b0] stored in [reg_p2] 
//  Output: c stored in [reg_p3]
//***********************************************************************
.global fp2mul610_c0_asm
fp2mul610_c0_asm:   
    push   r12  
    push   r13   
    push   r14  
    push   r15     
    push   rbx   
    push   rbp     
    mov    rcx, reg_p3
	sub    rsp, 112   
    
    // [rax, rsp0:rsp8, r11:r15, r8:r10] <- z = a0 x b00 - a1 x b10
    mov    rdx, [reg_p2]
    mulx   r9, rax, [reg_p1]
    xor    r10, r10
    mulx   r10, r11, [reg_p1+8]
    adcx   r9, r11     
	mov    [rsp], r9   
    mulx   r11, r12, [reg_p1+16] 
    adcx   r10, r12     
	mov    [rsp+8], r10      
    mulx   r12, r13, [reg_p1+24] 
    adcx   r11, r13       
    mulx   r13, r14, [reg_p1+32] 
    adcx   r12, r14      
    mulx   r14, r15, [reg_p1+40]
    adcx   r13, r15      
    mulx   r15, rbp, [reg_p1+48]
    adcx   r14, rbp     
    mulx   r8, rbx, [reg_p1+56] 
    adcx   r15, rbx     
    mulx   r9, rbp, [reg_p1+64] 
    adcx   r8, rbp    
    mulx   r10, rbx, [reg_p1+72] 
    mov    rdx, [reg_p2+80]
    adcx   r9, rbx    
    adc    r10, 0 
                
    MULSUB64x640 [reg_p1+80], rax, [rsp], r11, r12, r13, r14, r15, r8, r9, r10, rbx, rbp       
    // [r12:r15, r8:r10] <- z = (z0 x p610p1 + z)/2^64  
    xor    r11, r11
    MULADD64x384b [rip+p610p1+32], r12, r13, r14, r15, r8, r9, r10, rbx, rbp 
    mov    rdx, [reg_p2+8]
	bt     r10, 63
    sbb    r11, 0
    
    // [rax, rsp8:rsp16, r12:r15, r8:r11] <- z = a0 x b01 - a1 x b11 + z
    MULADD64x640c [reg_p1], rax, [rsp+8], r12, r13, r14, r15, r8, r9, r10, r11, rbx, rbp
    mov    rdx, [reg_p2+88]    
    MULSUB64x640 [reg_p1+80], rax, [rsp+8], r12, r13, r14, r15, r8, r9, r10, r11, rbx, rbp
    // [r13:r15, r8:r11] <- z = (z0 x p610p1 + z)/2^64
    xor    r12, r12 
    MULADD64x384b [rip+p610p1+32], r13, r14, r15, r8, r9, r10, r11, rbx, rbp 
    mov    rdx, [reg_p2+16]
	bt     r11, 63
    sbb    r12, 0
    
    // [rax, rsp16:rsp24, r13:r15, r8:r12] <- z = a0 x b02 - a1 x b12 + z 
    MULADD64x640c [reg_p1], rax, [rsp+16], r13, r14, r15, r8, r9, r10, r11, r12, rbx, rbp
    mov    rdx, [reg_p2+96]    
    MULSUB64x640 [reg_p1+80], rax, [rsp+16], r13, r14, r15, r8, r9, r10, r11, r12, rbx, rbp
    // [r14:r15, r8:r12] <- z = (z0 x p610p1 + z)/2^64
    xor    r13, r13 
    MULADD64x384b [rip+p610p1+32], r14, r15, r8, r9, r10, r11, r12, rbx, rbp
    mov    rdx, [reg_p2+24]
	bt     r12, 63
    sbb    r13, 0
    
    // [rax, rsp24:rsp32, r14:r15, r8:r13] <- z = a0 x b03 - a1 x b13 + z 
    MULADD64x640c [reg_p1], rax, [rsp+24], r14, r15, r8, r9, r10, r11, r12, r13, rbx, rbp
    mov    rdx, [reg_p2+104]    
    MULSUB64x640 [reg_p1+80], rax, [rsp+24], r14, r15, r8, r9, r10, r11, r12, r13, rbx, rbp
    // [r15, r8:r13] <- z = (z0 x p610p1 + z)/2^64
    xor    r14, r14
    MULADD64x384b [rip+p610p1+32], r15, r8, r9, r10, r11, r12, r13, rbx, rbp
    mov    rdx, [reg_p2+32]
	bt     r13, 63
    sbb    r14, 0
    
    // [rax, rsp32:rsp40, r15, r8:r14] <- z = a0 x b04 - a1 x b14 + z 
    MULADD64x640c [reg_p1], rax, [rsp+32], r15, r8, r9, r10, r11, r12, r13, r14, rbx, rbp
    mov    rdx, [reg_p2+112]    
    MULSUB64x640 [reg_p1+80], rax, [rsp+32], r15, r8, r9, r10, r11, r12, r13, r14, rbx, rbp
    // [r8:r14] <- z = (z0 x p610p1 + z)/2^64     
    xor    r15, r15 
    MULADD64x384b [rip+p610p1+32], r8, r9, r10, r11, r12, r13, r14, rbx, rbp
    mov    rdx, [reg_p2+40]
	bt     r14, 63
    sbb    r15, 0
    
    // [rax, rsp40:rsp48, r8:r15] <- z = a0 x b05 - a1 x b15 + z
    MULADD64x640c [reg_p1], rax, [rsp+40], r8, r9, r10, r11, r12, r13, r14, r15, rbx, rbp
    mov    rdx, [reg_p2+120]    
    MULSUB64x640 [reg_p1+80], rax, [rsp+40], r8, r9, r10, r11, r12, r13, r14, r15, rbx, rbp
    // [r9:r15] <- z = (z0 x p610p1 + z)/2^64
    xor    r8, r8 
    MULADD64x384b [rip+p610p1+32], r9, r10, r11, r12, r13, r14, r15, rbx, rbp
    mov    rdx, [reg_p2+48]
	bt     r15, 63
    sbb    r8, 0
    
    // [rax, rsp48:rsp56, r9:r15, r8] <- z = a0 x b06 - a1 x b16 + z
    MULADD64x640c [reg_p1], rax, [rsp+48], r9, r10, r11, r12, r13, r14, r15, r8, rbx, rbp
    mov    rdx, [reg_p2+128]    
    MULSUB64x640 [reg_p1+80], rax, [rsp+48], r9, r10, r11, r12, r13, r14, r15, r8, rbx, rbp
    // [r15, r8:r14] <- z = (z0 x p610p1 + z)/2^64    
    xor    r9, r9 
    MULADD64x384b [rip+p610p1+32], r10, r11, r12, r13, r14, r15, r8, rbx, rbp
    mov    rdx, [reg_p2+56]
	bt     r8, 63
    sbb    r9, 0
    
    // [rax, rsp56:rsp64, r10:r15, r8:r9] <- z = a0 x b07 - a1 x b17 + z
    MULADD64x640c [reg_p1], rax, [rsp+56], r10, r11, r12, r13, r14, r15, r8, r9, rbx, rbp
    mov    rdx, [reg_p2+136]    
    MULSUB64x640 [reg_p1+80], rax, [rsp+56], r10, r11, r12, r13, r14, r15, r8, r9, rbx, rbp
    // [r11:r15, r8:r9] <- z = (z0 x p610p1 + z)/2^64
	xor    r10, r10
    MULADD64x384b [rip+p610p1+32], r11, r12, r13, r14, r15, r8, r9, rbx, rbp
    mov    rdx, [reg_p2+64]
	bt     r9, 63
    sbb    r10, 0
    
    // [rax, rsp64:rsp72, r11:r15, r8:r10] <- z = a0 x b08 - a1 x b18 + z
    MULADD64x640c [reg_p1], rax, [rsp+64], r11, r12, r13, r14, r15, r8, r9, r10, rbx, rbp
    mov    rdx, [reg_p2+144]    
    MULSUB64x640 [reg_p1+80], rax, [rsp+64], r11, r12, r13, r14, r15, r8, r9, r10, rbx, rbp
    // [r12:r15, r8:r10] <- z = (z0 x p610p1 + z)/2^64
	xor    r11, r11
    MULADD64x384b [rip+p610p1+32], r12, r13, r14, r15, r8, r9, r10, rbx, rbp
    mov    rdx, [reg_p2+72]
	bt     r10, 63
    sbb    r11, 0
    
    // [rax, rsp72:rsp80, r12:r15, r8:r11] <- z = a0 x b09 - a1 x b19 + z
    MULADD64x640c [reg_p1], rax, [rsp+72], r12, r13, r14, r15, r8, r9, r10, r11, rbx, rbp
    mov    rdx, [reg_p2+152]    
    MULSUB64x640 [reg_p1+80], rax, [rsp+72], r12, r13, r14, r15, r8, r9, r10, r11, rbx, rbp
    // [r12:r15, r8:r10] <- z = (z0 x p610p1 + z)/2^64
	xor    r12, r12
    MULADD64x384b [rip+p610p1+32], r13, r14, r15, r8, r9, r10, r11, rbx, rbp
	bt     r11, 63
    sbb    r12, 0

    // Final correction if result < 0
    mov    rbx, [rip+fmt(p610)]  
    mov    rbp, [rip+fmt(p610)+32]  
    mov    rdx, [rip+fmt(p610)+40]
    and    rbx, r12
    and    rbp, r12
    and    rdx, r12

	mov    rdi, [rsp+80]
	mov    rsi, [rsp+88]
	add    rsp, 112   
    add    rax, rbx
    adc    rdi, rbx
    adc    rsi, rbx
    mov    [rcx], rax 
    mov    [rcx+8], rdi 
    adc    r13, rbx
	adc    r14, rbp
	adc    r15, rdx
    mov    [rcx+16], rsi        
    mov    [rcx+24], r13     
    mov    [rcx+32], r14   
    mov    [rcx+40], r15 
	setc   al
	
    mov    r13, [rip+fmt(p610)+48]
    mov    rsi, [rip+fmt(p610)+56]
	mov    rdi, [rip+fmt(p610)+64] 
	mov    rdx, [rip+fmt(p610)+72] 
	and    r13, r12 
	and    rsi, r12 
	and    rdi, r12 
	and    rdx, r12
	bt     rax, 0
    adc    r8, r13
    adc    r9, rsi
    adc    r10, rdi
	adc    r11, rdx
                         
    mov    [rcx+48], r8 
    mov    [rcx+56], r9 
    mov    [rcx+64], r10     
    mov    [rcx+72], r11
    pop    rbp
    pop    rbx
    pop    r15
    pop    r14
    pop    r13
    pop    r12
    ret

/*
///////////////////////////////////////////////////////////////// MACRO
// z = z - a x bi
// Inputs: base memory pointer M1 (a),
//         bi pre-stored in rdx,
//         accumulator z in [M, Z1:Z10]
// Output: [M, Z1:Z10]
// Temps:  regs T0:T1
/////////////////////////////////////////////////////////////////
.macro MULSUB64x640 M1, M, Z3, Z4, Z5, Z6, Z7, Z8, Z9, Z10, T0, T1, T2
	mov    \T2, \M
    mulx   \T0, \T1, \M1     // A0*B0
    sub    \T2, \T1
	mov    \T1, 8\M
    sbb    \T1, \T0
	mov    32\M, \T2
	mov    8\M, \T1
    mulx   \T0, \T1, 16\M1   // A0*B2 
	mov    \T2, 16\M
    sbb    \T2, \T1
    sbb    \Z3, \T0 
    mulx   \T0, \T1, 32\M1   // A0*B4 
	mov    16\M, \T2 
    sbb    \Z4, \T1
    sbb    \Z5, \T0   
    mulx   \T0, \T1, 48\M1   // A0*B6 
	mov    \T2, 8\M      
    sbb    \Z6, \T1
    sbb    \Z7, \T0    
    mulx   \T0, \T1, 64\M1   // A0*B8     
    sbb    \Z8, \T1
    sbb    \Z9, \T0 
    sbb    \Z10, 0  

    mulx   \T0, \T1, 8\M1    // A0*B1
    sub    \T2, \T1
	mov    \T1, 16\M
    sbb    \T1, \T0  
	mov    16\M, \T1
    mulx   \T0, \T1, 24\M1   // A0*B3 
	mov    8\M, \T2
    sbb    \Z3, \T1
    sbb    \Z4, \T0 
    mulx   \T0, \T1, 40\M1   // A0*B5
	mov    24\M, \Z3
    sbb    \Z5, \T1
    sbb    \Z6, \T0   
    mulx   \T0, \T1, 56\M1   // A0*B7 
    sbb    \Z7, \T1
    sbb    \Z8, \T0   
    mulx   \T0, \T1, 72\M1   // A0*B8
	mov    rdx, 32\M
    sbb    \Z9, \T1
    sbb    \Z10, \T0
.endm


.global fp2mul610_c0_asm
fp2mul610_c0_asm:   
    push   r12  
    push   r13   
    push   r14  
    push   r15     
    push   rbx   
    push   rbp     
    mov    rcx, reg_p3
	sub    rsp, 112   
    
    // [rax, rsp0:rsp8, r11:r15, r8:r10] <- z = a0 x b00 - a1 x b10
    mov    rdx, [reg_p2]
    mulx   r9, rax, [reg_p1]
    xor    r10, r10
	mov    [rsp], rax
    mulx   r10, r11, [reg_p1+8]
    adcx   r9, r11     
	mov    [rsp+8], r9   
    mulx   r11, r12, [reg_p1+16] 
    adcx   r10, r12     
	mov    [rsp+16], r10      
    mulx   r12, r13, [reg_p1+24] 
    adcx   r11, r13       
    mulx   r13, r14, [reg_p1+32] 
    adcx   r12, r14      
    mulx   r14, r15, [reg_p1+40]
    adcx   r13, r15      
    mulx   r15, rbp, [reg_p1+48]
    adcx   r14, rbp     
    mulx   r8, rbx, [reg_p1+56] 
    adcx   r15, rbx     
    mulx   r9, rbp, [reg_p1+64] 
    adcx   r8, rbp    
    mulx   r10, rbx, [reg_p1+72] 
    mov    rdx, [reg_p2+80]
    adcx   r9, rbx    
    adc    r10, 0 
                
    MULSUB64x640 [reg_p1+80], [rsp], r11, r12, r13, r14, r15, r8, r9, r10, rbx, rbp, rax       
    // [r12:r15, r8:r10] <- z = (z0 x p610p1 + z)/2^64  
    xor    r11, r11
    MULADD64x384b [rip+p610p1+32], r12, r13, r14, r15, r8, r9, r10, rbx, rbp 
    mov    rdx, [reg_p2+8]
	bt     r10, 63
    sbb    r11, 0
    
    // [rax, rsp8:rsp16, r12:r15, r8:r11] <- z = a0 x b01 - a1 x b11 + z
    MULADD64x640 [reg_p1], [rsp+8], r12, r13, r14, r15, r8, r9, r10, r11, rbx, rbp, rax, rax
    mov    rdx, [reg_p2+88]    
    MULSUB64x640 [reg_p1+80], [rsp+8], r12, r13, r14, r15, r8, r9, r10, r11, rbx, rbp, rax
    // [r13:r15, r8:r11] <- z = (z0 x p610p1 + z)/2^64
    xor    r12, r12 
    MULADD64x384b [rip+p610p1+32], r13, r14, r15, r8, r9, r10, r11, rbx, rbp 
    mov    rdx, [reg_p2+16]
	bt     r11, 63
    sbb    r12, 0
    
    // [rax, rsp16:rsp24, r13:r15, r8:r12] <- z = a0 x b02 - a1 x b12 + z 
    MULADD64x640 [reg_p1], [rsp+16], r13, r14, r15, r8, r9, r10, r11, r12, rbx, rbp, rax, rax
    mov    rdx, [reg_p2+96]    
    MULSUB64x640 [reg_p1+80], [rsp+16], r13, r14, r15, r8, r9, r10, r11, r12, rbx, rbp, rax
    // [r14:r15, r8:r12] <- z = (z0 x p610p1 + z)/2^64
    xor    r13, r13 
    MULADD64x384b [rip+p610p1+32], r14, r15, r8, r9, r10, r11, r12, rbx, rbp
    mov    rdx, [reg_p2+24]
	bt     r12, 63
    sbb    r13, 0
    
    // [rax, rsp24:rsp32, r14:r15, r8:r13] <- z = a0 x b03 - a1 x b13 + z 
    MULADD64x640 [reg_p1], [rsp+24], r14, r15, r8, r9, r10, r11, r12, r13, rbx, rbp, rax, rax
    mov    rdx, [reg_p2+104]    
    MULSUB64x640 [reg_p1+80], [rsp+24], r14, r15, r8, r9, r10, r11, r12, r13, rbx, rbp, rax
    // [r15, r8:r13] <- z = (z0 x p610p1 + z)/2^64
    xor    r14, r14
    MULADD64x384b [rip+p610p1+32], r15, r8, r9, r10, r11, r12, r13, rbx, rbp
    mov    rdx, [reg_p2+32]
	bt     r13, 63
    sbb    r14, 0
    
    // [rax, rsp32:rsp40, r15, r8:r14] <- z = a0 x b04 - a1 x b14 + z 
    MULADD64x640 [reg_p1], [rsp+32], r15, r8, r9, r10, r11, r12, r13, r14, rbx, rbp, rax, rax
    mov    rdx, [reg_p2+112]    
    MULSUB64x640 [reg_p1+80], [rsp+32], r15, r8, r9, r10, r11, r12, r13, r14, rbx, rbp, rax
    // [r8:r14] <- z = (z0 x p610p1 + z)/2^64     
    xor    r15, r15 
    MULADD64x384b [rip+p610p1+32], r8, r9, r10, r11, r12, r13, r14, rbx, rbp
    mov    rdx, [reg_p2+40]
	bt     r14, 63
    sbb    r15, 0
    
    // [rax, rsp40:rsp48, r8:r15] <- z = a0 x b05 - a1 x b15 + z
    MULADD64x640 [reg_p1], [rsp+40], r8, r9, r10, r11, r12, r13, r14, r15, rbx, rbp, rax, rax
    mov    rdx, [reg_p2+120]    
    MULSUB64x640 [reg_p1+80], [rsp+40], r8, r9, r10, r11, r12, r13, r14, r15, rbx, rbp, rax
    // [r9:r15] <- z = (z0 x p610p1 + z)/2^64
    xor    r8, r8 
    MULADD64x384b [rip+p610p1+32], r9, r10, r11, r12, r13, r14, r15, rbx, rbp
    mov    rdx, [reg_p2+48]
	bt     r15, 63
    sbb    r8, 0
    
    // [rax, rsp48:rsp56, r9:r15, r8] <- z = a0 x b06 - a1 x b16 + z
    MULADD64x640 [reg_p1], [rsp+48], r9, r10, r11, r12, r13, r14, r15, r8, rbx, rbp, rax, rax
    mov    rdx, [reg_p2+128]    
    MULSUB64x640 [reg_p1+80], [rsp+48], r9, r10, r11, r12, r13, r14, r15, r8, rbx, rbp, rax
    // [r15, r8:r14] <- z = (z0 x p610p1 + z)/2^64    
    xor    r9, r9 
    MULADD64x384b [rip+p610p1+32], r10, r11, r12, r13, r14, r15, r8, rbx, rbp
    mov    rdx, [reg_p2+56]
	bt     r8, 63
    sbb    r9, 0
    
    // [rax, rsp56:rsp64, r10:r15, r8:r9] <- z = a0 x b07 - a1 x b17 + z
    MULADD64x640 [reg_p1], [rsp+56], r10, r11, r12, r13, r14, r15, r8, r9, rbx, rbp, rax, rax
    mov    rdx, [reg_p2+136]    
    MULSUB64x640 [reg_p1+80], [rsp+56], r10, r11, r12, r13, r14, r15, r8, r9, rbx, rbp, rax
    // [r11:r15, r8:r9] <- z = (z0 x p610p1 + z)/2^64
	xor    r10, r10
    MULADD64x384b [rip+p610p1+32], r11, r12, r13, r14, r15, r8, r9, rbx, rbp
    mov    rdx, [reg_p2+64]
	bt     r9, 63
    sbb    r10, 0
    
    // [rax, rsp64:rsp72, r11:r15, r8:r10] <- z = a0 x b08 - a1 x b18 + z
    MULADD64x640 [reg_p1], [rsp+64], r11, r12, r13, r14, r15, r8, r9, r10, rbx, rbp, rax, rax
    mov    rdx, [reg_p2+144]    
    MULSUB64x640 [reg_p1+80], [rsp+64], r11, r12, r13, r14, r15, r8, r9, r10, rbx, rbp, rax
    // [r12:r15, r8:r10] <- z = (z0 x p610p1 + z)/2^64
	xor    r11, r11
    MULADD64x384b [rip+p610p1+32], r12, r13, r14, r15, r8, r9, r10, rbx, rbp
    mov    rdx, [reg_p2+72]
	bt     r10, 63
    sbb    r11, 0
    
    // [rax, rsp72:rsp80, r12:r15, r8:r11] <- z = a0 x b09 - a1 x b19 + z
    MULADD64x640 [reg_p1], [rsp+72], r12, r13, r14, r15, r8, r9, r10, r11, rbx, rbp, rax, rax
    mov    rdx, [reg_p2+152]    
    MULSUB64x640 [reg_p1+80], [rsp+72], r12, r13, r14, r15, r8, r9, r10, r11, rbx, rbp, rax
    // [r12:r15, r8:r10] <- z = (z0 x p610p1 + z)/2^64
	xor    rax, rax
    MULADD64x384b [rip+p610p1+32], r13, r14, r15, r8, r9, r10, r11, rbx, rbp
	bt     r11, 63
    sbb    rax, 0

    // Final correction if result < 0
    mov    rbx, [rip+fmt(p610)]  
    mov    rbp, [rip+fmt(p610)+32]  
    mov    rdx, [rip+fmt(p610)+40]
    and    rbx, rax
    and    rbp, rax
    and    rdx, rax

	mov    rdi, [rsp+80]
	mov    rsi, [rsp+88]
	add    rsp, 112   
    add    rdi, rbx
    adc    rsi, rbx
    adc    r12, rbx
    mov    [rcx], rdi 
    mov    [rcx+8], rsi 
    adc    r13, rbx
	adc    r14, rbp
	adc    r15, rdx
    mov    [rcx+16], r12        
    mov    [rcx+24], r13     
    mov    [rcx+32], r14   
    mov    [rcx+40], r15 
	setc   bl
	
    mov    r13, [rip+fmt(p610)+48]
    mov    rsi, [rip+fmt(p610)+56]
	mov    rdi, [rip+fmt(p610)+64] 
	mov    rdx, [rip+fmt(p610)+72] 
	and    r13, rax 
	and    rsi, rax 
	and    rdi, rax 
	and    rdx, rax
	bt     rbx, 0
    adc    r8, r13
    adc    r9, rsi
    adc    r10, rdi
	adc    r11, rdx
                         
    mov    [rcx+48], r8 
    mov    [rcx+56], r9 
    mov    [rcx+64], r10     
    mov    [rcx+72], r11
    pop    rbp
    pop    rbx
    pop    r15
    pop    r14
    pop    r13
    pop    r12
    ret
*/

//***********************************************************************
//  Squaring in GF(p^2), complex part
//  Operation: c [reg_p2] = 2a0 x a1
//  Inputs: a = [a1, a0] stored in [reg_p1] 
//  Output: c stored in [reg_p2]
//***********************************************************************
.global fp2sqr610_c1_asm
fp2sqr610_c1_asm:  
    push   r12     
    push   r13     
    push   r14 
    push   r15 
	
	mov    r8, [reg_p1]
	mov    r9, [reg_p1+8]
	mov    r10, [reg_p1+16]
	mov    r11, [reg_p1+24]
	mov    r12, [reg_p1+32]
	mov    r13, [reg_p1+40] 
	add    r8, r8
	adc    r9, r9
    push   rbx 
	adc    r10, r10
	adc    r11, r11  
    push   rbp
	adc    r12, r12
	adc    r13, r13
	mov    r14, [reg_p1+48] 
	mov    r15, [reg_p1+56] 
	adc    r14, r14
	adc    r15, r15
	mov    rbx, [reg_p1+64] 
	mov    rbp, [reg_p1+72] 
	adc    rbx, rbx
	adc    rbp, rbp
	sub    rsp, 112
	mov    [rsp+8], r9
	mov    [rsp+16], r10
	mov    [rsp+24], r11
    
    // [rsi0:rsi16, r11:r15, r8:r10] <- z = a00 x a1
    mov    rdx, r8
    mulx   r9, r8, [reg_p1+80]
	mov    [rsp+32], r12
    xor    rax, rax
    mulx   r10, r11, [reg_p1+88] 
	mov    [rsp+40], r13
    adcx   r9, r11     
    mulx   r11, r12, [reg_p1+96]
	mov    [rsp+48], r14
    adcx   r10, r12         
    mulx   r12, r13, [reg_p1+104] 
	mov    [rsp+104], r8
    adcx   r11, r13         
    mulx   r13, r8, [reg_p1+112]
	mov    [rsp+80], r9   
    adcx   r12, r8      
    mulx   r14, r9, [reg_p1+120]
	mov    [rsp+56], r15
    adcx   r13, r9      
    mulx   r15, rax, [reg_p1+128]
	mov    [rsp+88], r10  
    adcx   r14, rax     
    mulx   r8, r10, [reg_p1+136] 
	mov    [rsp+96], r11 
    adcx   r15, r10     
    mulx   r9, rax, [reg_p1+144] 
	mov    [rsp+64], rbx
    adcx   r8, rax    
    mulx   r10, rbx, [reg_p1+152] 
	mov    [rsp+72], rbp
    adcx   r9, rbx    
    adc    r10, 0 
                   
    // [r12:r15, r8:r10] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rsp+104]                  // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r12, r13, r14, r15, r8, r9, r10, rbx, rbp

    // [rsp8:rsp24, r12:r15, r8:r11] <- z = a0 x b11 + a1 x b01 + z 
    mov    rdx, [rsp+8]
    MULADD64x640b [reg_p1+80], [rsp+80], [rsp+80], r12, r13, r14, r15, r8, r9, r10, r11, rbx, rbp, rax, r11
    // [r13:r15, r8:r11] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rsp+104]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r13, r14, r15, r8, r9, r10, r11, rbx, rbp

    // [rsp16:rsp32, r13:r15, r8:r12] <- z = a0 x b12 + a1 x b02 + z 
    mov    rdx, [rsp+16]
    MULADD64x640b [reg_p1+80], [rsp+80], [rsp+80], r13, r14, r15, r8, r9, r10, r11, r12, rbx, rbp, rax, r12
    // [rsp24:rsp40, r14:r15, r8:r12] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rsp+104]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r14, r15, r8, r9, r10, r11, r12, rbx, rbp

    // [rsp24:rsp40, r14:r15, r8:r13] <- z = a0 x b13 + a1 x b03 + z 
    mov    rdx, [rsp+24]
    MULADD64x640b [reg_p1+80], [rsp+80], [rsp+80], r14, r15, r8, r9, r10, r11, r12, r13, rbx, rbp, rax, r13
    // [rsp32:rsp48, r15, r8:r13] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rsp+104]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r15, r8, r9, r10, r11, r12, r13, rbx, rbp

    // [rsp32:rsp48, r15, r8:r14] <- z = a0 x b14 + a1 x b04 + z 
    mov    rdx, [rsp+32]
    MULADD64x640b [reg_p1+80], [rsp+80], [rsp+80], r15, r8, r9, r10, r11, r12, r13, r14, rbx, rbp, rax, r14
    // [rsp40:rsp56, r8:r14] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rsp+104]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r8, r9, r10, r11, r12, r13, r14, rbx, rbp

    // [rsp40:rsp56, r8:r15] <- z = a0 x b15 + a1 x b05 + z 
    mov    rdx, [rsp+40]
    MULADD64x640b [reg_p1+80], [rsp+80], [rsp+80], r8, r9, r10, r11, r12, r13, r14, r15, rbx, rbp, rax, r15
    // [rsp48:rsp64, r9:r15] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rsp+104]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r9, r10, r11, r12, r13, r14, r15, rbx, rbp

    // [rsp48:rsp64, r9:r15, r8] <- z = a0 x b16 + a1 x b06 + z 
    mov    rdx, [rsp+48]
    MULADD64x640b [reg_p1+80], [rsp+80], [rsp+80], r9, r10, r11, r12, r13, r14, r15, r8, rbx, rbp, rax, r8
    // [rsp56:rsp72, r10:r15, r8] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rsp+104]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r10, r11, r12, r13, r14, r15, r8, rbx, rbp

    // [rsp56:rsp72, r10:r15, r8:r9] <- z = a0 x b17 + a1 x b07 + z 
    mov    rdx, [rsp+56]
    MULADD64x640b [reg_p1+80], [rsp+80], [rsp+80], r10, r11, r12, r13, r14, r15, r8, r9, rbx, rbp, rax, r9
    // [rsp64:rsp80, r11:r15, r8:r9] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rsp+104]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r11, r12, r13, r14, r15, r8, r9, rbx, rbp

    // [rsp64:rsp80, r11:r15, r8:r10] <- z = a0 x b18 + a1 x b08 + z 
    mov    rdx, [rsp+64]
    MULADD64x640b [reg_p1+80], [rsp+80], [rsp+80], r11, r12, r13, r14, r15, r8, r9, r10, rbx, rbp, rax, r10
    // [rsp72:rsp88, r12:r15, r8:r10] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rsp+104]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r12, r13, r14, r15, r8, r9, r10, rbx, rbp

    // [rsi0:rsi16, r12:r15, r8:r11] <- z = a0 x b19 + a1 x b09 + z 
    mov    rdx, [rsp+72]
    MULADD64x640b [reg_p1+80], [rsp+80], [reg_p2], r12, r13, r14, r15, r8, r9, r10, r11, rbx, rbp, rax, r11
    // [rsp80:rsp96, r13:r15, r8:r11] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rsp+104]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r13, r14, r15, r8, r9, r10, r11, rbx, rbp
         
    mov    [reg_p2+24], r13   
    mov    [reg_p2+32], r14 
    mov    [reg_p2+40], r15  
    mov    [reg_p2+48], r8      
    mov    [reg_p2+56], r9                  
    mov    [reg_p2+64], r10                 
    mov    [reg_p2+72], r11
	add    rsp, 112
    pop    rbp
    pop    rbx
    pop    r15 
    pop    r14
    pop    r13
    pop    r12
    ret


//***********************************************************************
//  Squaring in GF(p^2), non-complex part
//  Operation: c [reg_p2] = (a0+a1) x (a0-a1)
//  Inputs: a = [a1, a0] stored in [reg_p1] 
//  Output: c stored in [reg_p2]
//***********************************************************************
.global fp2sqr610_c0_asm
fp2sqr610_c0_asm:  
    push   r12
    push   r13
    push   r14  
    push   r15  
    push   rbx  
    push   rbp
	sub    rsp, 32

	// a0 + a1
	mov    r8, [reg_p1]
	mov    r9, [reg_p1+8]
	mov    r10, [reg_p1+16]
	mov    r11, [reg_p1+24]
	mov    r12, [reg_p1+32]
	mov    r13, [reg_p1+40]
	add    r8, [reg_p1+80]
	adc    r9, [reg_p1+88] 
	mov    [reg_p2], r8
	adc    r10, [reg_p1+96]
	adc    r11, [reg_p1+104]
	mov    [reg_p2+8], r9
	mov    [reg_p2+16], r10
	adc    r12, [reg_p1+112]
	adc    r13, [reg_p1+120]
	mov    r14, [reg_p1+48]
	mov    r15, [reg_p1+56]
	adc    r14, [reg_p1+128]
	adc    r15, [reg_p1+136]
	mov    r9, [reg_p1+64]
	mov    r10, [reg_p1+72]
	adc    r9, [reg_p1+144]
	adc    r10, [reg_p1+152]
	mov    [reg_p2+24], r11
	mov    [reg_p2+32], r12
	mov    [reg_p2+40], r13
	mov    [reg_p2+48], r14
	mov    [reg_p2+56], r15
	mov    [reg_p2+64], r9
	mov    [reg_p2+72], r10
	
	// a0 - a1 + 4xp503
	mov    rcx, [reg_p1]
	mov    r10, [reg_p1+8]
	mov    r12, [reg_p1+16]
	mov    r13, [reg_p1+24]
	mov    r14, [reg_p1+32]
	mov    r15, [reg_p1+40]
	sub    rcx, [reg_p1+80]
	sbb    r10, [reg_p1+88]
	sbb    r12, [reg_p1+96]
	sbb    r13, [reg_p1+104] 
	sbb    r14, [reg_p1+112]
	sbb    r15, [reg_p1+120]
	mov    rbx, [reg_p1+48]
	mov    rbp, [reg_p1+56]
	mov    r8, [reg_p1+64]
	mov    rax, [reg_p1+72]
	sbb    rbx, [reg_p1+128]
	sbb    rbp, [reg_p1+136]
	sbb    r8, [reg_p1+144]
	sbb    rax, [reg_p1+152]
	add    rcx, [rip+p610x4]	                  
	mov    rdx, [rip+p610x4+8]
	adc    r10, rdx
	adc    r12, rdx
	adc    r13, rdx
	adc    r14, [rip+p610x4+32]
	adc    r15, [rip+p610x4+40]
	adc    rbx, [rip+p610x4+48]
	adc    rbp, [rip+p610x4+56]
	adc    r8, [rip+p610x4+64]
	adc    rax, [rip+p610x4+72]
	mov    [reg_p2+80], rcx                 
	mov    [reg_p2+88], r10
	mov    [reg_p2+96], r12 
	mov    [reg_p2+104], r13 
	mov    [reg_p2+112], r14 
	mov    [reg_p2+144], r8 
	mov    [reg_p2+152], rax
    
    // [rsi0:rsi16, r11:r15, r8:r10] <- z = a00 x a1
    mov    rdx, [reg_p2]
    mulx   r9, r8, rcx
	mov    [reg_p2+120], r15
    xor    rax, rax 
    mulx   r10, r11, r10 
	mov    [reg_p2+128], rbx
    adcx   r9, r11     
    mulx   r11, r12, r12 
	mov    [reg_p2+136], rbp 
    adcx   r10, r12       
    mulx   r12, r13, r13 
	mov    [rsp+24], r8
    adcx   r11, r13      
    mulx   r13, r8, r14  
	mov    [rsp], r9 
    adcx   r12, r8      
    mulx   r14, r9, r15 
	mov    [rsp+8], r10  
    adcx   r13, r9      
    mulx   r15, rax, rbx 
	mov    [rsp+16], r11  
    adcx   r14, rax     
    mulx   r8, r10, rbp  
    adcx   r15, r10     
    mulx   r9, rax, [reg_p2+144] 
    adcx   r8, rax    
    mulx   r10, rbx, [reg_p2+152] 
    adcx   r9, rbx    
    adc    r10, 0 
                   
    // [r12:r15, r8:r10] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rsp+24]                  // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r12, r13, r14, r15, r8, r9, r10, rbx, rbp

    // [rsp8:rsp24, r12:r15, r8:r11] <- z = a0 x b11 + a1 x b01 + z 
    mov    rdx, [reg_p2+8]
    MULADD64x640b [reg_p2+80], [rsp], [rsp], r12, r13, r14, r15, r8, r9, r10, r11, rbx, rbp, rax, r11
    // [r13:r15, r8:r11] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rsp+24]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r13, r14, r15, r8, r9, r10, r11, rbx, rbp

    // [rsp16:rsp32, r13:r15, r8:r12] <- z = a0 x b12 + a1 x b02 + z 
    mov    rdx, [reg_p2+16]
    MULADD64x640b [reg_p2+80], [rsp], [rsp], r13, r14, r15, r8, r9, r10, r11, r12, rbx, rbp, rax, r12
    // [rsp24:rsp40, r14:r15, r8:r12] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rsp+24]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r14, r15, r8, r9, r10, r11, r12, rbx, rbp

    // [rsp24:rsp40, r14:r15, r8:r13] <- z = a0 x b13 + a1 x b03 + z 
    mov    rdx, [reg_p2+24]
    MULADD64x640b [reg_p2+80], [rsp], [rsp], r14, r15, r8, r9, r10, r11, r12, r13, rbx, rbp, rax, r13
    // [rsp32:rsp48, r15, r8:r13] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rsp+24]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r15, r8, r9, r10, r11, r12, r13, rbx, rbp

    // [rsp32:rsp48, r15, r8:r14] <- z = a0 x b14 + a1 x b04 + z 
    mov    rdx, [reg_p2+32]
    MULADD64x640b [reg_p2+80], [rsp], [rsp], r15, r8, r9, r10, r11, r12, r13, r14, rbx, rbp, rax, r14
    // [rsp40:rsp56, r8:r14] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rsp+24]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r8, r9, r10, r11, r12, r13, r14, rbx, rbp

    // [rsp40:rsp56, r8:r15] <- z = a0 x b15 + a1 x b05 + z 
    mov    rdx, [reg_p2+40]
    MULADD64x640b [reg_p2+80], [rsp], [rsp], r8, r9, r10, r11, r12, r13, r14, r15, rbx, rbp, rax, r15
    // [rsp48:rsp64, r9:r15] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rsp+24]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r9, r10, r11, r12, r13, r14, r15, rbx, rbp

    // [rsp48:rsp64, r9:r15, r8] <- z = a0 x b16 + a1 x b06 + z 
    mov    rdx, [reg_p2+48]
    MULADD64x640b [reg_p2+80], [rsp], [rsp], r9, r10, r11, r12, r13, r14, r15, r8, rbx, rbp, rax, r8
    // [rsp56:rsp72, r10:r15, r8] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rsp+24]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r10, r11, r12, r13, r14, r15, r8, rbx, rbp

    // [rsp56:rsp72, r10:r15, r8:r9] <- z = a0 x b17 + a1 x b07 + z 
    mov    rdx, [reg_p2+56]
    MULADD64x640b [reg_p2+80], [rsp], [rsp], r10, r11, r12, r13, r14, r15, r8, r9, rbx, rbp, rax, r9
    // [rsp64:rsp80, r11:r15, r8:r9] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rsp+24]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r11, r12, r13, r14, r15, r8, r9, rbx, rbp

    // [rsp64:rsp80, r11:r15, r8:r10] <- z = a0 x b18 + a1 x b08 + z 
    mov    rdx, [reg_p2+64]
    MULADD64x640b [reg_p2+80], [rsp], [rsp], r11, r12, r13, r14, r15, r8, r9, r10, rbx, rbp, rax, r10
    // [rsp72:rsp88, r12:r15, r8:r10] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rsp+24]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r12, r13, r14, r15, r8, r9, r10, rbx, rbp

    // [rsi0:rsi16, r12:r15, r8:r11] <- z = a0 x b19 + a1 x b09 + z 
    mov    rdx, [reg_p2+72]
    MULADD64x640b [reg_p2+80], [rsp], [reg_p2], r12, r13, r14, r15, r8, r9, r10, r11, rbx, rbp, rax, r11
    // [rsp80:rsp96, r13:r15, r8:r11] <- z = (z0 x p610p1 + z)/2^64
    mov    rdx, [rsp+24]                 // rdx <- z0
    MULADD64x384 [rip+p610p1+32], r13, r14, r15, r8, r9, r10, r11, rbx, rbp
           
    mov    [reg_p2+24], r13   
    mov    [reg_p2+32], r14 
    mov    [reg_p2+40], r15  
    mov    [reg_p2+48], r8      
    mov    [reg_p2+56], r9                  
    mov    [reg_p2+64], r10                 
    mov    [reg_p2+72], r11
	add    rsp, 32
    pop    rbp
    pop    rbx
    pop    r15 
    pop    r14
    pop    r13
    pop    r12
    ret