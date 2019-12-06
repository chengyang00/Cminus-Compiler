#include "cminus_builder.hpp"
#include <iostream>
using namespace llvm;
using namespace std;

#define CONST(num) \
    ConstantInt::get(context, APInt(32, num)) //得到常数值的表示,方便后面多次用到
#define TyInt32 Type::getInt32Ty(context)
#define DEBUG false

Function *func;
Value *Exp_val;
int stmt_num;
// vector<int> stmt_nums;


void CminusBuilder::visit(syntax_program &node)
{
    if (DEBUG) printf("program begin:\n");
    for (auto decl : node.declarations)
    {
        decl->accept(*this);
    }
    if (DEBUG) printf("program end:\n");
}

void CminusBuilder::visit(syntax_num &node)
{
    if (DEBUG) printf("num begin:\n");
    Exp_val = CONST(node.value);
    if (DEBUG) printf("num end:\n");
}

void CminusBuilder::visit(syntax_var_declaration &node)
{
    if (DEBUG) printf("var_declaration begin:\n");
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
    if (DEBUG) printf("var_declaration end:\n");
}

void CminusBuilder::visit(syntax_fun_declaration &node)
{
    if (DEBUG) printf("fun_declaration begin:\n");
    auto TyVoid = llvm::Type::getVoidTy(context);
    vector<Type *> Ints;
    std::vector<Value *> args2; //获取gcd函数的参数,通过iterator
    for (auto i : node.params)
    {
        if (i->isarray)
            Ints.push_back(builder.getInt32Ty()->getPointerTo());
        else
            Ints.push_back(TyInt32);
    }
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
    if (DEBUG) printf("fun_declaration end:\n");
}

void CminusBuilder::visit(syntax_param &node)
{
    if (DEBUG) printf("param begin:\n");
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
    if (DEBUG) printf("param end:\n");
}

void CminusBuilder::visit(syntax_compound_stmt &node)
{
    if (DEBUG) printf("compound_stmt begin:\n");
    // stmt_nums.push_back(0);
    scope.enter();
    for (auto delc : node.local_declarations)
    {
        delc->accept(*this);
    }
    for (auto stmt : node.statement_list)
    {
        stmt_num++;
        // *(stmt_nums.rbegin())++;
    }
    for (auto stmt : node.statement_list)
    {
        stmt_num--;
        // *(stmt_nums.rbegin())--;
        stmt->accept(*this);
    }
    scope.exit();
    // stmt_nums.pop_back();
    if (DEBUG) printf("compound_stmt end:\n");
}

void CminusBuilder::visit(syntax_expresion_stmt &node)
{
    if (DEBUG) printf("expresion_stmt begin:\n");
    if (node.expression != nullptr)
        node.expression->accept(*this);
    if (DEBUG) printf("expresion_stmt end:\n");
}

void CminusBuilder::visit(syntax_selection_stmt &node)
{
    if (DEBUG) printf("selection_stmt begin:\n");
    if (stmt_num > 0)
    {
        if (node.else_statement != nullptr)
        {
            auto trueBB = llvm::BasicBlock::Create(context, "trueBB", func);
            auto falseBB = llvm::BasicBlock::Create(context, "falseBB", func);
            auto endBB = llvm::BasicBlock::Create(context, "endBB", func);

            node.expression->accept(*this);
            auto icmp = builder.CreateICmpNE(Exp_val, CONST(0));
            auto br = builder.CreateCondBr(icmp, trueBB, falseBB);

            builder.SetInsertPoint(trueBB);
            node.if_statement->accept(*this);
            if (!trueBB->getTerminator())
                builder.CreateBr(endBB);

            builder.SetInsertPoint(falseBB);
            node.else_statement->accept(*this);
            if (!falseBB->getTerminator())
                builder.CreateBr(endBB);

            builder.SetInsertPoint(endBB);
        }
        else
        {
            // 无 else 语句
            auto trueBB = llvm::BasicBlock::Create(context, "trueBB", func);
            auto endBB = llvm::BasicBlock::Create(context, "endBB", func);

            node.expression->accept(*this);
            auto icmp = builder.CreateICmpNE(Exp_val, CONST(0));
            auto br = builder.CreateCondBr(icmp, trueBB, endBB);

            builder.SetInsertPoint(trueBB);
            node.if_statement->accept(*this);
            // if (!trueBB->getTerminator())
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
            auto icmp = builder.CreateICmpNE(Exp_val, CONST(0));
            auto br = builder.CreateCondBr(icmp, trueBB, falseBB);

            builder.SetInsertPoint(trueBB);
            node.if_statement->accept(*this);

            builder.SetInsertPoint(falseBB);
            node.else_statement->accept(*this);
        }
    }
    if (DEBUG) printf("selection_stmt end:\n");
}

