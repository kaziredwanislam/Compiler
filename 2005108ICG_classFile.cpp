#include "2005108.h"
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include<vector>
#include <algorithm>
#include <fstream>

using namespace std;

class ICG {
    SymbolInfo* rootpointer;
    SymbolTable st2;
    //FILE* outfile;
    public:
        int is_global=1;
        int is_function=0;
        int is_while_Loop=0;
        int other_func_variable=0;
        int pres_param=0;
        int is_other_func=0;
        int other_func_stackoffset=0;
        int curr_parameter_offset=2;
        int curr_label=0;
        int logicopprev=1;
        int is_for_loop=0;
        string curr_logicop="";
        int is_logicop=0;
        int is_If=0;
        int is_Loop_statement=0;
        int If_finish=0;
        int is_Loop=0;
        int is_Main=0;
        int pushFlag=0;
        int is_mulop=0;
        int is_addop=0;
        int arrayExpression=0;
        string curr_mulop="";
        string curr_func="";
        int curr_func_stackOffset=0;
        int assignopFlag=0;
        int assignboolflag=0;
        ofstream outfile;
        ICG()
        {
            outfile.open("Assembly.txt");
            //st2=new SymbolTable(10);
        }

        int finalCodeGenerator()
        {
           // cout<<"s"<<endl;
            ifstream infile;
            infile.open("Assembly.txt");
            ofstream finalfile;
            finalfile.open("FinalCode.txt");
            if(!infile)
            {
                cout<<"Can't open source file"<<endl;
                return 1;
            }
            //cout<<"Hello"<<endl;
            vector<string>content;
            string line;
            while(getline(infile,line))
            {
                content.push_back(line);
            }
            infile.close();
            int i;
            for(i=0;i<content.size()-1;i++)
            {
                if(content[i]=="PUSH AX"&&content[i+1]=="POP AX")
                {
                    i++;
                }
                else if(content[i]!="ADD AX, 0"&& content[i]!="MUL AX, 1")
                {
                    finalfile<<content[i]<<endl;
                }
            }
            finalfile<<content[i]<<endl;
            finalfile.close();
            outfile.close();
        }

        void assemblyCodeGenerator(SymbolInfo* r)
        {
            rootpointer=r;
            //outfile=f5;
            basicCodeSegment();
            codeTransformer(rootpointer);
        }

        void basicCodeSegment()
        {
            outfile<<".MODEL SMALL"<<endl;
            outfile<<".STACK 1000H"<<endl;
            outfile<<".Data"<<endl;
            outfile<<"\tnumber DB \"00000$\""<<endl;
        }

        void new_line_proc()
        {
            //cout<<"Yeahyeah"<<endl;
            outfile<<"new_line proc"<<endl;
            outfile<<"\tpush ax"<<endl;
            outfile<<"\tpush dx"<<endl;
            outfile<<"\tmov ah,2"<<endl;
            outfile<<"\tmov dl,0Dh"<<endl;
            outfile<<"\tint 21h"<<endl;
            outfile<<"\tmov ah,2"<<endl;
            outfile<<"\tmov dl,0Ah"<<endl;
            outfile<<"\tint 21h"<<endl;
            outfile<<"\tpop dx"<<endl;
            outfile<<"\tpop ax"<<endl;
            outfile<<"\tret"<<endl;
            outfile<<"new_line endp"<<endl;
        }

        void print_output_proc()
        {
            //<<"jjjjjjjjjjjjjjjj888777"<<endl;
            outfile<<"print_output proc"<<endl;
            outfile<<"\tpush ax"<<endl;
            outfile<<"\tpush bx"<<endl;
            outfile<<"\tpush cx"<<endl;
            outfile<<"\tpush dx"<<endl;
            outfile<<"\tpush si"<<endl;
            outfile<<"\tlea si,number"<<endl;
            outfile<<"\tmov bx,10"<<endl;
            outfile<<"\tadd si,4"<<endl;
            outfile<<"\tcmp ax,0"<<endl;
            outfile<<"\tjnge negate"<<endl;
            outfile<<"\tprint:"<<endl;
            outfile<<"\txor dx,dx"<<endl;
            outfile<<"\tdiv bx"<<endl;
            outfile<<"\tmov [si],dl"<<endl;
            outfile<<"\tadd [si],'0'"<<endl;
            outfile<<"\tdec si"<<endl;
            outfile<<"\tcmp ax,0"<<endl;
            outfile<<"\tjne print"<<endl;
            outfile<<"\tinc si"<<endl;
            outfile<<"\tlea dx,si"<<endl;
            outfile<<"\tmov ah,9"<<endl;
            outfile<<"\tint 21h"<<endl;
            outfile<<"\tpop si"<<endl;
            outfile<<"\tpop dx"<<endl;
            outfile<<"\tpop cx"<<endl;
            outfile<<"\tpop bx"<<endl;
            outfile<<"\tpop ax"<<endl;
            outfile<<"\tret"<<endl;
            outfile<<"\tnegate:"<<endl;
            outfile<<"\tpush ax"<<endl;
            outfile<<"\tmov ah,2"<<endl;
            outfile<<"\tmov dl,'-'"<<endl;
            outfile<<"\tint 21h"<<endl;
            outfile<<"\tpop ax"<<endl;
            outfile<<"\tneg ax"<<endl;
            outfile<<"\tjmp print"<<endl;
            outfile<<"print_output endp"<<endl;
        }

        void codeTransformer(SymbolInfo* ptr)
        {
            //cout<<ptr->get_Rules()<<"iiiii"<<endl;
            if(ptr->get_Rules()=="start : program")//1
            {
                //cout<<"start : program"<<endl;
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
                if(If_finish==1)
                {
                    curr_label++;
                    outfile<<"L"<<curr_label<<":"<<endl;
                    If_finish=0;
                }
                finalCodeGenerator();
            }
            else if(ptr->get_Rules()=="program : program unit")//2
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
                
            }

