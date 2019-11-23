#include "cminus_builder.hpp"
#include <iostream>
using namespace llvm;
using namespace std;
#define CONST(num) \
    ConstantInt::get(context, APInt(32, num)) //得到常数值的表示,方便后面多次用到

AllocaInst *retv;           //store return value
Function *func;
int exp_val;
int var_addr;
int stmt_num = 0;

// You can define global variables here
// to store state

void CminusBuilder::visit(syntax_program &node)
{
    for (auto decl : node.declarations)
    {
        decl->accept(*this);
    }
}

void CminusBuilder::visit(syntax_num &node)
{
    printf("num\n");
    exp_val = node.value;
}

void CminusBuilder::visit(syntax_var_declaration &node)
{
   printf("var_declaration\n");
    int temp = 0;
    Type *TYPE32 = Type::getInt32Ty(context);

    if (scope.in_global())
    {
        if (node.num != nullptr)
        {
            temp = node.num->value;
            auto global = new GlobalVariable(*(module.get()), ArrayType::get(TYPE32,temp), false,
                                             GlobalValue::LinkageTypes::CommonLinkage, ConstantAggregateZero::get(ArrayType::get(TYPE32,temp)),
                                             node.id);
            scope.push(node.id, global);
        }
        else
        {
            auto global = new GlobalVariable(*(module.get()), TYPE32, false,
                                             GlobalValue::LinkageTypes::CommonLinkage, ConstantAggregateZero::get(TYPE32),
                                             node.id);
            scope.push(node.id, global);
        }
    }
    else
    {
        if (node.num != nullptr)
        {
            temp = node.num->value;
            auto local = builder.CreateAlloca(ArrayType::get(TYPE32, temp));
            scope.push(node.id, local);
        }
        else
        {
            auto local = builder.CreateAlloca(TYPE32);
            scope.push(node.id, local);
        } 
    }
}

void CminusBuilder::visit(syntax_fun_declaration &node)
{
    auto TyVoid = llvm::Type::getVoidTy(context);
    auto TyInt32 = llvm::Type::getInt32Ty(context);
    std::vector<Type *> Ints(node.params.size(), TyInt32);
    auto fun_type = llvm::FunctionType::get(TyVoid, false);
    if (node.params.size() > 0)
    {
        if (node.type == TYPE_VOID)
        {
            fun_type = FunctionType::get(TyVoid, Ints, false);
        }
        else
        {
            fun_type = FunctionType::get(TyInt32, Ints, false);
        }
    }
    else
    {
        if (node.type == TYPE_INT)
        {
            fun_type = llvm::FunctionType::get(TyInt32, false);
        }
        else
        {
            fun_type = FunctionType::get(TyVoid, false);
        }
    }

    auto Fun = llvm::Function::Create(fun_type,
                                      GlobalValue::LinkageTypes::ExternalLinkage,
                                      node.id, module.get());
    func = Fun;
    scope.push(node.id, Fun);
    scope.enter();
    for (auto i : node.params)
    {
        i->accept(*this);
    }
    node.compound_stmt->accept(*this);
    scope.exit();
}

void CminusBuilder::visit(syntax_param &node)
{
    Type *TYPE32 = llvm::Type::getInt32Ty(context);
    retv = builder.CreateAlloca(TYPE32);
    auto uAlloca = builder.CreateAlloca(TYPE32);
    if (node.isarray)
    {
        uAlloca = builder.CreateAlloca(Type::getInt32PtrTy(context));
    }
    scope.push(node.id, uAlloca);
}

void CminusBuilder::visit(syntax_compound_stmt &node)
{
    scope.enter();
    for (auto delc : node.local_declarations)
    {
        delc->accept(*this);
    }
    for (auto stmt : node.statement_list)
    {
        stmt_num++;
    }
    for (auto stmt : node.statement_list)
    {
        stmt->accept(*this);
        stmt_num--;
    }
    scope.exit();
}

