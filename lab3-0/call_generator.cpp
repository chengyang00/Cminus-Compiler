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
    auto module = new Module("call", context);

    // callee函数
    // 函数参数类型的vector
    std::vector<Type *> Ints(1, TYPE32);
    auto calleeFun = Function::Create(FunctionType::get(TYPE32, Ints, false),
                                   GlobalValue::LinkageTypes::ExternalLinkage,
                                   "callee", module);
    auto bb = BasicBlock::Create(context, "entry", calleeFun);
    // BasicBlock entry
    builder.SetInsertPoint(bb);
    auto arg = calleeFun->arg_begin();      // param
    auto retval = builder.CreateNSWMul(CONST(2), arg);      // a * 2
    builder.CreateRet(retval);      // return

    // main函数
    auto mainFun = Function::Create(FunctionType::get(TYPE32, false),
                                    GlobalValue::LinkageTypes::ExternalLinkage,
                                    "main", module);
    bb = BasicBlock::Create(context, "entry", mainFun);
    // BasicBlock entry
    builder.SetInsertPoint(bb);
    auto call = builder.CreateCall(calleeFun, {CONST(10)});     // call callee
    builder.CreateRet(call);      // return
    
    builder.ClearInsertionPoint();
    module->print(outs(), nullptr);
    delete module;
    return 0;
}