void CminusBuilder::visit(syntax_iteration_stmt &node)
{
    if (DEBUG) printf("iteration_stmt beign:\n");
    auto jugBB = llvm::BasicBlock::Create(context, "jugBB", func);
    auto l_trueBB = llvm::BasicBlock::Create(context, "trueBB", func);
    auto l_falseBB = llvm::BasicBlock::Create(context, "falseBB", func);

    builder.CreateBr(jugBB);
    builder.SetInsertPoint(jugBB);
    node.expression->accept(*this);
    auto icmp = builder.CreateICmpNE(Exp_val, CONST(0));
    auto br = builder.CreateCondBr(icmp, l_trueBB, l_falseBB);

    builder.SetInsertPoint(l_trueBB);
    node.statement->accept(*this);
    // if (!l_trueBB->getTerminator())
        builder.CreateBr(jugBB);

    builder.SetInsertPoint(l_falseBB);

    if (DEBUG) printf("iteration_stmt end:\n");
}

void CminusBuilder::visit(syntax_return_stmt &node)
{
    if (DEBUG) printf("return_stmt begin:\n");
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
    if (DEBUG) printf("return_stmt end:\n");
}

void CminusBuilder::visit(syntax_var &node)
{
    // 取出变量的值
    if (DEBUG) std::cout<<"var begin"<<endl;
    llvm::Value *Var_addr = scope.find(node.id);
    if (node.expression != nullptr)
    {
        node.expression->accept(*this);
        auto icmp = builder.CreateICmpSGE(Exp_val, CONST(0));
        auto except = BasicBlock::Create(context, "except", func);
        auto normal = BasicBlock::Create(context, "normal", func);

        auto br = builder.CreateCondBr(icmp, normal, except);
        builder.SetInsertPoint(except);
        auto neg = scope.find("neg_idx_except");
        builder.CreateCall(neg);
        if (func->getFunctionType()->getReturnType()->isVoidTy())
            builder.CreateRetVoid();
        else
            builder.CreateRet(CONST(0));
        builder.SetInsertPoint(normal);
        if (Var_addr->getType()->getPointerElementType()->isArrayTy())
            // 判断是指向数组的指针（且不是形参），转换成指向对应元素的指针
            Var_addr = builder.CreateGEP(Var_addr, {CONST(0), Exp_val}, node.id);
        else
        {
            // 此时应该是数组形参，是指针的地址，这条语句的作用是取出指向首元素的指针
            Var_addr = builder.CreateLoad(Var_addr);
            // 这条语句的作用是根据首元素的指针找到偏移元素的地址
            Var_addr = builder.CreateGEP(Var_addr, Exp_val);
        }
    }

    if (Var_addr->getType()->getPointerElementType()->isArrayTy())
    {
        //判断是指向数组的指针，此时应该是实参
        Exp_val = Var_addr;
    }
    else
    {
        // 不是指向数组的指针，那么根据上面的处理，从对应地址中取出值
        Exp_val = builder.CreateLoad(Var_addr);
    }

    if (DEBUG) std::cout<<"var end"<<endl;
}

