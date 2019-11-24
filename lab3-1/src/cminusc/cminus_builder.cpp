#include "cminus_builder.hpp"
#include <iostream>
using namespace llvm;
using namespace std;
#define CONST(num) \
    ConstantInt::get(context, APInt(32, num)) //得到常数值的表示,方便后面多次用到

Function *func;
Value *Exp_val;
Value *Bool_val;
// int exp_val;
//Value *Var_addr;
// int var_addr;
int stmt_num;

#define TyInt32 llvm::Type::getInt32Ty(context)

// You can define global variables here
// to store state

void CminusBuilder::visit(syntax_program &node)
{
    printf("program begin:\n");
    for (auto decl : node.declarations)
    {
        decl->accept(*this);
    }
    printf("program end:\n");
}

void CminusBuilder::visit(syntax_num &node)
{
    printf("num begin:\n");
    Exp_val = CONST(node.value);
    printf("num end:\n");
}

void CminusBuilder::visit(syntax_var_declaration &node)
{
    printf("var_declaration begin:\n");
    int temp = 0;
    Type *TYPE32 = Type::getInt32Ty(context);

    if (scope.in_global())
    {
        if (node.num != nullptr)
        {
            temp = node.num->value;
            auto global = new GlobalVariable(*(module.get()), ArrayType::get(TYPE32, temp), false,
                                             GlobalValue::LinkageTypes::CommonLinkage, ConstantAggregateZero::get(ArrayType::get(TYPE32, temp)),
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
    printf("var_declaration end:\n");
}

void CminusBuilder::visit(syntax_fun_declaration &node)
{
    printf("fun_declaration begin:\n");
    auto TyVoid = llvm::Type::getVoidTy(context);
    std::vector<Type *> Ints(node.params.size(), TyInt32);
    FunctionType *fun_type;
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
    auto bb = BasicBlock::Create(context, "entry", Fun);
    // BasicBlock entry
    builder.SetInsertPoint(bb);
    scope.push(node.id, Fun);
    scope.enter();
    for (auto i : node.params)
    {
        i->accept(*this);
    }
    std::vector<Value *> args; //获取gcd函数的参数,通过iterator
    for (auto arg = Fun->arg_begin(); arg != Fun->arg_end(); arg++)
    {
        args.push_back(arg);
    }
    int index = 0;
    for (auto i : node.params)
    {
        auto id1 = scope.find(i->id);
        builder.CreateStore(args[index], id1);
        index++;
    }
    node.compound_stmt->accept(*this);
    scope.exit();
    printf("fun_declaration end:\n");
}

void CminusBuilder::visit(syntax_param &node)
{
    printf("param begin:\n");
    if (node.type == TYPE_INT)
    {
        if (node.isarray)
        {
            auto uAlloca = builder.CreateAlloca(ArrayType::getInt32PtrTy(context));
            scope.push(node.id, uAlloca);
        }
        else
        {
            auto uAlloca = builder.CreateAlloca(TyInt32);
            scope.push(node.id, uAlloca);
        }
    }
    printf("param end:\n");
}

void CminusBuilder::visit(syntax_compound_stmt &node)
{
    printf("compound_stmt begin:\n");
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
        stmt_num--;
        printf("syntax_compound_stmt stmt_num: %d\n", stmt_num);
        stmt->accept(*this);
    }
    scope.exit();
    printf("compound_stmt end:\n");
}

void CminusBuilder::visit(syntax_expresion_stmt &node)
{
    printf("expresion_stmt begin:\n");
    if (node.expression != nullptr)
        node.expression->accept(*this);
    printf("expresion_stmt end:\n");
}

void CminusBuilder::visit(syntax_selection_stmt &node)
{
    std::cout<<"selection_stmt begin"<<endl;
    //printf("selection_stmt begin:\n");
    if (stmt_num > 0)
    {
        if (node.else_statement != nullptr)
        {
            auto trueBB = llvm::BasicBlock::Create(context, "trueBB", func);
            auto falseBB = llvm::BasicBlock::Create(context, "falseBB", func);
            auto endBB = llvm::BasicBlock::Create(context, "endBB", func);

            node.expression->accept(*this);
            // auto icmp = builder.CreateICmpNE(Exp_val, CONST(0));
            auto br = builder.CreateCondBr(Exp_val, trueBB, falseBB);

            builder.SetInsertPoint(trueBB);
            node.if_statement->accept(*this);
            if (!trueBB->getTerminator()) {
                builder.CreateBr(endBB);
            }

            builder.SetInsertPoint(falseBB);
            node.else_statement->accept(*this);
            if (!falseBB->getTerminator()) {
                builder.CreateBr(endBB);
            }

            // builder.CreateBr(endBB);
            builder.SetInsertPoint(endBB);
        }
        else
        {
            auto trueBB = llvm::BasicBlock::Create(context, "trueBB", func);
            auto endBB = llvm::BasicBlock::Create(context, "endBB", func);

            node.expression->accept(*this);
            // auto icmp = builder.CreateICmpNE(Exp_val, CONST(0));
            //printf("select begin:\n");
            auto br = builder.CreateCondBr(Exp_val, trueBB, endBB);

            builder.SetInsertPoint(trueBB);
            node.if_statement->accept(*this);
            builder.CreateBr(endBB);
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
            // auto icmp = builder.CreateICmpNE(Exp_val, CONST(0));
            auto br = builder.CreateCondBr(Exp_val, trueBB, falseBB);

            builder.SetInsertPoint(trueBB);
            node.if_statement->accept(*this);

            builder.SetInsertPoint(falseBB);
            node.else_statement->accept(*this);
        }
    }
    std::cout<<"selection_stmt end"<<endl;
    //printf("selection_stmt end:\n");
}

void CminusBuilder::visit(syntax_iteration_stmt &node)
{
    printf("iteration_stmt beign:\n");
    auto jugBB = llvm::BasicBlock::Create(context, "jugBB", func);
    auto trueBB = llvm::BasicBlock::Create(context, "trueBB", func);
    auto falseBB = llvm::BasicBlock::Create(context, "falseBB", func);

    builder.CreateBr(jugBB);
    builder.SetInsertPoint(jugBB);
    node.expression->accept(*this);
    auto br = builder.CreateCondBr(Exp_val, trueBB, falseBB);

    builder.SetInsertPoint(trueBB);
    node.statement->accept(*this);
    builder.CreateBr(jugBB);

    printf("stmt_num: %d\n", stmt_num);
    builder.SetInsertPoint(falseBB);
    std::cout<<"iteration_stmt end"<<endl;
    //printf("iteration_stmt end:\n");
}

void CminusBuilder::visit(syntax_return_stmt &node)
{
    std::cout<<"return_stmt begin"<<endl;
    //printf("return_stmt begin:\n");
    if (node.expression == nullptr)
    {
        builder.CreateRetVoid();
        return;
    }
    else
    {
        node.expression->accept(*this); //得到expression的值
        builder.CreateRet(Exp_val);     //全局变量 表达式的值
    }
    std::cout<<"return_stmt end"<<endl;
    //printf("return_stmt end:\n");
}

void CminusBuilder::visit(syntax_var &node)
{
    std::cout<<"var begin"<<endl;
    llvm::Value *Var_addr = scope.find(node.id);
    if (node.expression != nullptr)
    {
        node.expression->accept(*this);
        Var_addr = builder.CreateGEP(Var_addr, {CONST(0),Exp_val}, node.id);
        /*auto icmp = builder.CreateICmpSGE(Exp_val, CONST(0));

        auto normal = BasicBlock::Create(context, "normal", func);
        auto except = BasicBlock::Create(context, "except", func);
        auto check_end = BasicBlock::Create(context, "check_end", func);
        auto br = builder.CreateCondBr(icmp, normal, except);

        builder.SetInsertPoint(normal);
        Var_addr = builder.CreateGEP(Var_addr, {CONST(0),Exp_val}, node.id);
        builder.CreateBr(check_end);

        builder.SetInsertPoint(except);
        auto neg = scope.find("neg_idx_except");
        builder.CreateCall(neg);
        //builder.CreateRet(call);

        builder.CreateBr(check_end);

        builder.SetInsertPoint(check_end);
        /*int Index;
        if (ConstantInt *CI = dyn_cast<ConstantInt>(Exp_val))
        {
            if (CI->getBitWidth() <= 32)
            {
                Index = CI->getSExtValue();
            }
        }

        if (Index < 0)
        {
            auto *except = module->getFunction("neg_idx_except");
            builder.CreateCall(except);
        }
        else
        {
            Value *addr = scope.find(node.id);
            Var_addr = builder.CreateGEP(addr, Exp_val, "array");
        }*/
    }
    /*int *addr;
    ConstantInt *C = dyn_cast<ConstantInt>(Var_addr);
    addr = C->getSExtValue();*/
    Exp_val = builder.CreateLoad(Var_addr);
    std::cout<<"var end"<<endl;
}

void CminusBuilder::visit(syntax_assign_expression &node)
{
    //printf("assign_expression begin:\n");
    std::cout<<"assign_expression begin"<<endl;
    llvm::Value *Var_addr = scope.find(node.var->id);
    if (node.var->expression != nullptr)
    {
        node.var->expression->accept(*this);
        /*int Index;
        if (ConstantInt *CI = dyn_cast<ConstantInt>(Exp_val))
        {
            if (CI->getBitWidth() <= 32)
            {
                Index = CI->getSExtValue();
            }
        }

        if (Index < 0)
        {
            auto *except = module->getFunction("neg_idx_except");
            builder.CreateCall(except);
        }
        else
        {
            Value *addr = scope.find(node.var->id);
            Var_addr = builder.CreateGEP(addr, Exp_val, "array");
        }*/
        //无下标越界检查
        Var_addr = builder.CreateGEP(Var_addr, {CONST(0), Exp_val}, node.var->id);
    }
    
    
    //node.var->accept(*this);
    //调用 var 得到地址后，直接使用。
    node.expression->accept(*this);
    //llvm::APInt addr = llvm::APInt(32, var_addr);
    //llvm::APInt val = llvm::APInt(32, exp_val);
    // outs()<<Exp_val->getType()->getTypeID()<<'\n';
    builder.CreateStore(Exp_val, Var_addr);
    //printf("assign_expression end:\n");
    std::cout<<"assign_expression end"<<endl;
}

void CminusBuilder::visit(syntax_simple_expression &node)
{
    std::cout<<"simple_expression begin"<<endl;
    //printf("simple_expression begin:\n");
    if (node.additive_expression_r == nullptr)
    {
        node.additive_expression_l->accept(*this);
    }
    else
    {
        node.additive_expression_l->accept(*this);
        auto addiexpr1 = Exp_val;
        node.additive_expression_r->accept(*this);
        auto addiexpr2 = Exp_val;
        if (node.op == OP_LT)
        {
            Exp_val = builder.CreateICmpSLT(addiexpr1, addiexpr2);
        }
        else if (node.op == OP_LE)
        {
            Exp_val = builder.CreateICmpSLE(addiexpr1, addiexpr2);
        }
        else if (node.op == OP_GE)
        {
            Exp_val = builder.CreateICmpSGE(addiexpr1, addiexpr2);
        }
        else if (node.op == OP_GT)
        {
            Exp_val = builder.CreateICmpSGT(addiexpr1, addiexpr2);
        }
        else if (node.op == OP_EQ)
        {
            //printf("EQ begin:\n");
            Exp_val = builder.CreateICmpEQ(addiexpr1, addiexpr2);
            //printf("EQ end:\n");
        }
        else if (node.op == OP_NEQ)
        {
            Exp_val = builder.CreateICmpNE(addiexpr1, addiexpr2);
        }
    }
    std::cout<<"simple_expression end"<<endl;
    //printf("simple_expression end:\n");
}

void CminusBuilder::visit(syntax_additive_expression &node)
{
    std::cout<<"additive_expression begin"<<endl;
    //printf("additive_expression begin:\n");
    if (node.additive_expression == nullptr)
    {
        node.term->accept(*this);
    }
    else
    {
        node.additive_expression->accept(*this);
        auto addiexpr = Exp_val;
        node.term->accept(*this);
        auto term = Exp_val;
        if (node.op == OP_PLUS)
        {
            Exp_val = builder.CreateNSWAdd(addiexpr, term);
        }
        else if (node.op == OP_MINUS)
        {
            Exp_val = builder.CreateNSWSub(addiexpr, term);
        }
    }
    //printf("additive_expression end:\n");
    std::cout<<"additive_expression end"<<endl;
}

void CminusBuilder::visit(syntax_term &node)
{
    std::cout<<"term begin"<<endl;
    //printf("term begin:\n");
    if (node.term == nullptr)
    {
        node.factor->accept(*this);
    }
    else
    {
        node.term->accept(*this);
        auto term = Exp_val;
        node.factor->accept(*this);
        auto factor = Exp_val;
        if (node.op == OP_MUL)
        {
            Exp_val = builder.CreateNSWMul(term, factor);
        }
        else if (node.op == OP_DIV)
        {
            Exp_val = builder.CreateSDiv(term, factor);
        }
    }
    //printf("term end:\n");
    std::cout<<"term end"<<endl;
}

void CminusBuilder::visit(syntax_call &node)
{
    std::cout<<"call begin"<<endl;
    //printf("call begin:\n");
    auto CalleeF = scope.find(node.id);
    vector<Value *> Argu;
    for (auto s = node.args.begin(); s != node.args.end(); s++)
    {
        (*s)->accept(*this);
        Argu.push_back(Exp_val);
    }
    builder.CreateCall(CalleeF, Argu);
    //printf("call end:\n");
    std::cout<<"call end"<<endl;
}