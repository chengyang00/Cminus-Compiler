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
    auto module = new Module("if", context);

    // main函数
    auto mainFun = Function::Create(FunctionType::get(TYPE32, false),
                                    GlobalValue::LinkageTypes::ExternalLinkage,
                                    "main", module);
    auto bb = BasicBlock::Create(context, "entry", mainFun);
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
    // BasicBlock true
    builder.SetInsertPoint(trueBB);
    builder.CreateRet(CONST(1));
    // BasicBlock false
    builder.SetInsertPoint(falseBB);
    builder.CreateRet(CONST(0));

    builder.ClearInsertionPoint();
    module->print(outs(), nullptr);
    delete module;
    return 0;
}