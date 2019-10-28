define i32 @main() #0 {
    %cond = icmp sgt i32 2, 1     ; 2 > 1?
    br i1 %cond, label %true, label %false

true:
    ret i32 1       ; return 1

false:
    ret i32 0       ; return 0
}
