define i32 @callee(i32) #0 {
    %value = mul nsw i32 2, %0      ; 2 * a
    ret i32 %value
}

define i32 @main() #0 {
    %value = call i32 @callee(i32 10)       ; call callee
    ret i32 %value
}