            else if(ptr->get_Rules()=="program : unit")//3
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
                if(If_finish==1)
                {
                    curr_label++;
                    outfile<<"L"<<curr_label<<":"<<endl;
                    If_finish=0;
                }
            }

            else if(ptr->get_Rules()=="unit : var_declaration")//4
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="unit : func_declaration")//5
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="unit : func_definition")//6
            {

                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON")//7
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON")//8
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement")//9
            {
                curr_parameter_offset=2;
                st2.Enter_Scope();
                is_function=1;
                pres_param=0;
                if(ptr->children[0]->Name!="main")
                {
                    is_other_func=1;
                    other_func_variable=0;
                    other_func_stackoffset=0;
                }
                if(is_global==1)
                {
                    outfile<<".CODE"<<endl;
                    is_global=0;
                }
                string func_name=ptr->children[1]->Name;
                curr_func=func_name;
                if(func_name=="main")is_Main=1;
                outfile<<func_name<<" PROC"<<endl;
                outfile<<"\tPUSH BP"<<endl;
                outfile<<"\tMOV BP, SP"<<endl;
                curr_label++;
                outfile<<"L"<<curr_label<<":"<<endl;
                codeTransformer(ptr->children[0]);
                codeTransformer(ptr->children[1]);
                codeTransformer(ptr->children[2]);
                codeTransformer(ptr->children[3]);
                codeTransformer(ptr->children[4]);
                codeTransformer(ptr->children[5]);
                is_other_func=0;
                other_func_variable=0;
                other_func_stackoffset=0;
                pushFlag=0;
            }

            else if(ptr->get_Rules()=="func_definition : type_specifier ID LPAREN RPAREN compound_statement")//10
            {
                curr_parameter_offset=2;
                st2.Enter_Scope();
                is_function=1;
                pres_param=0;
                if(ptr->children[0]->Name!="main")
                {
                    is_other_func=1;
                    other_func_variable=0;
                    other_func_stackoffset=0;
                }
                if(is_global==1)
                {
                    outfile<<".CODE"<<endl;
                    is_global=0;
                }
                string func_name=ptr->children[1]->Name;
                curr_func=func_name;
                if(func_name=="main")is_Main=1;
                outfile<<func_name<<" PROC"<<endl;
                if(is_Main==1)
                {
                    outfile<<"\tMOV AX, @DATA"<<endl;
	                outfile<<"\tMOV DS, AX"<<endl;
                }
                outfile<<"\t"<<"PUSH BP"<<endl;
                outfile<<"\t"<<"MOV BP, SP"<<endl;
                curr_label++;
                outfile<<"L"<<curr_label<<":"<<endl;
                codeTransformer(ptr->children[0]);
                codeTransformer(ptr->children[1]);
                codeTransformer(ptr->children[2]);
                codeTransformer(ptr->children[3]);
                codeTransformer(ptr->children[4]);
                is_other_func=0;
                other_func_variable=0;
                other_func_stackoffset=0;
                pushFlag=0;
            }

            else if(ptr->get_Rules()=="parameter_list  : parameter_list COMMA type_specifier ID")//11
            {

                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
                curr_parameter_offset+=2;
                int x=-(curr_parameter_offset);
                
                st2.insertsp(ptr->children[3]->Name,ptr->children[3]->Type,x);
                pres_param++;
            }

            else if(ptr->get_Rules()=="parameter_list  : parameter_list COMMA type_specifier")//12
            {
  
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
                
            }

            else if(ptr->get_Rules()=="parameter_list  : type_specifier ID")//13
            {

                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
                curr_parameter_offset+=2;
                int x=-(curr_parameter_offset);
                cout<<ptr->children[1]->Name<<" jj"<<endl;
                st2.insertsp(ptr->children[1]->Name,ptr->children[1]->Type,x);
                pres_param++;
            }

            else if(ptr->get_Rules()=="parameter_list  : type_specifier")//14
            {

                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="compound_statement  : LCURL statements RCURL")//15
            {
 
                codeTransformer(ptr->children[0]);
                codeTransformer(ptr->children[1]);
                if(is_function==1&&is_If==0 &&is_Loop==0 &&is_Loop_statement==0)
                {
                    curr_label++;
                    outfile<<"L"<<curr_label<<":"<<endl;
                    if(is_other_func==0)
                        outfile<<"\tADD SP, "<<curr_func_stackOffset<<endl;
                    else
                        outfile<<"\tADD SP, "<<other_func_stackoffset<<endl;
                    outfile<<"\tPOP BP"<<endl;
                    outfile<<"                                     ;Line: "<<ptr->children[0]->startLine<<endl;
                    if(is_Main!=1)
                    {
                        outfile<<"\tRET "<<pres_param*2<<endl;
                    }
                    if(is_Main==1)
                    {
                        outfile<<"	MOV AX,4CH "<<endl;
                        outfile<<"INT 21H"<<endl;
                    }
                    outfile<<curr_func<<" ENDP"<<endl;
                    if(curr_func=="main"){
                        outfile<<";---------------------------------------------"<<endl;
                        outfile<<";               Print Library                 "<<endl;
                        outfile<<";----------------------------------------------"<<endl;
                        new_line_proc();
                        print_output_proc();
                        outfile<<"END main"<<endl;
                    }
                    is_function=0;
                    curr_func="";
                    curr_func_stackOffset=0;
                    st2.ExitScope();
                    is_other_func=0;
                    other_func_variable=0;
                    other_func_stackoffset=0;
                    pres_param=0;
                    curr_parameter_offset=2;
                }

                codeTransformer(ptr->children[2]);
                if(is_Loop_statement==1)
                {
                    outfile<<"\tJMP L"<<curr_label-1<<endl;
                    
                    is_Loop=0;
                    is_Loop_statement=0;
                }
            }

            else if(ptr->get_Rules()=="compound_statement : LCURL RCURL")//16
            {

                codeTransformer(ptr->children[0]);
                if(is_function==1 &&is_If==0 &&is_Loop==0 && is_Loop_statement==0)
                {
                    curr_label++;
                    outfile<<"L"<<curr_label<<":"<<endl;
                    outfile<<"\tPOP BP"<<endl;
                    if(is_Main!=1)
                    {
                        outfile<<"\tRET"<<endl;
                    }
                    if(is_Main==1)
                    {
                        outfile<<"	MOV AX,4CH "<<endl;
                        outfile<<"INT 21H"<<endl;
                    }
                    outfile<<curr_func<<" ENDP"<<endl;
                    if(curr_func=="main"){
                        outfile<<";---------------------------------------------"<<endl;
                        outfile<<";               Print Library                 "<<endl;
                        outfile<<";----------------------------------------------"<<endl;
                        new_line_proc();
                        print_output_proc();
                        outfile<<"END main"<<endl;
                    }
                    is_function=0;
                    curr_func="";
                    curr_func_stackOffset=0;
                    st2.ExitScope();
                    is_other_func=0;
                    other_func_variable=0;
                    other_func_stackoffset=0;
                    curr_parameter_offset=2;
                }

                if(is_Loop_statement==1)
                {
                    outfile<<"\tJMP L"<<curr_label-1<<endl;
                    
                    is_Loop=0;
                    is_Loop_statement=0;
                }

                codeTransformer(ptr->children[1]);
            }

            else if(ptr->get_Rules()=="var_declaration : type_specifier declaration_list SEMICOLON")//17
            {
     
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="type_specifier : INT")//18
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="type_specifier : FLOAT")//19
            {

                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="type_specifier : VOID")//20
            {
 
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="declaration_list : declaration_list COMMA ID")//21
            {

                codeTransformer(ptr->children[0]);
                codeTransformer(ptr->children[1]);
                //codeTransformer(ptr->children[2]);
                if(is_global==1)
                {
                    outfile<<"\t"<<ptr->children[2]->Name<<" DW 1 DUP (0000H)"<<endl;
                }
                else if(is_function==1&&is_other_func==0)
                {
                    curr_func_stackOffset+=2;
                    //cout<<ptr->children[2]->Name<<" pppp"<<endl<<endl;
                    st2.insertsp(ptr->children[2]->Name,ptr->children[2]->Type,curr_func_stackOffset);
                    ptr->children[2]->stackOffset=curr_func_stackOffset;
                    outfile<<"\tSUB SP, 2"<<endl;
                }
                else if(is_function==1&&is_other_func==1)
                {
                    other_func_stackoffset+=2;
                    //cout<<ptr->children[2]->Name<<" pppp"<<endl<<endl;
                    st2.insertsp(ptr->children[2]->Name,ptr->children[2]->Type,other_func_stackoffset);
                    ptr->children[2]->stackOffset=other_func_stackoffset;
                    outfile<<"\tSUB SP, 2"<<endl;
                }
                codeTransformer(ptr->children[2]);
            }

            else if(ptr->get_Rules()=="declaration_list :  declaration_list COMMA ID LSQUARE CONST_INT RSQUARE")//22
            {
                codeTransformer(ptr->children[0]);
                codeTransformer(ptr->children[1]);
                codeTransformer(ptr->children[2]);
                codeTransformer(ptr->children[3]);
                codeTransformer(ptr->children[4]);
                codeTransformer(ptr->children[5]);
                if(is_function==1 && is_other_func==0)
                {
                    curr_func_stackOffset+=2;//stoi(ptr->children[4]->Name)*
                    st2.insertsp(ptr->children[2]->Name,ptr->children[2]->Type,curr_func_stackOffset);
                    curr_func_stackOffset=curr_func_stackOffset-2+stoi(ptr->children[4]->Name)*2;
                    //ptr->children[2]->stackOffset=curr_func_stackOffset;
                    outfile<<"\tSUB SP, "<<stoi(ptr->children[4]->Name)*2<<endl;
                }

                if(is_function==1 && is_other_func==1)
                {
                    other_func_stackoffset+=2;//stoi(ptr->children[4]->Name)*
                    st2.insertsp(ptr->children[2]->Name,ptr->children[2]->Type,other_func_stackoffset);
                    other_func_stackoffset=other_func_stackoffset-2+stoi(ptr->children[4]->Name)*2;
                    //ptr->children[2]->stackOffset=curr_func_stackOffset;
                    outfile<<"\tSUB SP, "<<stoi(ptr->children[4]->Name)*2<<endl;
                }
                
            }

            /*else if(ptr->get_Rules()=="declaration_list :  declaration_list COMMA ID LSQUARE CONST_INT RSQUARE")//23
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }*/

            else if(ptr->get_Rules()=="declaration_list  : ID LSQUARE CONST_INT RSQUARE")//24
            {
                codeTransformer(ptr->children[0]);
                codeTransformer(ptr->children[1]);
                codeTransformer(ptr->children[2]);
                codeTransformer(ptr->children[3]);
                if(is_function==1 && is_other_func==0)
                {
                    curr_func_stackOffset+=2;//stoi(ptr->children[2]->Name)*
                    st2.insertsp(ptr->children[0]->Name,ptr->children[0]->Type,curr_func_stackOffset);
                    ptr->children[0]->stackOffset=curr_func_stackOffset;
                    curr_func_stackOffset=curr_func_stackOffset-2+stoi(ptr->children[2]->Name)*2;
                    outfile<<"\tSUB SP, "<<stoi(ptr->children[2]->Name)*2<<endl;
                }
                else if(is_function==1 && is_other_func==1)
                {
                    other_func_stackoffset+=2;//stoi(ptr->children[2]->Name)*
                    st2.insertsp(ptr->children[0]->Name,ptr->children[0]->Type,other_func_stackoffset);
                    ptr->children[0]->stackOffset=other_func_stackoffset;
                    other_func_stackoffset=other_func_stackoffset-2+stoi(ptr->children[2]->Name)*2;
                    outfile<<"\tSUB SP, "<<stoi(ptr->children[2]->Name)*2<<endl;
                }
            }

            else if(ptr->get_Rules()=="declaration_list : ID")//24
            {
                //codeTransformer(ptr->children[0]);
                
                if(is_global==1)
                {
                    outfile<<"\t"<<ptr->children[0]->Name<<" DW 1 DUP (0000H)"<<endl;
                    
                }

                else if(is_function==1 && is_other_func==0)
                {
                    curr_func_stackOffset+=2;
                    ptr->children[0]->stackOffset=curr_func_stackOffset;
                    //cout<<ptr->children[0]->Name<<" hhhhhhh"<<endl<<endl;
                    st2.insertsp(ptr->children[0]->Name,ptr->children[0]->Type,curr_func_stackOffset);
                    //cout<<ptr->children[0]->Name<<" heheheheh "<<ptr->children[0]->stackOffset<<endl;
                    outfile<<"\tSUB SP, 2"<<endl;
                }
                else if(is_function==1 && is_other_func==1)
                {
                    other_func_stackoffset+=2;
                    ptr->children[0]->stackOffset=other_func_stackoffset;
                    //cout<<ptr->children[0]->Name<<" hhhhhhh"<<endl<<endl;
                    st2.insertsp(ptr->children[0]->Name,ptr->children[0]->Type,other_func_stackoffset);
                    //cout<<ptr->children[0]->Name<<" heheheheh "<<ptr->children[0]->stackOffset<<endl;
                    outfile<<"\tSUB SP, 2"<<endl;
                }
                codeTransformer(ptr->children[0]);
            }

            else if(ptr->get_Rules()=="statements : statement")//25
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="statements:  statements statement")//26
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="statement : var_declaration")//27
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="statement : expression_statement")//28
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="statement :  compound_statement")//29
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="statement :  FOR LPAREN expression_statement expression_statement expression RPAREN statement")//30
            {
                is_for_loop=1;
                is_If=1;
                is_Loop=1;
                is_Loop_statement=1;
                codeTransformer(ptr->children[0]);
                codeTransformer(ptr->children[1]);
                codeTransformer(ptr->children[2]);
                curr_label++;
                outfile<<"L"<<curr_label<<":"<<endl;
                codeTransformer(ptr->children[3]);
                 curr_label++;
                outfile<<"L"<<curr_label<<":"<<endl;
                outfile<<"                                     ;Line: "<<ptr->children[0]->startLine<<endl;
                codeTransformer(ptr->children[4]);
                codeTransformer(ptr->children[5]);
                codeTransformer(ptr->children[6]);
                is_Loop=0;
                is_If=0;
                is_for_loop=0;
               
               // codeTransformer(ptr->children[6]);
            }

            else if(ptr->get_Rules()=="statement :  IF LPAREN expression RPAREN statement")//31
            {
                is_If=1;
                codeTransformer(ptr->children[0]);
                codeTransformer(ptr->children[1]);
                curr_label++;
                outfile<<"L"<<curr_label<<":"<<endl;
                codeTransformer(ptr->children[2]);
             outfile<<"                                     ;Line: "<<ptr->children[0]->startLine<<endl;
                codeTransformer(ptr->children[3]);
                curr_label++;
                outfile<<"L"<<curr_label<<":"<<endl;
                codeTransformer(ptr->children[4]);
                is_If=0;
                
            }

            else if(ptr->get_Rules()=="statement : WHILE LPAREN expression RPAREN statement")//32
            {
                is_If=1;
                is_while_Loop=1;
                is_Loop=1;
                is_Loop_statement=1;
                codeTransformer(ptr->children[0]);
                codeTransformer(ptr->children[1]);
                curr_label++;
                outfile<<"L"<<curr_label<<":"<<endl;
                codeTransformer(ptr->children[2]);
                codeTransformer(ptr->children[3]);
                outfile<<"                                     ;Line: "<<ptr->children[0]->startLine<<endl;
                is_If=0;
                curr_label++;
                outfile<<"L"<<curr_label<<":"<<endl;
                is_Loop=0;
                codeTransformer(ptr->children[4]);
                is_while_Loop=1;
               //is_Loop=0;
                //outfile<<"JMP L"<<curr_label-1<<"mmmmmmmmmmmmmmmmmmmmm"<<endl;
            }

            else if(ptr->get_Rules()=="statement : PRINTLN LPAREN ID RPAREN SEMICOLON")//33
            {
                codeTransformer(ptr->children[0]);
                codeTransformer(ptr->children[1]);
                codeTransformer(ptr->children[2]);
                codeTransformer(ptr->children[3]);
                codeTransformer(ptr->children[4]);
                if(is_Loop==0 && is_while_Loop==0)
                {
                    curr_label++;
                    outfile<<"L"<<curr_label<<":"<<endl;
                }
      
                SymbolInfo* si=st2.Look_up(ptr->children[2]->Name);
                if(si!=NULL)
                {
                    int so=si->stackOffset;
                    if(si->is_array==1)so=so+si->arrayIndex;
                    if(so>=0)
                    {
                        outfile<<"\tMOV AX, [BP-"<<so<<"]"<<endl;
                    }
                    else
                    {
                        so*=(-1);
                        outfile<<"\tMOV AX, [BP+"<<so<<"]"<<endl;
                    }
                    outfile<<"\tCALL print_output"<<endl;
                    outfile<<"\tCALL new_line"<<endl;
                }
                else
                {
                    outfile<<"\tMOV AX, "<<ptr->children[2]->Name<<endl;
                    outfile<<"\tCALL print_output"<<endl;
                    outfile<<"\tCALL new_line"<<endl;
                }
             
            }

            else if(ptr->get_Rules()=="statement :  IF LPAREN expression RPAREN statement ELSE statement")//34
            {
                is_If=1;
                codeTransformer(ptr->children[0]);
                codeTransformer(ptr->children[1]);
                curr_label++;
                outfile<<"L"<<curr_label<<":"<<endl;
                codeTransformer(ptr->children[2]);
                outfile<<"                                     ;Line: "<<ptr->children[0]->startLine<<endl;
             
                codeTransformer(ptr->children[3]);
                curr_label++;
                outfile<<"L"<<curr_label<<":"<<endl;
                codeTransformer(ptr->children[4]);
                
                outfile<<"\tJMP L"<<curr_label+2<<endl;
                codeTransformer(ptr->children[5]);
                curr_label++;
                outfile<<"L"<<curr_label<<":"<<endl;
                
                codeTransformer(ptr->children[6]);
                //curr_label++;
                is_If=0;
            }

            else if(ptr->get_Rules()=="statement : RETURN expression SEMICOLON")//35
            {
                codeTransformer(ptr->children[0]);
                 codeTransformer(ptr->children[1]);
                SymbolInfo* si=st2.Look_up(ptr->children[1]->Name);
                if(si!=NULL)
                {
                    int so=si->stackOffset;
                    cout<<"so"<<so<<" "<<si->Name<<endl;
                    outfile<<"                                     ;Line: "<<ptr->children[0]->startLine<<endl;
                    if(so>=0)
                    {
                        outfile<<"\tMOV AX,  [BP-"<<so<<"]"<<endl;
                    }
                    else
                    {
                        so*=(-1);
                        outfile<<"\tMOV AX,  [BP+"<<so<<"]"<<endl;
                        //outfile<<"\tPUSH AX"<<endl;
                    }
                    
                }
                else
                {
                    if(ptr->children[1]->Name!="NULL")
                        outfile<<"\tMOV AX,  "<<ptr->children[1]->Name<<endl;
                    //outfile<<"\tPUSH AX"<<endl;
                }
                if(pushFlag==1)
                {
                    outfile<<"\tPOP AX"<<endl;
                }
               
                codeTransformer(ptr->children[2]);
                //outfile<<"\tRET DX"<<endl;
            }

            else if(ptr->get_Rules()=="expression_statement 	: SEMICOLON")//36
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="expression_statement 	: expression SEMICOLON")//37
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="variable : ID")//38
            {

                //cout<<ptr->children[0]->Name<<" hahahahah "<<ptr->children[0]->stackOffset<<endl;
                codeTransformer(ptr->children[0]);
            }

            else if(ptr->get_Rules()=="variable : ID LSQUARE expression RSQUARE")//39
            {
                SymbolInfo* si=st2.Look_up(ptr->children[0]->Name);
                if(si!=NULL)
                {
                        si->is_array=1;
                        si->arrayIndex=stoi(ptr->children[2]->Name);
                        
                }
                arrayExpression=1;
                codeTransformer(ptr->children[0]);
                codeTransformer(ptr->children[1]);
                codeTransformer(ptr->children[2]);
                codeTransformer(ptr->children[3]);
                arrayExpression=0;
            }

            else if(ptr->get_Rules()=="expression : logic_expression")//40
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="expression : variable ASSIGNOP logic_expression")//41
            {  
                assignopFlag=1;
                codeTransformer(ptr->children[0]);
                codeTransformer(ptr->children[1]);
                codeTransformer(ptr->children[2]);
                if(assignboolflag==0)
                {
                           SymbolInfo* si=st2.Look_up(ptr->children[0]->Name);
                           //cout<<si->Name<<"  kkkkkkkkkkkkkkkkkkkkkkkkkkk  "<<endl;
                    int so;
                    int so2;
                    if(si!=NULL)
                    {
                        so=si->stackOffset;
                        if(si->is_array==1)
                        {
                            so=so+si->arrayIndex*2;
                        }
                    }
                        
                    SymbolInfo* si2=st2.Look_up(ptr->children[2]->Name);
                    if(si2!=NULL)
                    {
                        so2=si2->stackOffset;
                        if(si2->is_array)
                        {
                            so2=so2+si2->arrayIndex*2;
                        }
                    }

                    //codeTransformer(ptr->children[1]);
                    if(si2==NULL)
                    {
                        if(ptr->children[2]->Name!="NULL")
                            outfile<<"\tMOV AX, "<<ptr->children[2]->Name<<endl;
                        //cout<<"\tMOV AX,  mmmm "<<ptr->children[2]->Name<<endl;
                    }
                    else
                    {
                        if(so2>=0)
                            outfile<<"\tMOV AX, [BP-"<<so2<<"]"<<endl;
                        else
                        {
                            so2*=(-1);
                            outfile<<"\tMOV AX, [BP+"<<so2<<"]"<<endl;
                        }
                            
                    }
              
                    //codeTransformer(ptr->children[2]);
                    
                    if(pushFlag==1)
                        {
                            outfile<<"\tPOP AX"<<endl;
                            pushFlag=0;
                        }
                    if(si==NULL)
                    {
                        outfile<<"\tMOV "<<ptr->children[0]->Name<<" ,AX"<<endl;
                    }
                        
                    if(si!=NULL)
                    {
                        if(so>=0)
                            outfile<<"\tMOV [BP-"<<so<<"], AX "<<endl;
                        else 
                        {
                            so*=(-1);
                            outfile<<"\tMOV [BP+"<<so<<"], AX "<<endl;
                        }
                    }
                        
                }
                else
                {
                    SymbolInfo* sii=st2.Look_up(ptr->children[0]->Name);
                    if(sii!=NULL)
                    {
                        int soo=sii->stackOffset;
                        outfile<<"\tPOP AX"<<endl;
                        if(soo>=0)
                            outfile<<"\tMOV [BP-"<<soo<<"], AX"<<endl;
                        else
                        {
                            soo*=(-1);
                            outfile<<"\tMOV [BP+"<<soo<<"], AX"<<endl;
                        }
                            
                    }
                    assignboolflag=0;
                }
         
                is_addop=0;
                is_mulop=0;
                assignopFlag=0;
                assignboolflag=0;
            }

            else if(ptr->get_Rules()=="logic_expression : rel_expression")//42
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="logic_expression : rel_expression LOGICOP rel_expression")//43
            {
                if(assignopFlag==0)
                {
                    curr_logicop=ptr->children[1]->Name;
                    is_logicop=1;
                    logicopprev=1;
                    //outfile<<"jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj"<<endl;
                    codeTransformer(ptr->children[0]);
                    codeTransformer(ptr->children[1]);
                    curr_label++;
                    outfile<<"L"<<curr_label<<": "<<endl;
                    logicopprev=0;
                    codeTransformer(ptr->children[2]);
                    curr_logicop="";
                    is_logicop=0;
                }
                else
                {
                    assignboolflag=1;
                    codeTransformer(ptr->children[0]);
                    codeTransformer(ptr->children[1]);
                    codeTransformer(ptr->children[2]);
                    if(ptr->children[1]->Name=="&&")
                    {
                        SymbolInfo* sii1=st2.Look_up(ptr->children[0]->Name);
                        SymbolInfo* sii2=st2.Look_up(ptr->children[1]->Name);
                        if(sii1!=NULL)
                        {
                            int soo1=sii1->stackOffset;
                            if(soo1>=0)
                            {
                                outfile<<"\tMOV AX,[BP-"<<soo1<<"]"<<endl;
                            }
                            else
                            {
                                soo1*=(-1);
                                outfile<<"\tMOV AX,[BP+"<<soo1<<"]"<<endl;
                            }
                        }
                        else
                        {
                            outfile<<"\tMOV AX, "<<ptr->children[0]->Name<<endl;
                        }
                        if(sii2!=NULL)
                        {
                            int soo2=sii2->stackOffset;
                            if(soo2>=0)
                            {
                                outfile<<"\tMOV BX,[BP-"<<soo2<<"]"<<endl;
                            }
                            else
                            {
                                soo2*=(-1);
                                outfile<<"\tMOV BX,[BP+"<<soo2<<"]"<<endl;
                            }
                        }
                        else
                        {
                            outfile<<"\tMOV BX, "<<ptr->children[2]->Name<<endl;
                        }
                        outfile<<"\tAND AX,BX"<<endl;
                    }
                    else if(ptr->children[1]->Name=="||")
                    {
                        SymbolInfo* sii1=st2.Look_up(ptr->children[0]->Name);
                        SymbolInfo* sii2=st2.Look_up(ptr->children[2]->Name);
                        if(sii1!=NULL)
                        {
                            int soo1=sii1->stackOffset;
                            if(soo1>=0)
                            {
                                outfile<<"\tMOV AX,[BP-"<<soo1<<"]"<<endl;
                            }
                            else
                            {
                                soo1*=(-1);
                                outfile<<"\tMOV AX,[BP+"<<soo1<<"]"<<endl;
                            }
                            
                        }
                        else
                        {
                            outfile<<"\tMOV AX, "<<ptr->children[0]->Name<<endl;
                        }
                        if(sii2!=NULL)
                        {
                            int soo2=sii2->stackOffset;
                            if(soo2>=0)
                            {
                                outfile<<"\tMOV BX,[BP-"<<soo2<<"]"<<endl;
                            }
                            else
                            {
                                soo2*=(-1);
                                outfile<<"\tMOV BX,[BP+"<<soo2<<"]"<<endl;
                            }
                        }
                        else
                        {
                            outfile<<"\tMOV BX, "<<ptr->children[2]->Name<<endl;
                        }
                        outfile<<"\tOR AX,BX"<<endl;
                    }
                    outfile<<"\tPUSH AX"<<endl;
                }
             
            }

            else if(ptr->get_Rules()=="rel_expression	: simple_expression")//44
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
                //cout<<ptr->children[0]->Name<<"kkkkk"<<endl;
                SymbolInfo* si=st2.Look_up(ptr->children[0]->Name);
                if(si!=NULL &&is_Loop==1&&is_for_loop==0)
                {
                    int so=si->stackOffset;
                    //outfile<<"\tMOV [BP-"<<so<<"], AX        hhhhhhhhhh"<<endl;
                    outfile<<"\tPOP AX"<<endl;
                    outfile<<"\tCMP AX,0"<<endl;
                    outfile<<"\tJNE L"<<curr_label+1<<endl;
                    outfile<<"\tJMP L"<<curr_label+2<<endl;
                    //cout<<"hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh"<<endl;
                }
      
            }

            
            else if(ptr->get_Rules()=="rel_expression	: simple_expression RELOP simple_expression")//45
            {
                
                codeTransformer(ptr->children[0]);
                codeTransformer(ptr->children[1]);
                codeTransformer(ptr->children[2]);
                
                string curr_relop=ptr->children[1]->Name;
                if(is_If==1 &&is_logicop==0 &&is_Loop==0 )
                {
                    SymbolInfo* si1=st2.Look_up(ptr->children[2]->Name);
                    if(si1==NULL)
                    {
                        outfile<<"\tMOV AX, "<<ptr->children[2]->Name<<endl;
                        outfile<<"\tMOV DX, AX"<<endl;
                    }
                    else
                    {
                        int so=si1->stackOffset;
                        if(so>=0)
                        {
                            outfile<<"\tMOV AX , [BP-"<<so<<"]"<<endl;
                        }
                        else
                        {
                            so*=(-1);
                            outfile<<"\tMOV AX, [BP+"<<so<<"]"<<endl;
                        }
                        
                        outfile<<"\tMOV DX, AX"<<endl;
                    }
                    SymbolInfo* si2=st2.Look_up(ptr->children[0]->Name);
                    if(si2==NULL)
                    {
                        outfile<<"\tMOV AX, "<<ptr->children[0]->Name<<endl;
                        outfile<<"\tCMP AX,DX"<<endl;
                        if(curr_relop=="<")
                            outfile<<"\tJL L"<<curr_label+1<<endl;
                        else if(curr_relop==">")
                            outfile<<"\tJG L"<<curr_label+1<<endl;
                        else if(curr_relop==">=")
                            outfile<<"\tJGE L"<<curr_label+1<<endl;
                        else if(curr_relop=="<=")
                            outfile<<"\tJLE L"<<curr_label+1<<endl;
                        else if(curr_relop=="==")
                            outfile<<"\tJE L"<<curr_label+1<<endl;
                        else if(curr_relop=="!=")
                            outfile<<"\tJNE L"<<curr_label+1<<endl;
                        outfile<<"\tJMP L"<<curr_label+2<<endl;
                    }
                    else
                    {
                        int so=si2->stackOffset;
                        if(so>=0)
                        {
                            outfile<<"\tMOV AX, [BP-"<<so<<"]"<<endl;
                        }
                        else
                        {
                            so*=(-1);
                            outfile<<"\tMOV AX, [BP+"<<so<<"]"<<endl;
                        }
                        outfile<<"\tCMP AX,DX"<<endl;
                        if(curr_relop=="<")
                            outfile<<"\tJL L"<<curr_label+1<<endl;
                        else if(curr_relop==">")
                            outfile<<"\tJG L"<<curr_label+1<<endl;
                        else if(curr_relop==">=")
                            outfile<<"\tJGE L"<<curr_label+1<<endl;
                        else if(curr_relop=="<=")
                            outfile<<"\tJLE L"<<curr_label+1<<endl;
                        else if(curr_relop=="==")
                            outfile<<"\tJE L"<<curr_label+1<<endl;
                        else if(curr_relop=="!=")
                            outfile<<"\tJNE L"<<curr_label+1<<endl;
                        outfile<<"\tJMP L"<<curr_label+2<<endl;
                    }
                }


                else if(is_If==1 && is_logicop==1 &&is_Loop==0 )
                {
                    SymbolInfo* si1=st2.Look_up(ptr->children[2]->Name);
                    int L,R;
                    if(curr_logicop=="&&" &&logicopprev==1){
                        L=1;
                        R=3;
                    }
                    else if(curr_logicop=="&&" && logicopprev==0)
                    {
                        L=1;
                        R=2;
                        logicopprev=1;
                    }
                    if(curr_logicop=="||"&&logicopprev==1){
                        L=2;
                        R=1;
                    }
                    else if(curr_logicop=="||"&&logicopprev==0)
                    {
                        L=1;
                        R=2;
                        logicopprev=1;
                    }
                    if(si1==NULL)
                    {
                        outfile<<"\tMOV AX, "<<ptr->children[2]->Name<<endl;
                        outfile<<"\tMOV DX, AX"<<endl;
                    }
                    else
                    {
                        int so=si1->stackOffset;
                        if(so>=0)
                        {
                            outfile<<"\tMOV AX, [BP-"<<so<<"]"<<endl;
                        }
                        else
                        {
                            so*=(-1);
                            outfile<<"\tMOV AX, [BP+"<<so<<"]"<<endl;
                        }
                        outfile<<"\tMOV DX, AX"<<endl;
                    }
                    SymbolInfo* si2=st2.Look_up(ptr->children[0]->Name);
                    if(si2==NULL)
                    {
                        outfile<<"\tMOV AX, "<<ptr->children[0]->Name<<endl;
                        outfile<<"\tCMP AX,DX"<<endl;
                        if(curr_relop=="<")
                            outfile<<"\tJL L"<<curr_label+L<<endl;
                        else if(curr_relop==">")
                            outfile<<"\tJG L"<<curr_label+L<<endl;
                        else if(curr_relop==">=")
                            outfile<<"\tJGE L"<<curr_label+L<<endl;
                        else if(curr_relop=="<=")
                            outfile<<"\tJLE L"<<curr_label+L<<endl;
                        else if(curr_relop=="==")
                            outfile<<"\tJE L"<<curr_label+L<<endl;
                        else if(curr_relop=="!=")
                            outfile<<"\tJNE L"<<curr_label+L<<endl;
                        outfile<<"\tJMP L"<<curr_label+R<<endl;
                    }
                    else
                    {
                        int so=si2->stackOffset;
                        if(so>=0)
                        {
                            outfile<<"\tMOV AX, [BP-"<<so<<"]"<<endl;
                        }
                        else
                        {
                            so*=(-1);
                            outfile<<"\tMOV AX, [BP+"<<so<<"]"<<endl;
                        }
                        outfile<<"\tCMP AX,DX"<<endl;
                        if(curr_relop=="<")
                            outfile<<"\tJL L"<<curr_label+L<<endl;
                        else if(curr_relop==">")
                            outfile<<"\tJG L"<<curr_label+L<<endl;
                        else if(curr_relop==">=")
                            outfile<<"\tJGE L"<<curr_label+L<<endl;
                        else if(curr_relop=="<=")
                            outfile<<"\tJLE L"<<curr_label+L<<endl;
                        else if(curr_relop=="==")
                            outfile<<"\tJE L"<<curr_label+L<<endl;
                        else if(curr_relop=="!=")
                            outfile<<"\tJNE L"<<curr_label+L<<endl;
                        outfile<<"\tJMP L"<<curr_label+R<<endl;
                    }
                }

                else if(is_Loop==1 )
                {
                    //outfile<<"jjjj"<<endl;
                    SymbolInfo* si1=st2.Look_up(ptr->children[0]->Name);
                    SymbolInfo* si2=st2.Look_up(ptr->children[2]->Name);
                    if(si1!=NULL && si2==NULL)
                    {
                        string s=ptr->children[2]->Name;
                        int so=si1->stackOffset;
                        outfile<<"\tPOP AX "<<endl;
                        outfile<<"\tCMP AX, "<<s<<endl;
                         if(curr_relop=="<")
                            outfile<<"\tJL L"<<curr_label+1<<endl;
                        else if(curr_relop==">")
                            outfile<<"\tJG L"<<curr_label+1<<endl;
                        else if(curr_relop==">=")
                            outfile<<"\tJGE L"<<curr_label+1<<endl;
                        else if(curr_relop=="<=")
                            outfile<<"\tJLE L"<<curr_label+1<<endl;
                        else if(curr_relop=="==")
                            outfile<<"\tJE L"<<curr_label+1<<endl;
                        else if(curr_relop=="!=")
                            outfile<<"\tJNE L"<<curr_label+1<<endl;
                        
                        outfile<<"\tJMP L"<<curr_label+2<<endl;
                    }
                }

                
            }

            else if(ptr->get_Rules()=="simple_expression : term")//46
            {
                //cout<<ptr->children[0]->Name<<"kkkkjjjjjjj"<<endl<<endl;
                if(is_addop==1)
                {
                    SymbolInfo* si=st2.Look_up(ptr->children[0]->Name);
                    //outfile<<ptr->children[0]->Name<<"ssss"<<endl;
                    if(si!=NULL){
                        //cout<<si->Name<<" is array"<<si->is_array<<endl;
                        //outfile<<si->Name<<" pppppppp"<<endl;
                        int so=si->stackOffset;
                        if(si->is_array==1)
                        {
                            so=so+si->arrayIndex*2;
                            //cout<<si->arrayIndex<<" nnnnnnnnnnnnnnnnnnnnnn    "<<endl<<endl;
                        }
                        if(so>=0)
                            outfile<<"\tMOV AX, [BP-"<<so<<"]"<<endl;
                        else
                        {
                            so*=(-1);
                             outfile<<"\tMOV AX, [BP+"<<so<<"]"<<endl;
                        }
                        outfile<<"\tPUSH AX"<<endl;
                        pushFlag=1;
                    }
                    else
                    {
                        //cout<<ptr->children[0]->Name<<" jjj"<<endl;
                        if(arrayExpression==0 && ptr->children[0]->Name!="NULL")
                        {
                            outfile<<"\tMOV AX, "<<ptr->children[0]->Name<<endl;
                            outfile<<"\tPUSH AX "<<endl;
                            pushFlag=1;
                        }
                        
                    }
                }
                else if(is_Loop==1)
                {
                    SymbolInfo* si=st2.Look_up(ptr->children[0]->Name);
                    if(si!=NULL)
                    {
                        int so=si->stackOffset;
                        if(si->is_array==1)
                        {
                            so=so+si->arrayIndex*2;   
                        }
                        outfile<<"\tMOV AX,[BP-"<<so<<"]"<<endl;
                        outfile<<"\tPUSH AX "<<endl;
                        pushFlag=1;
                    }
                    else
                    {
                         //outfile<<"\tMOV AX,"<<ptr->children[0]->Name<<endl;
                        //outfile<<"\tPUSH AX "<<endl;
                        //pushFlag=1;
                    }
                }
     
                codeTransformer(ptr->children[0]);
            }

            else if(ptr->get_Rules()=="simple_expression : simple_expression ADDOP term")//47
            {
                is_addop=1;
                codeTransformer(ptr->children[0]);
                codeTransformer(ptr->children[1]);
                codeTransformer(ptr->children[2]);
                //cout<<"9999999999999999999999999999999999999999"<<endl;
                string addoperation=ptr->children[1]->Name;
                SymbolInfo* si=st2.Look_up(ptr->children[2]->Name);
                //outfile<<" Sowdha"<<endl;
                //outfile<<ptr->children[2]->Name<<endl;
                if(si!=NULL)
                {
                    int so=si->stackOffset;
                    if(si->is_array==1)
                    {
                        so=so+si->arrayIndex*2;
                       
                    }
                    //outfile<<si->Name<<"  immmmmmmmmmmmmmm"<<endl;
                    //cout<<si<<"        jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj"<<endl;
                    if(addoperation=="+")
                    {
                        if(so>=0)
                        {
                            outfile<<"\tMOV AX, [BP-"<<so<<"]"<<endl;
                        }
                        else
                        {
                            so*=(-1);
                            outfile<<"\tMOV AX, [BP+"<<so<<"]"<<endl;
                        }
                            
                        outfile<<"\tMOV DX, AX"<<endl;
                        outfile<<"\tPOP AX"<<endl;
                        outfile<<"\tADD AX,DX"<<endl;
                        outfile<<"\tPUSH AX"<<endl;
                        pushFlag=1;
                    }

                    else if(addoperation=="-")
                    {
                        if(so>=0)
                        {
                            outfile<<"\tMOV AX, [BP-"<<so<<"]"<<endl;
                        }
                        else
                        {
                            so*=(-1);
                            outfile<<"\tMOV AX, [BP+"<<so<<"]"<<endl;
                        }
                        outfile<<"\tMOV DX, AX"<<endl;
                        outfile<<"\tPOP AX"<<endl;
                        outfile<<"\tSUB AX,DX"<<endl;
                        outfile<<"\tPUSH AX"<<endl;
                        pushFlag=1;
                    }
                }
                else
                {
                    if(addoperation=="+")
                    {
                        if(ptr->children[2]->Name!="NULL")
                            outfile<<"\tMOV AX, "<<ptr->children[2]->Name<<endl;
                        outfile<<"\tMOV DX, AX"<<endl;
                        outfile<<"\tPOP AX"<<endl;
                        outfile<<"\tADD AX,DX"<<endl;
                        outfile<<"\tPUSH AX"<<endl;
                        pushFlag=1;
                    }

                    else if(addoperation=="-")
                    {
                        if(ptr->children[2]->Name!="NULL")
                            outfile<<"\tMOV AX, "<<ptr->children[2]->Name<<endl;
                        outfile<<"\tMOV DX, AX"<<endl;
                        outfile<<"\tPOP AX"<<endl;
                        outfile<<"\tSUB AX,DX"<<endl;
                        outfile<<"\tPUSH AX"<<endl;
                        pushFlag=1;
                    }
                }
               is_addop=0;
            }

            else if(ptr->get_Rules()=="term :	unary_expression")//48
            {
                if(is_mulop==1)
                {
                    if(curr_mulop=="*")
                    {
                        SymbolInfo* si=st2.Look_up(ptr->children[0]->Name);
                        if(si!=NULL)
                        {
                            int sp=si->stackOffset;
                            if(si->is_array==1)sp=sp+si->arrayIndex*2;
                            if(sp>=0)
                                outfile<<"\tMOV AX, [BP-"<<sp<<"]"<<endl;
                            else
                            {
                                sp*=(-1);
                                outfile<<"\tMOV AX,  [BP+"<<sp<<"]"<<si->Name<<endl;////////
                            }
                            outfile<<"\tPUSH AX"<<endl;
                            pushFlag=1;
                        }
                        else
                        {
                            if(arrayExpression==0)
                            {
                                if(ptr->children[0]->Name!="NULL")
                                    outfile<<"\tMOV AX, "<<ptr->children[0]->Name<<endl;
                                outfile<<"\tPUSH AX "<<endl;
                                pushFlag=1;
                            }
                           
                        }
                    }

                    else if(curr_mulop=="/"||curr_mulop=="%")
                    {
                        SymbolInfo* si=st2.Look_up(ptr->children[0]->Name);
                        if(si!=NULL)
                        {
                            int sp=si->stackOffset;
                            if(si->is_array==1)sp=sp+si->arrayIndex*2;
                            if(sp>=0)
                                outfile<<"\tMOV AX, [BP-"<<sp<<"]"<<endl;
                            else
                            {
                                sp*=(-1);
                                outfile<<"\tMOV AX, [BP+"<<sp<<"]"<<endl;
                            }
                            outfile<<"\tPUSH AX"<<endl;
                            pushFlag=1;
                        }
                        else
                        {
                            if(ptr->children[0]->Name!="NULL")
                                outfile<<"\tMOV AX, "<<ptr->children[0]->Name<<endl;
                            outfile<<"\tPUSH AX"<<endl;
                            pushFlag=1;
                        }
                    }
                }
                codeTransformer(ptr->children[0]);
            }

            else if(ptr->get_Rules()=="term:  term MULOP unary_expression")//49
            {
                //cout<<"----------------------------"<<endl;
                is_mulop=1;
                //arrayExpression=1;
                curr_mulop=ptr->children[1]->Name;
                //cout<<curr_mulop<<endl;
                codeTransformer(ptr->children[0]);
          
                codeTransformer(ptr->children[1]);
                
                codeTransformer(ptr->children[2]);
                curr_mulop=ptr->children[1]->Name;
                if(curr_mulop=="*")
                {
                        //cout<<"****************"<<endl;
                        //cout<<ptr->children[2]->Name<<endl;
                        SymbolInfo* si=st2.Look_up(ptr->children[2]->Name);
                        if(si!=NULL)
                        {
                            //cout<<"(((((())))))"<<endl;
                            int sp=si->stackOffset;
                            if(si->is_array==1)sp=sp+si->arrayIndex*2;
                            if(sp>=0)
                                outfile<<"\tMOV AX, [BP-"<<sp<<"]"<<endl;
                            else
                            {
                                sp*=(-1);
                                outfile<<"\tMOV AX, [BP+"<<sp<<"]"<<endl;
                            }
                            outfile<<"\tMOV CX, AX"<<endl;
                            outfile<<"\tPOP AX"<<endl;
                            outfile<<"\tCWD"<<endl;
                            outfile<<"\tMUL CX"<<endl;
                            outfile<<"\tPUSH AX "<<endl;

                            pushFlag=1;
                        }
                        else
                        {
                            if(ptr->children[2]->Name!="NULL")
                                outfile<<"\tMOV AX, "<<ptr->children[2]->Name<<endl;
                            outfile<<"\tMOV CX, AX"<<endl;
                            outfile<<"\tPOP AX"<<endl;
                            outfile<<"\tCWD"<<endl;
                            outfile<<"\tMUL CX"<<endl;
                            outfile<<"\tPUSH AX"<<endl;
                            pushFlag=1;
                        }
                }
                else if(curr_mulop=="/"||curr_mulop=="%")
                {
                        //cout<<"////////////"<<endl;
                        SymbolInfo* si=st2.Look_up(ptr->children[2]->Name);
                        if(si!=NULL)
                        {
                            //cout<<"(((((())))))"<<endl;
                            int sp=si->stackOffset;
                            if(si->is_array==1)sp=sp+si->arrayIndex*2;
                            if(sp>=0)
                                outfile<<"\tMOV AX, [BP-"<<sp<<"] "<<endl;
                            else
                            {
                                sp*=(-1);
                                outfile<<"\tMOV AX, [BP+"<<sp<<"] "<<endl;
                            }
                            outfile<<"\tMOV CX, AX"<<endl;
                            outfile<<"\tPOP AX"<<endl;
                            outfile<<"\tCWD"<<endl;
                            outfile<<"\tDIV CX"<<endl;
                            if(curr_mulop=="/")
                                outfile<<"\tPUSH AX"<<endl;
                            else if(curr_mulop=="%")
                                outfile<<"\tPUSH DX"<<endl;
                            pushFlag=1;
                        }
                        else
                        {
                            outfile<<"\tMOV AX, "<<ptr->children[2]->Name<<endl;
                            outfile<<"\tMOV CX, AX"<<endl;
                            outfile<<"\tPOP AX"<<endl;
                            outfile<<"\tCWD"<<endl;
                            outfile<<"\tDIV CX"<<endl;
                            if(curr_mulop=="/")
                                outfile<<"\tPUSH AX"<<endl;
                            else if(curr_mulop=="%")
                                outfile<<"\tPUSH DX"<<endl;
                            pushFlag=1;
                        }
                }
                is_mulop=0;
            }

            else if(ptr->get_Rules()=="unary_expression : ADDOP unary_expression")//50
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
                string addorsub=ptr->children[0]->Name;
                              //cout<<addorsub<<endl;
                int val=1;
                if(addorsub=="-")val=-1;
                SymbolInfo* si=st2.Look_up(ptr->children[1]->Name);
                if(si!=NULL)
                {
                       //cout<<"(((((())))))"<<endl;
                            int sp=si->stackOffset;
                            if(si->is_array==1)sp=sp+si->arrayIndex*2;
                            if(sp>=0)
                                outfile<<"\tMOV AX, [BP-"<<sp<<"]"<<endl;
                            else
                            {
                                sp*=(-1);
                                outfile<<"\tMOV AX, [BP+"<<sp<<"]"<<endl;
                            }
                            outfile<<"\tMOV CX, AX"<<endl;
                            outfile<<"\tMOV AX,"<<val<<endl;
                            outfile<<"\tCWD"<<endl;
                            outfile<<"\tMUL CX"<<endl;
                            outfile<<"\tPUSH AX "<<endl;

                            pushFlag=1;
                        }
                        else
                        {
                            if(ptr->children[2]->Name!="NULL")
                                outfile<<"\tMOV AX, "<<ptr->children[2]->Name<<endl;
                            outfile<<"\tMOV CX, AX"<<endl;
                            outfile<<"\tMOV AX,"<<val<<endl;
                            outfile<<"\tCWD"<<endl;
                            outfile<<"\tMUL CX"<<endl;
                            outfile<<"\tPUSH AX"<<endl;
                            pushFlag=1;
                        
                }
            }

            else if(ptr->get_Rules()=="unary_expression : NOT unary_expression")//51
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
  
            }

            else if(ptr->get_Rules()=="unary_expression : factor")//52
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="factor	: variable")//53
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="factor	: ID LPAREN argument_list RPAREN")//54
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
                outfile<<"\tCALL "<<ptr->children[0]->Name<<endl;
                
            }

            else if(ptr->get_Rules()=="factor	: LPAREN expression RPAREN")//55
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="factor	: CONST_INT")//56
            {
                //cout<<"hahahah"<<ptr->children[0]->Name<<endl;
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="factor	: CONST_FLOAT")//57
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }

            else if(ptr->get_Rules()=="factor	: variable INCOP")//58
            {
                codeTransformer(ptr->children[0]);
                codeTransformer(ptr->children[1]);
                //cout<<ptr->children[0]->Name<<" hahahhahah"<<endl;
                if(is_Loop==0)
                {
                    SymbolInfo* si=st2.Look_up(ptr->children[0]->Name);
                    if(si!=NULL)
                    {
                        int so=si->stackOffset;
                        if(so>=0)
                        {
                            outfile<<"\tMOV AX,[BP-"<<so<<"]"<<endl;
                            outfile<<"\tADD AX,1"<<endl;
                            outfile<<"\tMOV [BP-"<<so<<"], AX"<<endl;
                        }
                        else
                        {
                            so*=(-1);
                            outfile<<"\tMOV AX,[BP+"<<so<<"]"<<endl;
                            outfile<<"\tADD AX,1"<<endl;
                            outfile<<"\tMOV [BP+"<<so<<"], AX"<<endl;
                        }
                        
                        
                        
                    }
                    else
                    {
                        outfile<<"MOV AX, "<<ptr->children[0]->Name<<endl;
                        outfile<<"\tADD AX,1"<<endl;
                        outfile<<"\tMOV "<<ptr->children[0]->Name<<", AX"<<endl;
                    }
                }
                else if(is_Loop==1)
                {
                    SymbolInfo* si=st2.Look_up(ptr->children[0]->Name);
                    if(si!=NULL)
                    {
                        int so=si->stackOffset;
                        if(so>=0)
                        {
                            outfile<<"MOV AX,[BP-"<<so<<"]"<<endl;
                            outfile<<"\tPUSH AX"<<endl;
                            outfile<<"\tADD AX,1"<<endl;
                            outfile<<"\tMOV [BP-"<<so<<"], AX"<<endl;
                        }
                        else
                        {
                            so*=(-1);
                            outfile<<"MOV AX,[BP+"<<so<<"]"<<endl;
                            outfile<<"\tPUSH AX"<<endl;
                            outfile<<"\tADD AX,1"<<endl;
                            outfile<<"\tMOV [BP+"<<so<<"], AX"<<endl;
                        }
                       
                    }
                    else
                    {
                        outfile<<"MOV AX, "<<ptr->children[0]->Name<<endl;
                        outfile<<"\tADD AX,1"<<endl;
                        outfile<<"\tMOV "<<ptr->children[0]->Name<<", AX"<<endl;
                    }
                }

            }

            else if(ptr->get_Rules()=="factor	: variable DECOP")//59
            {
                codeTransformer(ptr->children[0]);
                codeTransformer(ptr->children[1]);
                //cout<<ptr->children[0]->Name<<" hohoho"<<endl;
                if(is_Loop==0)
                {
                    SymbolInfo* si=st2.Look_up(ptr->children[0]->Name);
                    if(si!=NULL)
                    {
                        int so=si->stackOffset;
                        if(so>=0)
                        {
                            outfile<<"MOV AX,[BP-"<<so<<"]"<<endl;
                            outfile<<"\tSUB AX,1"<<endl;
                            outfile<<"\tMOV [BP-"<<so<<"], AX"<<endl;   
                        }
                        else
                        {
                            so*=(-1);
                            outfile<<"\tMOV AX,[BP+"<<so<<"]"<<endl;
                            outfile<<"\tSUB AX,1"<<endl;
                            outfile<<"\tMOV [BP+"<<so<<"], AX"<<endl;
                        }
                        
                    }
                    else
                    {
                        outfile<<"\tMOV AX, "<<ptr->children[0]->Name<<endl;
                        outfile<<"\tSUB AX,1"<<endl;
                        outfile<<"\tMOV "<<ptr->children[0]->Name<<", AX"<<endl;
                    }
                }
                else if(is_Loop==1)
                {
                    SymbolInfo* si=st2.Look_up(ptr->children[0]->Name);
                    if(si!=NULL)
                    {
                        int so=si->stackOffset;
                        if(so>=0)
                        {
                            outfile<<"\tMOV AX,[BP-"<<so<<"]"<<endl;
                            outfile<<"\tPUSH AX "<<endl;
                            outfile<<"\tSUB AX,1"<<endl;
                            outfile<<"\tMOV [BP-"<<so<<"], AX"<<endl;
                        }
                        else
                        {
                            so*=(-1);
                            outfile<<"\tMOV AX,[BP-"<<so<<"]"<<endl;
                            outfile<<"\tPUSH AX "<<endl;
                            outfile<<"\tSUB AX,1"<<endl;
                            outfile<<"\tMOV [BP-"<<so<<"], AX"<<endl;
                        }
                    }
                    else
                    {
                        outfile<<"\tMOV AX, "<<ptr->children[0]->Name<<endl;
                        outfile<<"\tSUB AX,1"<<endl;
                        outfile<<"\tMOV "<<ptr->children[0]->Name<<", AX"<<endl;
                    }
                }
            }

            else if(ptr->get_Rules()=="argument_list : arguments")//60
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
            }
            
            else if(ptr->get_Rules()=="arguments : arguments COMMA logic_expression")//61
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
                SymbolInfo* si=st2.Look_up(ptr->children[2]->Name);
                if(si!=NULL)
                {
                    int so=si->stackOffset;
                    if(so>=0)
                    {
                        outfile<<"\tMOV AX, "<<"[BP-"<<so<<"]"<<endl;
                    }
                    else
                    {
                        so*=(-1);
                        outfile<<"\tMOV AX, "<<"[BP-"<<so<<"]"<<endl;
                    }
                }
                else
                {
                    outfile<<"\tMOV AX, "<<ptr->children[2]->Name<<endl;
                }
                outfile<<"\tPUSH AX"<<endl;
            }

            else if(ptr->get_Rules()=="arguments : logic_expression")//62
            {
                for(const auto & element:ptr->children)
                {
                    codeTransformer(element);
                }
                SymbolInfo* si=st2.Look_up(ptr->children[0]->Name);
                if(si!=NULL)
                {
                    int so=si->stackOffset;
                    if(so>=0)
                    {
                        outfile<<"\tMOV AX, "<<"[BP-"<<so<<"]"<<endl;
                    }
                    else
                    {
                        so*=(-1);
                        outfile<<"\tMOV AX, "<<"[BP+"<<so<<"]"<<endl;
                    }
                }
                else
                {
                    outfile<<"\tMOV AX, "<<ptr->children[0]->Name<<endl;
                }
                outfile<<"\tPUSH AX"<<endl;
                //cout<<ptr->children[0]->Name<<" Irtiaz vai"<<endl;
            }

        }
};