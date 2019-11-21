#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/Verifier.h>

#include <iostream>
#include <memory>

#ifdef DEBUG                                             // 用于调试信息，大家可以在编译过程中通过" -DDEBUG"来开启这一选项
#define DEBUG_OUTPUT std::cout << __LINE__ << std::endl; // 输出行号的简单示例
#else
#define DEBUG_OUTPUT
#endif

using namespace llvm; // 指明命名空间为llvm
#define CONST(num) \
    ConstantInt::get(context, APInt(32, num)) //得到常数值的表示,方便后面多次用到

int main()
{
    LLVMContext context;
    Type *TYPE32 = Type::getInt32Ty(context);
    IRBuilder<> builder(context);
    auto module = new Module("while", context);

    // main函数
    auto mainFun = Function::Create(FunctionType::get(TYPE32, false),
                                    GlobalValue::LinkageTypes::ExternalLinkage,
                                    "main", module);
    auto bb = BasicBlock::Create(context, "entry", mainFun);
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
    // BasicBlock while
    builder.SetInsertPoint(whileBB);
    auto iLoad = builder.CreateLoad(iAlloca);       
    auto icmp = builder.CreateICmpSLT(iLoad, CONST(10));        // compare i with 10
    builder.CreateCondBr(icmp, trueBB, falseBB);        // branch
    // BasicBlock true
    builder.SetInsertPoint(trueBB);
    auto ival = builder.CreateNSWAdd(iLoad, CONST(1));        // i = i + 1
    builder.CreateStore(ival, iAlloca);
    auto aLoad = builder.CreateLoad(aAlloca);
    auto aval = builder.CreateNSWAdd(aLoad, ival);      // a = a + i 
    builder.CreateStore(aval, aAlloca);
    builder.CreateBr(whileBB);      // jump forward
    // BasicBlock false
    builder.SetInsertPoint(falseBB);
    aLoad = builder.CreateLoad(aAlloca);
    builder.CreateRet(aLoad);

    builder.ClearInsertionPoint();
    module->print(outs(), nullptr);
    delete module;
    return 0;
}