void CminusBuilder::visit(syntax_expresion_stmt &node)
{
    if (node.expression != nullptr)
        node.expression->accept(*this);
}

void CminusBuilder::visit(syntax_selection_stmt &node)
{
    if (stmt_num > 0)
    {
        if (node.else_statement != nullptr)
        {
            auto trueBB = llvm::BasicBlock::Create(context, "trueBB", func);
            auto falseBB = llvm::BasicBlock::Create(context, "falseBB", func);
            auto endBB = llvm::BasicBlock::Create(context, "endBB", func);

            node.expression->accept(*this);
            auto icmp = builder.CreateICmpEQ(CONST(exp_val), CONST(0));
            auto br = builder.CreateCondBr(icmp, trueBB, falseBB);

            builder.SetInsertPoint(trueBB);
            node.if_statement->accept(*this);
            builder.CreateBr(endBB);

            builder.SetInsertPoint(falseBB);
            node.else_statement->accept(*this);
            builder.CreateBr(endBB);

            builder.CreateBr(endBB);
            builder.SetInsertPoint(endBB);
        }
        else
        {
            auto trueBB = llvm::BasicBlock::Create(context, "trueBB", func);
            auto endBB = llvm::BasicBlock::Create(context, "endBB", func);

            node.expression->accept(*this);
            auto icmp = builder.CreateICmpEQ(CONST(exp_val), CONST(0));
            auto br = builder.CreateCondBr(icmp, trueBB, endBB);

            builder.SetInsertPoint(trueBB);
            node.if_statement->accept(*this);

            builder.SetInsertPoint(endBB);
        }
    }
    else
    {
        if (node.else_statement != nullptr)
        {
            auto trueBB = llvm::BasicBlock::Create(context, "trueBB", func);
            auto falseBB = llvm::BasicBlock::Create(context, "falseBB", func);

            node.expression->accept(*this);
            auto icmp = builder.CreateICmpEQ(CONST(exp_val), CONST(0));
            auto br = builder.CreateCondBr(icmp, trueBB, falseBB);

            builder.SetInsertPoint(trueBB);
            node.if_statement->accept(*this);

            builder.SetInsertPoint(falseBB);
            node.else_statement->accept(*this);
        }
    }
}

void CminusBuilder::visit(syntax_iteration_stmt &node)
{
    auto trueBB = llvm::BasicBlock::Create(context, "trueBB", func); //unfinished
    auto falseBB = llvm::BasicBlock::Create(context, "falseBB", func);
    auto jugBB = llvm::BasicBlock::Create(context, "jugBB", func);

    builder.SetInsertPoint(jugBB);
    node.expression->accept(*this);
    auto icmp = builder.CreateICmpEQ(CONST(exp_val), CONST(0)); //表达式的值
    auto br = builder.CreateCondBr(icmp, trueBB, falseBB);

    builder.SetInsertPoint(trueBB);
    node.statement->accept(*this);
    builder.CreateBr(jugBB);

    builder.SetInsertPoint(falseBB);
    //unfinished
}

void CminusBuilder::visit(syntax_return_stmt &node)
{
    if (node.expression == nullptr)
    {
        return;
    }
    else
    {
        node.expression->accept(*this);    //得到expression的值
        builder.CreateRet(CONST(exp_val)); //全局变量 表达式的值
    }
}

void CminusBuilder::visit(syntax_var &node)
{
    if (node.expression != nullptr)
    {
        node.expression->accept(*this);
        if (exp_val < 0)
        {
            auto *except = module->getFunction("neg_idx_except");
            builder.CreateCall(except);
            //未完成
        }
        else
        {

            llvm::Value *addr = scope.find(node.id);
            var_addr += exp_val * 4;
        }
    }
    else
    {
        std::string name = node.id;
        llvm::Value *Val = scope.find(name);
        //TYTE 转成 C++的int类型
        if (ConstantInt *CI = dyn_cast<ConstantInt>(Val))
        {
            if (CI->getBitWidth() <= 32)
            {
                var_addr = CI->getSExtValue();
            }
        }
    }
}

