## lab3-0实验报告

姓名：杨城

学号：PB17111659

### 实验要求

本次实验主要包括以下内容：手工翻译C程序为.ll文件，实现相同的逻辑功能；编写cpp文件生成与C程序相同逻辑功能的.ll文件。本次实验主要是让同学基本了解.ll文件的架构和调用llvm库的过程。并且为之后编译cminus打下知识基础。

### 实验结果

assign.c

```c++
// BasicBlock entry 
builder.SetInsertPoint(bb);
// Instuction
auto aAlloca = builder.CreateAlloca(TYPE32);        // define a
builder.CreateStore(CONST(1), aAlloca);         // a = 1
auto aLoad = builder.CreateLoad(aAlloca);
builder.CreateRet(aLoad);       // return value

对应

entry:                                                                                     %0 = alloca i32                                                                           store i32 1, i32* %0                                                                     %1 = load i32, i32* %0                                                                   ret i32 %1
```

if.c

```c++
// BasicBlock entry
builder.SetInsertPoint(bb);
// Instuction
// At first, new space for 1 and 2
auto xAlloca = builder.CreateAlloca(TYPE32);
auto yAlloca = builder.CreateAlloca(TYPE32);
builder.CreateStore(CONST(2), xAlloca);
builder.CreateStore(CONST(1), yAlloca);
auto xLoad = builder.CreateLoad(xAlloca);
auto yLoad = builder.CreateLoad(yAlloca);
auto icmp = builder.CreateICmpSGT(xLoad, yLoad);
auto trueBB = BasicBlock::Create(context, "true", mainFun);
auto falseBB = BasicBlock::Create(context, "false", mainFun);
builder.CreateCondBr(icmp, trueBB, falseBB);        // compare

对应
    
entry:
  %0 = alloca i32
  %1 = alloca i32
  store i32 2, i32* %0
  store i32 1, i32* %1
  %2 = load i32, i32* %0
  %3 = load i32, i32* %1
  %4 = icmp sgt i32 %2, %3
  br i1 %4, label %true, label %false
```

```c++
// BasicBlock true
builder.SetInsertPoint(trueBB);
builder.CreateRet(CONST(1));

对应
    
true:     
  ret i32 1
```

```c++
// BasicBlock false
builder.SetInsertPoint(falseBB);
builder.CreateRet(CONST(0));

对应
    
false:                  
  ret i32 0
```

while.c

```c++
// BasicBlock entry
builder.SetInsertPoint(bb);
// Instruction
auto aAlloca = builder.CreateAlloca(TYPE32);        // int a
auto iAlloca = builder.CreateAlloca(TYPE32);        // int i
builder.CreateStore(CONST(10), aAlloca);        // a = 10
builder.CreateStore(CONST(0), iAlloca);         // i = 10
auto whileBB = BasicBlock::Create(context, "while", mainFun);
auto trueBB = BasicBlock::Create(context, "true", mainFun);
auto falseBB = BasicBlock::Create(context, "false", mainFun);
builder.CreateBr(whileBB);

对应
    
entry:
  %0 = alloca i32
  %1 = alloca i32
  store i32 10, i32* %0
  store i32 0, i32* %1
  br label %while
```

```c++
// BasicBlock while
builder.SetInsertPoint(whileBB);
auto iLoad = builder.CreateLoad(iAlloca);       
auto icmp = builder.CreateICmpSLT(iLoad, CONST(10));        // compare i with 10
builder.CreateCondBr(icmp, trueBB, falseBB);        // branch

对应
    
while:                        
  %2 = load i32, i32* %1
  %3 = icmp slt i32 %2, 10
  br i1 %3, label %true, label %false
```

```c++
// BasicBlock true
builder.SetInsertPoint(trueBB);
auto ival = builder.CreateNSWAdd(iLoad, CONST(1));        // i = i + 1
builder.CreateStore(ival, iAlloca);
auto aLoad = builder.CreateLoad(aAlloca);
auto aval = builder.CreateNSWAdd(aLoad, ival);      // a = a + i 
builder.CreateStore(aval, aAlloca);
builder.CreateBr(whileBB);      // jump forward


对应

true:                                         
  %4 = add nsw i32 %2, 1
  store i32 %4, i32* %1
  %5 = load i32, i32* %0
  %6 = add nsw i32 %5, %4
  store i32 %6, i32* %0
  br label %while
```

```c++
// BasicBlock false
builder.SetInsertPoint(falseBB);
aLoad = builder.CreateLoad(aAlloca);
builder.CreateRet(aLoad);

对应
    
false:                           
  %7 = load i32, i32* %0
  ret i32 %7
```

call.c

```c++
// BasicBlock entry
builder.SetInsertPoint(bb);
auto arg = calleeFun->arg_begin();      // param
auto retval = builder.CreateNSWMul(CONST(2), arg);      // a * 2
builder.CreateRet(retval);      // return

对应
    
entry:
  %1 = mul nsw i32 2, %0
  ret i32 %1
```

```c++
// BasicBlock entry
builder.SetInsertPoint(bb);
auto call = builder.CreateCall(calleeFun, {CONST(10)});     // call callee
builder.CreateRet(call);      // return

对应
    
entry:
  %0 = call i32 @callee(i32 10)
  ret i32 %0    
```

### 实验难点

- 难点：不理解.ll文件的结构
  - 解决方案：翻阅LLVM IR文档熟悉语法
- 难点：不了解LLVM库的调用方式
  - 解决方案：模仿助教给出的cpp程序完成实验

### 实验总结

基本了解了.ll文件的架构和调用llvm库的过程，为之后编译cminus打下知识基础。