void CminusBuilder::visit(syntax_assign_expression &node)
{
    if (DEBUG) printf("assign_expression begin:\n");
    llvm::Value *Var_addr = scope.find(node.var->id);
    if (node.var->expression != nullptr)
    {
        node.var->expression->accept(*this);
        auto icmp = builder.CreateICmpSGE(Exp_val, CONST(0));
        auto except = BasicBlock::Create(context, "except", func);
        auto normal = BasicBlock::Create(context, "normal", func);

        auto br = builder.CreateCondBr(icmp, normal, except);
        builder.SetInsertPoint(except);
        auto neg = scope.find("neg_idx_except");
        builder.CreateCall(neg);
        if (func->getFunctionType()->getReturnType()->isVoidTy())
            builder.CreateRetVoid();
        else
            builder.CreateRet(CONST(0));
        builder.SetInsertPoint(normal);

        if (Var_addr->getType()->getPointerElementType()->isArrayTy())
            // 判断是指向数组的指针（且不是形参），转换成指向对应元素的指针
            Var_addr = builder.CreateGEP(Var_addr, {CONST(0), Exp_val});
        else
        {
            // 此时应该是数组形参，是指针的地址，这条语句的作用是取出指向首元素的指针
            Var_addr = builder.CreateLoad(Var_addr);
            // 这条语句的作用是根据首元素的指针找到偏移元素的地址
            Var_addr = builder.CreateGEP(Var_addr, Exp_val);
        }
    }

    //调用 var 得到地址后，直接使用。
    node.expression->accept(*this);

    builder.CreateStore(Exp_val, Var_addr);
    if (DEBUG) printf("assign_expression end:\n");
}

void CminusBuilder::visit(syntax_simple_expression &node)
{
    if (DEBUG) printf("simple_expression begin:\n");
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
            Exp_val = builder.CreateIntCast(Exp_val, Type::getInt32Ty(context), false);
        }
        else if (node.op == OP_LE)
        {
            Exp_val = builder.CreateICmpSLE(addiexpr1, addiexpr2);
            Exp_val = builder.CreateIntCast(Exp_val, Type::getInt32Ty(context), false);
        }
        else if (node.op == OP_GE)
        {
            Exp_val = builder.CreateICmpSGE(addiexpr1, addiexpr2);
            Exp_val = builder.CreateIntCast(Exp_val, Type::getInt32Ty(context), false);
        }
        else if (node.op == OP_GT)
        {
            Exp_val = builder.CreateICmpSGT(addiexpr1, addiexpr2);
            Exp_val = builder.CreateIntCast(Exp_val, Type::getInt32Ty(context), false);
        }
        else if (node.op == OP_EQ)
        {
            Exp_val = builder.CreateICmpEQ(addiexpr1, addiexpr2);
            Exp_val = builder.CreateIntCast(Exp_val, Type::getInt32Ty(context), false);
        }
        else if (node.op == OP_NEQ)
        {
            Exp_val = builder.CreateICmpNE(addiexpr1, addiexpr2);
            Exp_val = builder.CreateIntCast(Exp_val, Type::getInt32Ty(context), false);
        }
    }
    if (DEBUG) printf("simple_expression end:\n");
}

void CminusBuilder::visit(syntax_additive_expression &node)
{
    if (DEBUG) printf("additive_expression begin:\n");
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
    if (DEBUG) printf("additive_expression end:\n");
}

void CminusBuilder::visit(syntax_term &node)
{
    if (DEBUG) printf("term begin:\n");
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
    if (DEBUG) printf("term end:\n");
}

void CminusBuilder::visit(syntax_call &node)
{
    if (DEBUG) printf("call begin:\n");
    auto CalleeF = scope.find(node.id);
    vector<Value *> Argu;
    for (auto s = node.args.begin(); s != node.args.end(); s++)
    {
        (*s)->accept(*this);
        // 如果是数组类型，通过这条语句将指向数组的指针转换成指向数组首元素的指针，
        // 第一个CONST(0)意思是元素的首元素从零开始，第二个CONST(0)表示首元素。
        if (Exp_val->getType()->isPointerTy())
        {
            if (Exp_val->getType()->getPointerElementType()->isArrayTy())
                Exp_val = builder.CreateGEP(Exp_val, {CONST(0), CONST(0)});
        }
        Argu.push_back(Exp_val);
    }
    Exp_val = builder.CreateCall(CalleeF, Argu);
    if (DEBUG) printf("call end:\n");
}