void CminusBuilder::visit(syntax_assign_expression &node)
{
    node.var->accept(*this);
    //调用 var 得到地址后，直接使用。
    node.expression->accept(*this);
    //
    //llvm::APInt addr = llvm::APInt(32, var_addr);
    //llvm::APInt val = llvm::APInt(32, exp_val);
    builder.CreateStore(CONST(var_addr), CONST(exp_val));
}

void CminusBuilder::visit(syntax_simple_expression &node)
{
    if (node.additive_expression_r == nullptr)
    {
        node.additive_expression_l->accept(*this);
    }
    else
    {
        node.additive_expression_l->accept(*this);
        int addiexpr1 = exp_val;
        node.additive_expression_r->accept(*this);
        int addiexpr2 = exp_val;
        if (node.op == OP_LT)
        {
            builder.CreateICmpSLT(CONST(addiexpr1), CONST(addiexpr2));
            if (addiexpr1 < addiexpr2)
                exp_val = 1;
            else
                exp_val = 0;
        }
        else if (node.op == OP_LE)
        {
            builder.CreateICmpSLE(CONST(addiexpr1), CONST(addiexpr2));
            if (addiexpr1 <= addiexpr2)
                exp_val = 1;
            else
                exp_val = 0;
        }
        else if (node.op == OP_GE)
        {
            builder.CreateICmpSGE(CONST(addiexpr1), CONST(addiexpr2));
            if (addiexpr1 >= addiexpr2)
                exp_val = 1;
            else
                exp_val = 0;
        }
        else if (node.op == OP_GT)
        {
            builder.CreateICmpSGT(CONST(addiexpr1), CONST(addiexpr2));
            if (addiexpr1 > addiexpr2)
                exp_val = 1;
            else
                exp_val = 0;
        }
        else if (node.op == OP_EQ)
        {
            builder.CreateICmpEQ(CONST(addiexpr1), CONST(addiexpr2));
            if (addiexpr1 == addiexpr2)
                exp_val = 1;
            else
                exp_val = 0;
        }
        else if (node.op == OP_NEQ)
        {
            builder.CreateICmpNE(CONST(addiexpr1), CONST(addiexpr2));
            if (addiexpr1 != addiexpr2)
                exp_val = 1;
            else
                exp_val = 0;
        }
    }
}

void CminusBuilder::visit(syntax_additive_expression &node)
{
    if (node.additive_expression == nullptr)
    {
        node.term->accept(*this);
    }
    else
    {
        node.additive_expression->accept(*this);
        int addiexpr = exp_val;
        node.term->accept(*this);
        int term = exp_val;
        if (node.op == OP_PLUS)
        {
            exp_val = addiexpr + term;
            builder.CreateNSWAdd(CONST(addiexpr), CONST(term));
        }
        else if (node.op == OP_MINUS)
        {
            exp_val = addiexpr - term;
            builder.CreateNSWSub(CONST(addiexpr), CONST(term));
        }
    }
}

void CminusBuilder::visit(syntax_term &node)
{
    if (node.term == nullptr)
    {
        node.factor->accept(*this);
    }
    else
    {
        node.term->accept(*this);
        int term = exp_val;
        node.factor->accept(*this);
        int factor = exp_val;
        if (node.op == OP_MUL)
        {
            exp_val = term * factor;
            builder.CreateNSWMul(CONST(term), CONST(factor));
        }
        else if (node.op == OP_DIV)
        {
            exp_val = term / factor;
            builder.CreateSDiv(CONST(term), CONST(factor));
        }
    }
}

void CminusBuilder::visit(syntax_call &node)
{
    auto CalleeF = scope.find(node.id);
    vector<Value *> Argu;
    for (auto s = node.args.begin(); s != node.args.end(); s++)
    {
        (*s)->accept(*this);
        Argu.push_back(CONST(exp_val));
    }
    builder.CreateCall(CalleeF, Argu);
}
