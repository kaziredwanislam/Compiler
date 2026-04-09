%{

#include "2005108.h"
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include <fstream>

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;

SymbolTable *table;

void yyerror(char *s)
{
	cout << "Error"<<endl;
	//write your code
}
FILE* fp;
FILE* fp2;
FILE* fp3;
FILE* fp4;

int total_buckets=11;
SymbolTable st(total_buckets);
string t_specifier="NULL";
string f_specifier="NULL";
extern int lineCount;
extern int errorcount;
vector<SymbolInfo*>curr_parameters;
int arrayFlag=0;
int modulaserrorFlag=0;
void say_hello()
{
	printf("Hello");
	//fprintf(fp3,"Hello\n");
}

void check_function_return_type(string ty_specifier,SymbolInfo* f2,int line_no)
{
	//std::cout<<ty_specifier<<endl;
	if(ty_specifier!=f2->Type)
	{
		errorcount++;
		fprintf(fp4,"Line# %d: Conflicting types for '%s'\n",line_no,f2->get_Name().c_str());
	}
}
bool is_present_in_curr_parameters(string Name)
{
	bool val=false;
	for(int i=0;i<curr_parameters.size();i++)
	{
			if(curr_parameters[i]->Name==Name)
			{
				val=true;
				break;
			}
	}
	return val;
}

string get_type_of_parameter(string Name)
{
	for(int i=0;i<curr_parameters.size();i++)
	{
		if(curr_parameters[i]->Name==Name)
		{
			return curr_parameters[i]->Type;
		}
	}
}

void print_parameters(SymbolInfo* obj)
{
	for(int i=0;i<obj->parameters.size();i++)
	{
		std::cout<<obj->parameters[i]->Name<<" params "<<obj->parameters[i]->Type<<endl;
	}
	std::cout<<endl;
}

void show_factors(SymbolInfo* obj)
{
	for(int i=0;i<obj->factorList.size();i++)
	{
		std::cout<<obj->factorList[i]->Name<<" factor "<<obj->factorList[i]->Type<<endl;
	}
}

void check_parameters_Number(SymbolInfo* prev,SymbolInfo* next,int line_no)
{
	int size1=prev->parameters.size();
	int size2=next->parameters.size();
	//std::cout<<size1<<"cpn "<<size2<<endl;
	if(size2>size1)
	{
		errorcount++;
		fprintf(fp4,"Line# %d Too many arguments to function '%s'\n",line_no,prev->Name.c_str());
	}
	else if(size2<size1)
	{
		errorcount++;
		fprintf(fp4,"Line# %d Too few arguments to function '%s'\n",line_no,prev->Name.c_str());
	}
}

void check_function_validity(SymbolInfo* prev,SymbolInfo* next,int line_no)
{
		int size1=prev->parameters.size();
		int size2=next->parameters.size();
		if(size1!=size2)
		{
			errorcount++;
			fprintf(fp4,"Line# %d: Conflicting types for '%s'\n",line_no,prev->Name.c_str());
		}
		else
		{
			int p=size1-1;
			for(int i=0;i<size1;i++)
			{
				if(prev->parameters[i]->Type!=next->parameters[p]->Type)
				{
					errorcount++;
					fprintf(fp4,"Line# %d: Conflicting types for '%s'\n",line_no,prev->Name.c_str());
				}
				p--;
			}
		}
}

void compare_parameters_type(SymbolInfo* prev,SymbolInfo* next,int line_no)
{
	int size1=prev->parameters.size();
	int size2=next->parameters.size();
	//cout<<"NNNNN"<<endl;
	//print_parameters(prev);
	//cout<<"iiii"<<endl;
	//print_parameters(next);
	
	//std::cout<<size1<<" hahahaha"<<size2<<endl;
	if(size1==size2)
	{
		int p=prev->parameters.size()-1;
		for(int i=0;i<prev->parameters.size();i++)
		{
			//cout<<next->parameters[i]->Name<<" "<<next->parameters[i]->is_array<<endl;
			if(next->parameters[p]->is_array==true)
			{
				errorcount++;
				//std::cout<<"HhHHhHH"<<endl;
				fprintf(fp4,"Line# %d: Type mismatch for argument %d of '%s'\n",line_no,i+1,prev->get_Name().c_str());
			}
			//std::cout<<prev->parameters[i]->Name<<" pp "<<prev->parameters[i]->Type<<endl;
			else if(prev->parameters[i]->Type!=next->parameters[p]->Type)
			{
				errorcount++;
				fprintf(fp4,"Line# %d: Type mismatch for argument %d of '%s'\n",line_no,i+1,prev->get_Name().c_str());
			}
			p--;
		}
	}
}

bool is_factors_present(SymbolInfo* right,int line_no)
{
	bool val=true;
	//std:: cout<<"is_factors_pres"<<endl;
	//std::cout<<right->factorList.size()<<" bbb"<<endl;
	for(int i=0;i<right->factorList.size();i++)
	{
		//std::cout<<right->factorList[i]->Name<<" hhhh "<<right->factorList[i]->Type<<endl;
		if(right->factorList[i]->Type=="NULL")
		{
			errorcount++;
			val=false;
			fprintf(fp4,"Line# %d: %s is not declared before\n",line_no,right->factorList[i]->Name.c_str());
		}
	}
	//std::cout<<val<<"Abir"<<endl;
	return val;
}

bool check_factors_Type(SymbolInfo* left,SymbolInfo* right,int line_no)
{
	bool val=true;
	//std::cout<<"Tabib "<< left->Name<<" "<<left->Type<<endl;
	for(int i=0;i<right->factorList.size();i++)
	{
		//std::cout<<"aaaaaaaaaaa"<<endl;
		if(left->Type!=right->factorList[i]->Type)
		{
			val=false;
			if(left->Type=="INT" && right->factorList[i]->Type=="FLOAT")
			{
				errorcount++;
				fprintf(fp4,"Line# %d: Warning: possible loss of data in assignment of FLOAT to INT\n",line_no);
			}
		}
	}
	return val;
}

void print_parse_tree(SymbolInfo* rootpointer,int empty_space)
{
	for(const auto & element:rootpointer->children)
	{
		for(int i=0;i<empty_space;i++)
		{
			fprintf(fp3," ");
		}

		if(element->is_terminal()==true)
		{
			fprintf(fp3,"%s : %s <Line: %d>\n",element->get_real_Type().c_str(),element->get_Name().c_str(),element->startLine);
		}
		
		else 
		{
			fprintf(fp3,"%s <Line: %d-%d>\n",element->get_Rules().c_str(),element->startLine,element->endLine);
		}
		print_parse_tree(element,empty_space+1);
	}
}

%}

%union{
	SymbolInfo* symbol;
	}

%token<symbol> IF ELSE FOR WHILE ID LPAREN RPAREN SEMICOLON COMMA LCURL RCURL INT FLOAT VOID PRINTLN 
		LTHIRD RTHIRD CONST_INT CONST_FLOAT RETURN RELOP ADDOP MULOP LOGICOP ASSIGNOP NOT 
		INCOP DECOP STRUCT

%type<symbol>start program unit func_declaration func_definition  parameter_list compound_statement var_declaration
		type_specifier declaration_list statements statement  expression_statement variable expression logic_expression
		rel_expression simple_expression term  unary_expression factor argument_list arguments struct_definition



%left  ADDOP MULOP
%right RELOP

%nonassoc  INCOP DECOP
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

start : program
	{
			//write your code in this block in all the similar blocks below
			$$=new SymbolInfo();
			SymbolInfo* sli=new SymbolInfo();
			sli->Rules="start : program";
			sli->Name="NULL";
			sli->startLine=$1->startLine;
			sli->endLine=$1->endLine;
			sli->terminal=false;
			$$=sli;
			$$->add_children($1);
			SymbolInfo* root=$$;
			fprintf(fp3,"%s		<Line:%d-%d>\n",$$->Rules.c_str(),$$->startLine,$$->endLine);
			//st.print_all_scope_table(fp2);
			print_parse_tree(root,1);
			fprintf(fp2,"start : program \n");
			fprintf(fp2,"Total Lines: %d\n",lineCount+1);
			fprintf(fp2,"Total errors: %d\n",errorcount);
			ICG ob;
			ob.assemblyCodeGenerator(root);
			//std::cout<<"Hahahahahah\n"<<endl;
	}
	;

program : program unit 
{
			SymbolInfo* sli=new SymbolInfo();
			sli->Rules="program : program unit";
			sli->Name="NULL";
			sli->startLine=$1->startLine;
			sli->endLine=$2->endLine;
			sli->terminal=false;
			$$=sli;
			$$->add_children($1);
			$$->add_children($2);
			fprintf(fp2,"program : program unit \n");
			//fprintf(fp3,"%s	<Line:%d-%d>\n",$$->Type.c_str(),$$->startLine,$$->endLine);
}
	| unit {
			$$=new SymbolInfo();
			SymbolInfo* sli=new SymbolInfo();
			sli->Rules="program : unit";
			sli->Name="NULL";
			sli->startLine=$1->startLine;
			sli->endLine=$1->endLine;
			sli->terminal=false;
			$$=sli;
			$$->add_children($1);
			fprintf(fp2,"program : unit \n");
			//fprintf(fp3,"%s		<Line:%d-%d>\n",$$->Type.c_str(),$$->startLine,$$->endLine);
			//fprintf(fp3,"%s, Line:%d\n",$$->Type.c_str(),$$->startLine);
	}
	;
	
unit : var_declaration {
	fprintf(fp2,"unit : var_declaration \n");
	$$=new SymbolInfo();
	SymbolInfo* sli=new SymbolInfo();
	sli->Rules="unit : var_declaration";
	sli->Name="NULL";
	sli->terminal=false;
	sli->startLine=$1->startLine;
	sli->endLine=$1->endLine;
	$$=sli;
	$$->add_children($1);
	//fprintf(fp2,"%s		<Line:%d-%d>\n",$$->Type.c_str(),$$->startLine,$$->endLine);
	//fprintf(fp2,"%s, Line:%g\n",$$->Type.c_str(),$$->startLine);
}
     | func_declaration {
			fprintf(fp2,"unit : func_declaration \n");
			$$=new SymbolInfo();
			SymbolInfo* sli=new SymbolInfo();
			sli->Rules="unit : func_declaration";
			sli->Name="NULL";
			sli->terminal=false;
			sli->startLine=$1->startLine;
			sli->endLine=$1->endLine;
			$$=sli;
			$$->add_children($1);
			//fprintf(fp3,"%s		<Line:%d-%d>\n",$$->Type.c_str(),$$->startLine,$$->endLine);
	 }
     | func_definition {
			fprintf(fp2,"unit : func_defintion \n");
			$$=new SymbolInfo();
			SymbolInfo* sli=new SymbolInfo();
			sli->Rules="unit : func_definition";
			sli->Name="NULL";
			sli->terminal=false;
			sli->startLine=$1->startLine;
			sli->endLine=$1->endLine;
			$$=sli;
			$$->add_children($1);
			//fprintf(fp3,"%s		<Line:%d-%d>\n",$$->Type.c_str(),$$->startLine,$$->endLine);
	 }
	 | struct_definition {
		$$=new SymbolInfo();
		SymbolInfo* sli=new SymbolInfo();
		sli->Rules="unit: struct_definition ";
		sli->Name="NULL";
		sli->terminal=false;
		sli->startLine=$1->startLine;
		sli->endLine=$1->endLine;
		sli->Type=t_specifier;
		$$=sli;
		$$->add_children($1);
	
	 }
     ;

struct_definition :STRUCT ID compound_statement SEMICOLON{
	cout<<"Hello";
	fprintf(fp2,"struct_definition :STRUCT  ID compound_statement SEMICOLON\n");
	$$=new SymbolInfo();
	SymbolInfo* sli=new SymbolInfo();
	sli->Rules="unit : STRUCT  ID compound_statement SEMICOLON ";
		sli->Name="NULL";
		sli->terminal=false;
		sli->startLine=$1->startLine;
		sli->endLine=$4->endLine;
		sli->Type=t_specifier;
		$$=sli;
		$$->add_children($1);
		$$->add_children($2);
		$$->add_children($3);
		$$->add_children($4);
		//std::cout <<"Hello"<<endl;
}
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
		fprintf(fp2,"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON \n");
		$$=new SymbolInfo();
		SymbolInfo* sli=new SymbolInfo();
		sli->Rules="func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON";
		sli->Name="NULL";
		sli->terminal=false;
		sli->startLine=$1->startLine;
		sli->endLine=$6->endLine;
		sli->Type=t_specifier;
		sli->copy_parameters($4,fp4,$1->startLine);
		$$=sli;
		$$->add_children($1);
		$$->add_children($2);
		$$->add_children($3);
		$$->add_children($4);
		$$->add_children($5);
		$$->add_children($6);
			bool val=st.Insert_Function_declaration($2->Name,f_specifier,true,fp2,$4->parameters);
			//std::cout<<val<<" nnnn"<<endl;
		//fprintf(fp3,"%s		<Line:%d-%d>\n",$$->Type.c_str(),$$->startLine,$$->endLine);
		f_specifier="NULL";
}
		| type_specifier ID LPAREN RPAREN SEMICOLON {
				fprintf(fp2,"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON \n");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON";
				sli->Name="NULL";
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$5->endLine;
				sli->Type=t_specifier;
				vector<SymbolInfo*>vv;
				$$=sli;
				$$->add_children($1);
				$$->add_children($2);
				$$->add_children($3);
				$$->add_children($4);
				$$->add_children($5);
				bool val=st.Insert_Function_declaration($2->Name,f_specifier,true,fp2,vv);
				//std::cout<<val<<" kkk"<<endl;
				//fprintf(fp3,"%s		<Line:%d-%d>\n",$$->Type.c_str(),$$->startLine,$$->endLine);
				f_specifier="NULL";
		}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement {
			//std::cout<<$1->Type<<" jjjj"<<endl;
			for(int i=0;i<$4->parameters.size();i++)
			{
				bool value=st.Insert_parameter($4->parameters[i]->Name,$4->parameters[i]->Type,fp2,true);
				if(value==false)
				{
					errorcount++;
					fprintf(fp4,"Line# %d: Redefinition of parameter '%s'\n",$1->startLine,$4->parameters[i]->Name.c_str());
				}
			}
			st.print_all_scope_table(fp2);
			bool val=st.ExitScope();
			 val=st.Insert_into_parent_table($2->Name,f_specifier,fp2,$4->parameters);
			//std::cout<<val<<endl;
				if(val==false)
				{
					SymbolInfo* prev=st.Look_up($2->Name);
					if(prev->is_function==true)
					{
						check_function_return_type(f_specifier,prev,$2->startLine);
						check_function_validity(prev,$4,$1->startLine);
						//compare_parameters_type(prev,$4,$1->startLine);
					}
					else
					{
						errorcount++;
						fprintf(fp4,"Line# %d:  '%s' redeclared as different kind of symbol\n",$1->startLine,prev->Name.c_str());
					}
				}
		//print_parameters($4);

		fprintf(fp2,"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement \n");
		$$=new SymbolInfo();
		//st.Enter_Scope();
		SymbolInfo* sli=new SymbolInfo();
		sli->Rules="func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement";
		sli->Name="NULL";
		sli->terminal=false;
		sli->startLine=$1->startLine;
		sli->endLine=$6->endLine;
		$$=sli;
		$$->add_children($1);
		$$->add_children($2);
		$$->add_children($3);
		$$->add_children($4);
		$$->add_children($5);
		$$->add_children($6);
		f_specifier="NULL";
		curr_parameters.clear();
		//print_parameters($$);
		//fprintf(fp3,"%s		<Line:%d-%d>\n",$$->Type.c_str(),$$->startLine,$$->endLine);
}
		| type_specifier ID LPAREN RPAREN compound_statement {
					//std::cout<<endl<<$1->Type<<"nnnn"<<endl;
					//cout<<"here!"<<endl;
			vector<SymbolInfo*>vv;
			SymbolInfo*obj=new SymbolInfo();
			st.print_all_scope_table(fp2);
			bool val=st.ExitScope();
			 val=st.Insert_into_parent_table($2->Name,f_specifier,fp2,vv);

			//std::cout<<val<<endl;
				if(val==false)
				{
					SymbolInfo* prev=st.Look_up($2->Name);
					if(prev->is_function==true)
					{
						check_function_return_type(f_specifier,prev,$2->startLine);
						check_function_validity(prev,obj,lineCount);
					}
					else
					{
						errorcount++;
						fprintf(fp4,"Line# %d:  '%s' redeclared as different kind of symbol\n",$1->startLine,prev->Name.c_str());
					}
					//compare_parameters_type(prev,vv,)
				}
	
				fprintf(fp2,"func_definition : type_specifier ID LPAREN RPAREN compound_statement \n");
				$$=new SymbolInfo();	
				//st.Enter_Scope();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="func_definition : type_specifier ID LPAREN RPAREN compound_statement";
				sli->Name="NULL";
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$5->endLine;
				$$=sli;
				$$->add_children($1);
				$$->add_children($2);
				$$->add_children($3);
				$$->add_children($4);
				$$->add_children($5);
				f_specifier="NULL";
				curr_parameters.clear();
				//print_parameters($$);
				//fprintf(fp3,"%s		<Line:%d-%d>\n",$$->Type.c_str(),$$->startLine,$$->endLine);
		}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID {
				fprintf(fp2,"parameter_list  : parameter_list COMMA type_specifier ID \n");
				$$=new SymbolInfo();
				//st.Enter_Scope();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="parameter_list  : parameter_list COMMA type_specifier ID";
				sli->Name="NULL";
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$4->endLine;
				/*bool val=st.Insert_parameter($4->Name,t_specifier,fp2,true);
				if(val==false)
				{
					fprintf(fp4,"Line# %d: Redefinition of parameter %s \n",$4->startLine,$4->Name.c_str());
				}*/
				$$=sli;
				$4->return_type=t_specifier;
				$4->Type=t_specifier;
				$$->add_children($1);
				$$->add_children($2);
				$$->add_children($3);
				$$->add_children($4);
				$$->copy_parameters($1,fp4,$1->startLine);
				$$->add_parameters($4);
				curr_parameters.push_back($4);
				for(int i=0;i<$1->parameters.size();i++)
				{
					curr_parameters.push_back($1->parameters[i]);
				}
			
				//print_parameters($$);
				//fprintf(fp3,"%s		<Line:%d-%d>\n",$$->Type.c_str(),$$->startLine,$$->endLine);
}
		| parameter_list COMMA type_specifier {
				fprintf(fp2,"parameter_list  : parameter_list COMMA type_specifier \n");
				$$=new SymbolInfo();
				//st.Enter_Scope();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="parameter_list  : parameter_list COMMA type_specifier ID";
				sli->Name="NULL";
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$3->endLine;
				$$=sli;
				$$->add_children($1);
				$$->add_children($2);
				$$->add_children($3);
				$$->copy_parameters($1,fp4,$1->startLine);
				//fprintf(fp3,"%s		<Line:%d-%d>\n",$$->Type.c_str(),$$->startLine,$$->endLine);
		}
 		| type_specifier ID {
				fprintf(fp2,"parameter_list  : type_specifier ID \n ");
				$$=new SymbolInfo();
				//st.Enter_Scope();
				SymbolInfo* sli=new SymbolInfo();
				/*bool val=st.Insert_parameter($2->Name,t_specifier,fp2,true);
				if(val==false)
				{
					fprintf(fp4,"Line# %d: Redefinition of parameter %s\n",$2->startLine,$2->Name.c_str());
				}*/
				sli->Rules="parameter_list  : type_specifier ID";
				sli->Name="NULL";
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$2->endLine;
				$$=sli;
				$2->return_type=t_specifier;
				$2->Type=t_specifier;
				$$->add_children($1);
				$$->add_children($2);
				$$->add_parameters($2);
				curr_parameters.push_back($2);
				//fprintf(fp3,"%s		<Line:%d-%d>\n",$$->Type.c_str(),$$->startLine,$$->endLine);
		}
		| type_specifier{
				fprintf(fp2,"parameter_list  : type_specifier \n");
				$$=new SymbolInfo();
				//st.Enter_Scope();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="parameter_list  : type_specifier";
				sli->Name="NULL";
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$1->endLine;
				$$=sli;
				$$->add_children($1);
				//fprintf(fp3,"%s		<Line:%d-%d>\n",$$->Type.c_str(),$$->startLine,$$->endLine);
		}
 		;

 		
compound_statement : LCURL statements RCURL {
				$$=new SymbolInfo();
				//st.Enter_Scope();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="compound_statement  : LCURL statements RCURL";
				sli->Name="NULL";
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$3->endLine;
				$$=sli;
				$$->add_children($1);
				$$->add_children($2);
				$$->add_children($3);
				fprintf(fp2,"compound_statement : LCURL statements RCURL \n");
				//fprintf(fp2,"Helllllllooooooo\n");
				
				
				//fprintf(fp2,"%d\n",val);
				//fprintf(fp3,"%s		<Line:%d-%d>\n",$$->Type.c_str(),$$->startLine,$$->endLine);
}
 		    | LCURL RCURL {
				//printf("HhH");
				fprintf(fp2,"compound_statement : LCURL RCURL \n");
				$$=new SymbolInfo();
				//st.Enter_Scope();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="compound_statement : LCURL RCURL";
				sli->Name="NULL";
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$2->endLine;
				$$=sli;
				$$->add_children($1);
				$$->add_children($2);
				//printf("worldddddd");
				//st.print_all_scope_table(fp2);
				//st.ExitScope();
				//fprintf(fp3,"%s		<Line:%d-%d>\n",$$->Type.c_str(),$$->startLine,$$->endLine);
			}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {
		fprintf(fp2,"var_declaration : type_specifier declaration_list SEMICOLON \n");
		$$=new SymbolInfo();
		SymbolInfo* sli=new SymbolInfo();
		sli->Rules="var_declaration : type_specifier declaration_list SEMICOLON";
		sli->Name="NULL";
		sli->terminal=false;
		sli->startLine=$1->startLine;
		sli->endLine=$3->endLine;
		$$=sli;
		$$->add_children($1);
		$$->add_children($2);
		$$->add_children($3);
		//std::cout<<$3->Name<<"888"<<endl;
		if($1->isVoid==true)
		{
			// do not insert
			for(int i=0;i<$1->children.size();i++)
			{
				//if($1->children[i]->Type=="ID")
				errorcount++;
					fprintf(fp4,"Line# %d: Variable or field '%s' declared void \n",$1->startLine,$2->children[i]->Name.c_str());
			}	
		}
		//fprintf(fp3,"%s		<Line:%d-%d>\n",$$->Type.c_str(),$$->startLine,$$->endLine);
		//fprintf(fp3,"%s, Line:%d\n",$$->Type.c_str(),$$->startLine);
	}
	 
 		 ;
 		 
type_specifier	: INT {
		fprintf(fp2,"type_specifier	: INT \n");
		t_specifier="INT";
		//$$->Type="INT";
		if(f_specifier=="NULL")
			f_specifier="INT";
		$$=new SymbolInfo();
		SymbolInfo* sli=new SymbolInfo();
		sli->Rules="type_specifier : INT";
		sli->Name="NULL";
		sli->terminal=false;
		sli->startLine=$1->startLine;
		sli->endLine=$1->endLine;
		$$=sli;
		$$->add_children($1);
		//fprintf(fp3,"%s	%s	<Line:%d-%d>\n",$$->Type.c_str(),$$->Name.c_str(),$$->startLine,$$->endLine);
		//fprintf(fp3,"mmm");
		//fprintf(fp3,"%s, Line:%d\n",$1->Type.c_str(),$1->startLine);
}
 		| FLOAT {
			fprintf(fp2,"type_specifier	: FLOAT \n");
			t_specifier="FLOAT";
			//$$->Type="FLOAT";
			if(f_specifier=="NULL")
				f_specifier="FLOAT";
			$$=new SymbolInfo();
			SymbolInfo* sli=new SymbolInfo();
			sli->Rules="type_specifier : FLOAT";
			sli->Name="NULL";
			sli->terminal=false;
			sli->startLine=$1->startLine;
			sli->endLine=$1->endLine;
			$$=sli;
			$$->add_children($1);
			//fprintf(fp3,"%s	%s	<Line:%d-%d>\n",$$->Type.c_str(),$$->Name.c_str(),$$->startLine,$$->endLine);
		}
 		| VOID {
			fprintf(fp2,"type_specifier	: VOID\n");
			t_specifier="VOID";
			//$$->Type="VOID";
			if(f_specifier=="NULL")
				f_specifier="VOID";
			//cout<<$1->get_Name()<<endl;
			$$=new SymbolInfo();
			SymbolInfo* sli=new SymbolInfo();
			sli->Rules="type_specifier : VOID";
			sli->Name="NULL";
			sli->terminal=false;
			sli->startLine=$1->startLine;
			sli->endLine=$1->endLine;
			$$=sli;
			$$->add_children($1);
			$1->isVoid=true;
			$$->isVoid=$1->isVoid;
			//fprintf(fp3,"%s	%s	<Line:%d-%d>\n",$$->Type.c_str(),$$->Name.c_str(),$$->startLine,$$->endLine);
		}
 		;
 		
declaration_list : declaration_list COMMA ID {
	fprintf(fp2,"declaration_list : declaration_list COMMA ID \n");
	//$$=new SymbolInfo();
	$$=new SymbolInfo();
	SymbolInfo* sli=new SymbolInfo();
	sli->Rules="declaration_list : declaration_list COMMA ID";
	sli->Name="NULL";
	sli->terminal=false;
	sli->startLine=$1->startLine;
	sli->endLine=$3->endLine;
	$3->Type=t_specifier;
	bool val=st.Insert($3->Name,t_specifier,fp2);
	if(val==false)
	{
		SymbolInfo* prev=st.Look_up($3->Name);
		if(prev->is_parameter==false)
		{
			if(prev->Type==t_specifier)
			{
				errorcount++;
				fprintf(fp4,"Line# %d: 555 Redefinition of parameter '%s'\n",$3->startLine,$3->Name.c_str());
			}
			else
			{
				errorcount++;
				fprintf(fp4,"Line# %d: Conflicting types for'%s'\n",$3->startLine,$3->Name.c_str());
			}
		}
			
	}
	$$=sli;
	$$->add_children($1);
	$$->add_children($2);
	$$->add_children($3);
	if(st.get_curr_table_id()=="1")
	{
		f_specifier="NULL";
	}
	//fprintf(fp3,"%s	%s	<Line:%d-%d>\n",$$->Type.c_str(),$$->Name.c_str(),$$->startLine,$$->endLine);
	//fprintf(fp3,"%s, Line:%g\n",$$->Type.c_str(),$$->startLine);
}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD{
				fprintf(fp2,"declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE \n");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="declaration_list :  declaration_list COMMA ID LSQUARE CONST_INT RSQUARE";
				sli->Name="NULL";
				sli->terminal=false;
				sli->startLine=$6->startLine;
				sli->endLine=$6->endLine;
				$3->Type=t_specifier;
				bool val=st.Insert($3->Name,t_specifier,fp2,true);
				if(val==false)
				{
					SymbolInfo* prev=st.Look_up($3->Name);
						if(prev->is_parameter==false)
						{
							if(prev->Type==t_specifier)
							{
								errorcount++;
								fprintf(fp4,"Line# %d: Redefinition of parameter '%s'\n",$3->startLine,$3->Name.c_str());
							}
							else
							{
								errorcount++;
								fprintf(fp4,"Line# %d: Conflicting types for'%s'\n",$3->startLine,$3->Name.c_str());
							}
						}
				}
				$$=sli;
				$$->add_children($1);
				$$->add_children($2);
				$$->add_children($3);
				$$->add_children($4);
				$$->add_children($5);
				$$->add_children($6);
					if(st.get_curr_table_id()=="1")
					{
						f_specifier="NULL";
					}
				//fprintf(fp3,"%s	%s	<Line:%d-%d>\n",$$->Type.c_str(),$$->Name.c_str(),$$->startLine,$$->endLine);
		  }
 		  
 		  | ID LTHIRD CONST_INT RTHIRD{
				$$=new SymbolInfo();
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="declaration_list  : ID LSQUARE CONST_INT RSQUARE";
				sli->Name="NULL";
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$4->endLine;
				sli->Type=t_specifier;
				$1->Type=t_specifier;
				bool val=st.Insert($1->Name,t_specifier,fp2,true);
				if(val==false)
				{
					SymbolInfo* prev=st.Look_up($1->Name);
						if(prev->is_parameter==false)
						{
							if(prev->Type==t_specifier)
							{
								errorcount++;
								fprintf(fp4,"Line# %d: Redefinition of parameter '%s'\n",$1->startLine,$1->Name.c_str());
							}
							else
							{
								errorcount++;
								fprintf(fp4,"Line# %d: Conflicting types for'%s'\n",$1->startLine,$1->Name.c_str());
							}
						}
				}
				$$=sli;
				$$->add_children($1);
				$$->add_children($2);
				$$->add_children($3);
				$$->add_children($4);
					if(st.get_curr_table_id()=="1")
					{
						f_specifier="NULL";
					}
				fprintf(fp2,"declaration_list : ID LSQUARE CONST_INT RSQUARE \n");
				//fprintf(fp3,"%s	%s	<Line:%d-%d>\n",$$->Type.c_str(),$$->Name.c_str(),$$->startLine,$$->endLine);
		  }
		  | ID {
				fprintf(fp2,"declaration_list : ID \n");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="declaration_list : ID";
				sli->Name="NULL";
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$1->endLine;
				sli->Type=t_specifier;
				$$=sli;
				bool val=st.Insert($1->Name,t_specifier,fp2);
				if(val==false)
				{
					SymbolInfo* prev=st.Look_up($1->Name);
						if(prev->is_parameter==false)
						{
							if(prev->Type==t_specifier)
							{
								errorcount++;
								fprintf(fp4,"Line# %d: Redefinition of parameter '%s'\n",$1->startLine,$1->Name.c_str());
							}
							else
							{
								errorcount++;
								fprintf(fp4,"Line# %d: Conflicting types for'%s'\n",$1->startLine,$1->Name.c_str());
							}
						}
				}
				$$->add_children($1);
					if(st.get_curr_table_id()=="1")
					{
						f_specifier="NULL";
					}
				//fprintf(fp3,"%s	%s	<Line:%d-%d>\n",$$->Type.c_str(),$$->Name.c_str(),$$->startLine,$$->endLine);
				//fprintf(fp3,"iiiii");
				//say_hello();
				//fprintf(fp3,"%s, Line:%d",$$->Type.c_str(),$$->startLine);
			}
 		  ;
 		  
statements : statement {
		fprintf(fp2,"statements : statement \n");
		$$=new SymbolInfo();
		$$=new SymbolInfo();
		SymbolInfo* sli=new SymbolInfo();
		sli->Rules="statements : statement";
		sli->Name="NULL";
		sli->terminal=false;
		sli->startLine=$1->startLine;
		sli->endLine=$1->endLine;
		$$=sli;	
		$$->add_children($1);
		//fprintf(fp3,"%s	%s	<Line:%d-%d>\n",$$->Type.c_str(),$$->Name.c_str(),$$->startLine,$$->endLine);
}

	   | statements statement {
			fprintf(fp2,"statements:  statements statement \n ");
			$$=new SymbolInfo();
			SymbolInfo* sli=new SymbolInfo();
			sli->Rules="statements:  statements statement";
			sli->Name="NULL";
			sli->terminal=false;
			sli->startLine=$1->startLine;
			sli->endLine=$2->endLine;
			$$=sli;	
			$$->add_children($1);
			$$->add_children($2);	
			//fprintf(fp3,"%s	%s	<Line:%d-%d>\n",$$->Type.c_str(),$$->Name.c_str(),$$->startLine,$$->endLine);			
	   }
	   ;
	   
statement : var_declaration {
			fprintf(fp2,"statement : var_declaration \n");
			$$=new SymbolInfo();
			SymbolInfo* sli=new SymbolInfo();
			sli->Rules="statement : var_declaration";
			sli->Name="NULL";
			sli->terminal=false;
			sli->startLine=$1->startLine;
			sli->endLine=$1->endLine;
			$$=sli;	
			$$->add_children($1);
}
	  | expression_statement {
			fprintf(fp2,"statement : expression_statement \n");
			$$=new SymbolInfo();
			SymbolInfo* sli=new SymbolInfo();
			sli->Rules="statement : expression_statement";
			sli->Name="NULL";
			sli->terminal=false;
			sli->startLine=$1->startLine;
			sli->endLine=$1->endLine;
			$$=sli;	
			$$->add_children($1);
			//std::cout<<" statement:  expression_statement "<<endl;
	  }
	  | compound_statement {
			fprintf(fp2,"statement :  compound_statement \n");
			
			$$=new SymbolInfo();
			SymbolInfo* sli=new SymbolInfo();
			sli->Rules="statement :  compound_statement";
			sli->Name="NULL";
			sli->terminal=false;
			sli->startLine=$1->startLine;
			sli->endLine=$1->endLine;
			$$=sli;	
			$$->add_children($1);
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
			fprintf(fp2,"statement :  FOR LPAREN expression_statement expression_statement expression RPAREN statement \n ");
			$$=new SymbolInfo();
			SymbolInfo* sli=new SymbolInfo();
			sli->Rules="statement :  FOR LPAREN expression_statement expression_statement expression RPAREN statement";
			sli->Name="NULL";
			sli->terminal=false;
			sli->startLine=$1->startLine;
			sli->endLine=$7->endLine;
			$$=sli;	
			$$->add_children($1);
			$$->add_children($2);
			$$->add_children($3);
			$$->add_children($4);
			$$->add_children($5);
			$$->add_children($6);
			$$->add_children($7);
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE{
			fprintf(fp2,"statement :  IF LPAREN expression RPAREN statement \n");
			$$=new SymbolInfo();
			SymbolInfo* sli=new SymbolInfo();
			sli->Rules="statement :  IF LPAREN expression RPAREN statement";
			sli->Name="NULL";
			sli->terminal=false;
			sli->startLine=$1->startLine;
			sli->endLine=$5->endLine;
			$$=sli;	
			
			$$->add_children($1);
			$$->add_children($2);
			$$->add_children($3);
			$$->add_children($4);
			$$->add_children($5);
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement {
			fprintf(fp2,"statement :  IF LPAREN expression RPAREN statement ELSE statement \n");
			$$=new SymbolInfo();
			SymbolInfo* sli=new SymbolInfo();
			sli->Rules="statement :  IF LPAREN expression RPAREN statement ELSE statement";
			sli->Name="NULL";
			sli->terminal=false;
			sli->startLine=$1->startLine;
			sli->endLine=$7->endLine;
			$$=sli;	
			$$->add_children($1);
			$$->add_children($2);
			$$->add_children($3);
			$$->add_children($4);
			$$->add_children($5);
			$$->add_children($6);
			$$->add_children($7);
	  }
	  | WHILE LPAREN expression RPAREN statement {
			fprintf(fp2,"statement : WHILE LPAREN expression RPAREN statement \n");
			$$=new SymbolInfo();
			SymbolInfo* sli=new SymbolInfo();
			sli->Rules="statement : WHILE LPAREN expression RPAREN statement";
			sli->Name="NULL";
			sli->terminal=false;
			sli->startLine=$1->startLine;
			sli->endLine=$5->endLine;
			$$=sli;	
			$$->add_children($1);
			$$->add_children($2);
			$$->add_children($3);
			$$->add_children($4);
			$$->add_children($5);
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {
			fprintf(fp2,"statement : PRINTLN LPAREN ID RPAREN SEMICOLON \n");
			$$=new SymbolInfo();
			SymbolInfo* sli=new SymbolInfo();
			sli->Rules="statement : PRINTLN LPAREN ID RPAREN SEMICOLON";
			sli->Name="NULL";
			sli->terminal=false;
			sli->startLine=$1->startLine;
			sli->endLine=$5->endLine;
			$$=sli;	
			$$->add_children($1);
			$$->add_children($2);
			$$->add_children($3);
			$$->add_children($4);
			$$->add_children($5);
	  }
	
	  | RETURN expression SEMICOLON {
			fprintf(fp2,"statement : RETURN expression SEMICOLON \n");
			$$=new SymbolInfo();
			SymbolInfo* sli=new SymbolInfo();
			sli->Rules="statement : RETURN expression SEMICOLON";
			sli->Name="NULL";
			sli->terminal=false;
			sli->startLine=$1->startLine;
			sli->endLine=$3->endLine;
			$$=sli;	
			$$->add_children($1);
			$$->add_children($2);
			$$->add_children($3);
	  }

	  ;
	  
expression_statement 	: SEMICOLON	{
			fprintf(fp2,"expression_statement 	: SEMICOLON	\n");
			$$=new SymbolInfo();
			SymbolInfo* sli=new SymbolInfo();
			sli->Rules="expression_statement 	: SEMICOLON";
			sli->Name="NULL";
			sli->terminal=false;
			sli->startLine=$1->startLine;
			sli->endLine=$1->endLine;
			$$=sli;	
			$$->add_children($1);
			//std::cout<<"expression_statement: SEMICOLON"<<endl;
}		
			| expression SEMICOLON {
				fprintf(fp2,"expression_statement 	: expression SEMICOLON \n ");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="expression_statement 	: expression SEMICOLON";
				sli->Name="NULL";
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$2->endLine;
				$$=sli;	
				$$->add_children($1);
				$$->add_children($2);
				//std::cout<<"expression_statement:  expression SEMICOLON"<<endl;
			}
			;
	  
variable : ID {
				fprintf(fp2,"variable : ID \n");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="variable : ID";
				sli->Name=$1->Name;
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$1->endLine;
				//sli->stackOffset=3;
				sli->Type=t_specifier;
				$$=sli;	
				$$->add_children($1);
				SymbolInfo* ob=st.Look_up($1->Name);
				if(ob==NULL)
				{
					$$->Type=$1->Type;
					bool v=is_present_in_curr_parameters($1->Name);
					//std::cout<<v<<"bbbbbb"<<endl;
					if(v==false)
					{
						fprintf(fp4,"Line# %d: Undeclared variable '%s'\n",$1->startLine,$1->Name.c_str());
						errorcount++;
					}
						
					else  
					{
						$$->Type=get_type_of_parameter($1->Name);
					}	
						
				}
				else if(ob!=NULL)
				{
					if(ob->Type!="INT"&&ob->Type!="FLOAT")
					{
						arrayFlag=1;
						errorcount++;
						fprintf(fp4,"Line# %d: %s is not an INT\n",$1->startLine,$1->Name.c_str());
					}
					$$->Type=ob->Type;
					//std::cout<<"Hello "<<$$->Name<<" dddd "<<$$->Type<<endl;
				}

				//std::cout<<$$->Name<<" name type "<<$$->Type<<endl;
}		
	 | ID LTHIRD expression RTHIRD {
				fprintf(fp2,"variable : ID LSQUARE expression RSQUARE \n ");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="variable : ID LSQUARE expression RSQUARE";
				sli->Name=$1->Name;
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$4->endLine;
				sli->Type=t_specifier;
				if($1->is_array==1)
				{
					sli->arrayindex=$3->Name;
				}
				$$=sli;	
				$$->add_children($1);
				$$->add_children($2);
				$$->add_children($3);
				$$->add_children($4);
				if($3->Type!="INT")
				{
					errorcount++;
					fprintf(fp4,"Line# %d: Array subscript is not an integer\n",$3->startLine);
				}
				SymbolInfo* ob=st.Look_up($1->Name);
				$$->Type=ob->Type;
				if(ob!=NULL)
				{
					//cout<<ob->Type<<"haahahah"<<endl;
					if(ob->is_array==false)
					{
						errorcount++;
						fprintf(fp4,"Line# %d: '%s' is not an ARRAY\n",$1->startLine,$1->Name.c_str());
					}
				}
				else
				{
					errorcount++;
					fprintf(fp4,"Line# %d: Undeclared ARRAY '%s'\n",$1->startLine,$1->Name.c_str());
				}
				
	 }
	 ;
	 
expression : logic_expression {
				fprintf(fp2,"expression : logic_expression \n ");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="expression : logic_expression";
				sli->Name=$1->Name;
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$1->endLine;
				sli->Type=$1->Type;
				$$=sli;	
				$$->add_children($1);
				if($1->is_function==true && $1->return_type=="NULL")
				{
					errorcount++;
					fprintf(fp4,"Line# %d: Undeclared function '%s'\n",$1->startLine,$1->function_name.c_str());
				}
				else 
				{
					SymbolInfo* sf=new SymbolInfo();
					sf=st.Look_up($1->function_name);
					//std::cout<<"I am Here"<<endl;
					//print_parameters($1);
					//std:: cout<<"Bye"<<endl;
					//std::cout<<"Hello"<<endl;
					if(sf!=NULL &&sf->return_type!="VOID")
					{
						check_parameters_Number(sf,$1,$1->startLine);
						compare_parameters_type(sf,$1,$1->startLine);
					}
				}
}	
	   | variable ASSIGNOP logic_expression {
				fprintf(fp2,"expression : variable ASSIGNOP logic_expression \n");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="expression : variable ASSIGNOP logic_expression";
				sli->Name=$3->Name;
				sli->arrayindex=$1->arrayindex;
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$3->endLine;
				sli->Type=$1->Type;
				$$=sli;	
				$$->add_children($1);	
				$$->add_children($2);
				$$->add_children($3);
				
				//std::cout<<$3->is_function<<" Irtiaz "<<$3->return_type<<endl;

				//cout<<$3->Type<<" Tyyy"<<endl;
				//cout<<"ekhane to mone hoy ashbe sure na"<<endl;
				
				if($3->is_function==true)
				{
					if($3->return_type=="VOID")
					{
						errorcount++;
						fprintf(fp4,"Line# %d: Void cannot be used in expression\n",$1->startLine);
					}
					else if($3->return_type=="NULL")
					{
						errorcount++;
						fprintf(fp4,"Line# %d: Undeclared function %s\n",$1->startLine,$3->function_name.c_str());
					}
			
					SymbolInfo* sf=new SymbolInfo();
					sf=st.Look_up($3->function_name);
					if(sf!=NULL &&sf->return_type!="VOID")
					{
						
						check_parameters_Number(sf,$3,$3->startLine);
						compare_parameters_type(sf,$3,$3->startLine);
					}
				}
				else
				{
					if(modulaserrorFlag==0)
					{
						bool value=is_factors_present($3,$1->startLine);
						if(value==true)
						{
							//std::cout<<"Ajaira"<<endl;
							SymbolInfo* ss=new SymbolInfo();
							ss=st.Look_up($1->Name);
							if(ss!=NULL)
							{
								if(ss->Type=="ARRAY" &&arrayFlag==0)ss->Type=ss->real_Type;
								//std::cout<<ss->Name<<" "<<ss->Type<<endl;
								value=check_factors_Type(ss,$3,$1->startLine);
							}

						}
					}
			
				}
				arrayFlag=0;
				modulaserrorFlag=0;
	   } 	
	   ;
			
logic_expression : rel_expression {
				fprintf(fp2,"logic_expression : rel_expression \n");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="logic_expression : rel_expression";
				sli->Name=$1->Name;
				sli->copy_factors($1);
				sli->is_function=$1->is_function;
				sli->return_type=$1->return_type;
				sli->terminal=false;
				sli->function_name=$1->function_name;
				sli->Type=$1->Type;
				sli->startLine=$1->startLine;
				sli->endLine=$1->endLine;
				$$=sli;	
				$$->add_children($1);
				$$->copy_parameters($1,fp2,0);
				//::cout<<"logic_expression : rel_expression "<<endl;
}	
		 | rel_expression LOGICOP rel_expression {
				fprintf(fp2,"logic_expression : rel_expression LOGICOP rel_expression \n");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="logic_expression : rel_expression LOGICOP rel_expression";
				sli->Name="NULL";
				sli->terminal=false;
				sli->copy_factors($1);
				sli->copy_factors($3);
				sli->startLine=$1->startLine;
				sli->endLine=$3->endLine;
				sli->function_name=$1->function_name;
				sli->Type=$1->Type;
				$$=sli;	
				$$->add_children($1);	
				$$->add_children($2);
				$$->add_children($3);
				$$->copy_parameters($1,fp2,0);
				$$->copy_parameters($3,fp2,0);
		 }	
		 ;
			
rel_expression	: simple_expression {
				fprintf(fp2,"rel_expression	: simple_expression \n");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="rel_expression	: simple_expression";
				sli->Name=$1->Name;
				sli->terminal=false;
				sli->Type=$1->Type;
				sli->copy_factors($1);
				sli->is_function=$1->is_function;
				sli->function_name=$1->function_name;
				sli->return_type=$1->return_type;
				sli->startLine=$1->startLine;
				sli->endLine=$1->endLine;
				$$=sli;	
				$$->add_children($1);
				$$->copy_parameters($1,fp2,0);
				//std::cout<<"rel_expression	: simple_expression\n "<<endl;
}
		| simple_expression RELOP simple_expression	{
				fprintf(fp2,"rel_expression	: simple_expression RELOP simple_expression \n");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="rel_expression	: simple_expression RELOP simple_expression";
				sli->Name="NULL";
				sli->terminal=false;
				sli->copy_factors($1);
				sli->copy_factors($3);
				sli->function_name=$1->function_name;
				sli->is_function=$1->is_function;
				sli->return_type=$1->return_type;
				sli->Type=$1->Type;
				sli->startLine=$1->startLine;
				sli->endLine=$3->endLine;
				$$=sli;	
				$$->add_children($1);	
				$$->add_children($2);
				$$->add_children($3);
				$$->copy_parameters($1,fp2,0);
				$$->copy_parameters($3,fp2,0);
		}
		;
				
simple_expression : term {
				fprintf(fp2,"simple_expression : term \n");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="simple_expression : term";
				sli->Name=$1->Name;
				//cout<<$1->Name<<"kkkkkkkkkkkk"<<endl;
				sli->function_name=$1->function_name;
				sli->Type=$1->Type;
				sli->copy_factors($1);
				sli->is_function=$1->is_function;
				sli->return_type=$1->return_type;
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$1->endLine;
				$$=sli;	
				$$->add_children($1); 
				$$->copy_parameters($1,fp2,0);
	
				//std::cout<<"simple_expression : term \n"<<endl;
}
		  | simple_expression ADDOP term {
				fprintf(fp2,"simple_expression : simple_expression ADDOP term \n");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="simple_expression : simple_expression ADDOP term";
				sli->Name=$1->Name;
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$3->endLine;
				sli->Type=$1->Type;
				sli->copy_factors($1);
				sli->copy_factors($3);
				sli->function_name=$3->function_name;
				sli->is_function=$3->is_function;
				sli->return_type=$3->return_type;
				$$=sli;	
				$$->add_children($1);	
				$$->add_children($2);
				$$->add_children($3);	
		  }
		  ;
					
term :	unary_expression {
				fprintf(fp2,"term :	unary_expression \n ");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="term :	unary_expression";
				sli->Name=$1->Name;
				sli->terminal=false;
				sli->Type=$1->Type;
				sli->copy_factors($1);
				sli->function_name=$1->function_name;
				sli->is_function=$1->is_function;
				sli->return_type=$1->return_type;
				sli->startLine=$1->startLine;
				sli->endLine=$1->endLine;
				$$=sli;	
				$$->add_children($1);
				$$->copy_parameters($1,fp2,0);

				//std::cout<<"term :	unary_expression \n"<<endl;
}
     |  term MULOP unary_expression {
				fprintf(fp2,"term:  term MULOP unary_expression \n ");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="term:  term MULOP unary_expression";
				sli->Name="NULL";
				sli->Type=$1->Type;
				sli->terminal=false;
				sli->copy_factors($1);
				sli->copy_factors($3);
				sli->function_name=$3->function_name;
				sli->is_function=$3->is_function;
				sli->return_type=$3->return_type;
				sli->startLine=$1->startLine;
				sli->endLine=$3->endLine;
				$$=sli;	
				$$->add_children($1);	
				$$->add_children($2);
				$$->add_children($3);
				if($2->Name=="%")
				{
					if($1->Type!="INT"||$3->Type!="INT")
					{
						modulaserrorFlag=1;
						errorcount++;
						fprintf(fp4,"Line# %d: The Operand of modulas operator must be Integer\n",$1->startLine);
					}
					
				}
				if($2->Name=="/"||$2->Name=="%")
				{
					//std::cout<<$2->Name<<" yyy "<<$3->Name<<endl;
					if($3->Name=="0")
					{
						//std::cout<<"JJjJJJ"<<endl;
						errorcount++;
						fprintf(fp4,"Line# %d:  Warning: division by zero i=0f=1Const=0\n",$1->startLine);
					}
				}
				$$->copy_parameters($3,fp2,0);
				$$->copy_parameters($1,fp2,0);
	 }
     ;

unary_expression : ADDOP unary_expression {
				fprintf(fp2,"unary_expression : ADDOP unary_expression \n ");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="unary_expression : ADDOP unary_expression";
				sli->Name=$2->Name;
				sli->terminal=false;
				sli->Type=$2->Type;
				sli->function_name=$2->function_name;
				sli->is_function=$2->is_function;
				sli->return_type=$2->return_type;
				sli->copy_factors($2);
				sli->startLine=$1->startLine;
				sli->endLine=$2->endLine;
				$$=sli;	
				$$->add_children($1);	
				$$->add_children($2);
}
		 | NOT unary_expression {
				fprintf(fp2,"unary_expression : NOT unary_expression \n");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="unary_expression : NOT unary_expression";
				sli->Name=$2->Name;
				sli->Type=$2->Type;
				sli->function_name=$2->function_name;
				sli->terminal=false;
				sli->is_function=$2->is_function;
				sli->return_type=$2->return_type;
				sli->copy_factors($2);
				sli->startLine=$1->startLine;
				sli->endLine=$2->endLine;
				$$=sli;	
				$$->add_children($1);
				$$->add_children($2);
		 }
		 | factor {
				fprintf(fp2,"unary_expression : factor \n");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="unary_expression : factor";
				sli->Name=$1->Name;
				sli->terminal=false;
				sli->function_name=$1->function_name;
				sli->Type=$1->Type;
				sli->startLine=$1->startLine;
				sli->endLine=$1->endLine;
				sli->copy_factors($1);
				sli->is_function=$1->is_function;
				sli->return_type=$1->return_type;
				//std::cout<<"factor "<<sli->function_name<<endl;
				$$=sli;	
				$$->add_children($1);
				$$->copy_parameters($1,fp2,0);
				//cout<<"I am "<<endl;
				//print_parameters($$);
				//cout<<"KkKKKk"<<endl;
				//show_factors($$);
		 }
		 ;
	
factor	: variable {
				fprintf(fp2,"factor	: variable \n ");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				SymbolInfo* childFactor=new SymbolInfo();
				childFactor=$1;
				sli->Rules="factor	: variable";
				sli->Name=$1->Name;
				sli->Type=$1->Type;
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$1->endLine;
				//std:: cout<<sli->Name<<" hahahah "<<sli->Type<<endl;
				SymbolInfo* getObj=st.Look_up($1->Name);
				sli->add_children($1);
				if(getObj!=NULL)
				{
					childFactor->Type=getObj->Type;
					childFactor->Name=getObj->Name;
					childFactor->is_array=getObj->is_array;
					//std::cout<<childFactor->Name<<" hhgggjj "<<childFactor->is_array<<endl;
				}
				
				else childFactor->Type="NULL";
				sli->add_factor(childFactor);
				$$=sli;	
				$$->add_parameters($1);
				
}
	| ID LPAREN argument_list RPAREN {
				fprintf(fp2,"factor	: ID LPAREN argument_list RPAREN \n ");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="factor	: ID LPAREN argument_list RPAREN";
				sli->Name="NULL";
				sli->Type=$1->Type;
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$4->endLine;
				sli->is_function=true;
				sli->function_name=$1->Name;
				//std::cout<<$1->Name<<" redwan "<<endl;
				SymbolInfo* getObj=st.Look_up($1->Name);
				if(getObj!=NULL){
					sli->return_type=getObj->return_type;
					sli->is_array=getObj->is_array;
					///std::cout<<sli->Name<<"hkkk "<<sli->is_array<<endl;
				}	
				else sli->return_type="NULL";
				$$=sli;	
				$$->add_children($1);	
				$$->add_children($2);
				$$->add_children($3);
				$$->add_children($4);
				$$->copy_parameters($3,fp2,0);
	}
	| LPAREN expression RPAREN {
				fprintf(fp2,"factor	: LPAREN expression RPAREN \n ");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="factor	: LPAREN expression RPAREN";
				sli->Name="NULL";
				sli->Type=$2->Type;
				sli->is_function=true;
				//sli->return_type="INT";
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$3->endLine;
				
				$$=sli;	
				$$->add_children($1);	
				$$->add_children($2);
				$$->add_children($3);	
	}
	| CONST_INT {
				fprintf(fp2,"factor	: CONST_INT \n");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				SymbolInfo* childFactor=new SymbolInfo();
				childFactor=$1;
				childFactor->Type="INT";
				sli->Rules="factor	: CONST_INT";
				sli->Name=$1->Name;
				sli->Type="INT";
				sli->return_type="INT";
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$1->endLine;
				sli->add_factor(childFactor);
				$$=sli;	
				$$->add_children($1);
				$$->add_parameters($1);
	}
	| CONST_FLOAT {
				fprintf(fp2,"factor	: CONST_FLOAT \n");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				SymbolInfo* childFactor=new SymbolInfo();
				childFactor=$1;
				childFactor->Type="FLOAT";
				sli->Rules="factor	: CONST_FLOAT";
				sli->Name=$1->Name;
				sli->Type="FLOAT";
				sli->return_type="INT";
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$1->endLine;
				sli->add_factor(childFactor);
				$$=sli;	
				$$->add_children($1);
				$$->add_parameters($1);	
	}
	| variable INCOP {
				fprintf(fp2,"factor	: variable INCOP \n");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				SymbolInfo* childFactor=new SymbolInfo();
				childFactor=$1;
				sli->Rules="factor	: variable INCOP";
				sli->Name=$1->Name;
				sli->Type=$1->Type;
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$2->endLine;
				SymbolInfo* getObj=st.Look_up($1->Name);
				if(getObj!=NULL)
				{
					childFactor->Type=getObj->Type;
				}
				else childFactor->Type="NULL";
				$$=sli;	
				$$->add_children($1);
				$$->add_children($2);
				$$->add_factor(childFactor);
				//std::cout<<childFactor->Name<<" hheheheheh"<<childFactor->Type<<endl;
	} 
	| variable DECOP {
				fprintf(fp2,"factor	: variable DECOP \n");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				SymbolInfo* childFactor=new SymbolInfo();
				childFactor=$1;
				sli->Rules="factor	: variable DECOP";
				sli->Name=$1->Name;
				sli->Type=$1->Type;
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$2->endLine;
				SymbolInfo* getObj=st.Look_up($1->Name);
				if(getObj!=NULL)
				{
					childFactor->Type=getObj->Type;
				}
				else childFactor->Type="NULL";
				$$=sli;	
				$$->add_children($1);	
				$$->add_children($2);
				$$->add_factor(childFactor);
	}
	;
	
argument_list : arguments {
				//cout<<"Nooo"<<endl;
				fprintf(fp2,"argument_list : arguments \n");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="argument_list : arguments";
				sli->Name="NULL";
				sli->Type=$1->Type;
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$1->endLine;
				$$=sli;	
				$$->add_children($1);	
				for(int i=0;i<$1->parameters.size();i++)
				{
					if($1->parameters[i]->Type=="ARRAY")
					{
						SymbolInfo* soss=st.Look_up($1->parameters[i]->Name);
						if(soss!=NULL)$1->parameters[i]->Type=soss->real_Type;
					}
					
					//cout<<i<<" mm ";
				}
				//cout<<endl;
				$$->copy_parameters($1,fp2,0);
				//print_parameters($$);
}
| {
	SymbolInfo* si=new SymbolInfo();
	$$->copy_parameters(si,fp2,0);
	//cout<<"JJJJJJJ"<<endl;
}
;
	
arguments : arguments COMMA logic_expression {
				fprintf(fp2,"arguments : arguments COMMA logic_expression \n");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="arguments : arguments COMMA logic_expression";
				sli->Name="NULL";
				sli->terminal=false;
				sli->Type=$3->Type;
				sli->startLine=$1->startLine;
				sli->endLine=$3->endLine;
				$$=sli;	
				$$->add_children($1);	
				$$->add_children($2);
				$$->add_children($3);
			

				/*for(int i=0;i<$1->parameters.size();i++)
				{
					if($3->parameters[i]->Type=="ARRAY")
					{
						SymbolInfo* soss=st.Look_up($3->parameters[i]->Name);
						if(soss!=NULL)$3->parameters[i]->Type=soss->real_Type;
					}
				}*/
				for(int i=0;i<$1->parameters.size();i++)
				{
					if($1->parameters[i]->Type=="ARRAY")
					{
						SymbolInfo* soss=st.Look_up($1->parameters[i]->Name);
						if(soss!=NULL)$1->parameters[i]->Type=soss->real_Type;
					}
				}
				$$->copy_parameters($3,fp2,0);
				$$->copy_parameters($1,fp2,0);
				//cout<<"IIiII"<<endl;
				//std::cout<<"KkKKK"<<endl;
				//print_parameters($$);
				//std::cout<<"Hello"<<endl;
}
	      | logic_expression {
				fprintf(fp2,"arguments : logic_expression \n ");
				$$=new SymbolInfo();
				SymbolInfo* sli=new SymbolInfo();
				sli->Rules="arguments : logic_expression";
				sli->Name=$1->Name;
				sli->Type=$1->Type;
				sli->terminal=false;
				sli->startLine=$1->startLine;
				sli->endLine=$1->endLine;
				$$=sli;
				SymbolInfo* sss=new SymbolInfo();
				sss=$1;
				if(sss->Type=="ARRAY")sss->Type=sss->real_Type;	
				for(int i=0;i<$1->parameters.size();i++)
				{
					if($1->parameters[i]->Type=="ARRAY")
					{
						SymbolInfo* soss=st.Look_up($1->parameters[i]->Name);
						if(soss!=NULL)$1->parameters[i]->Type=soss->real_Type;
					}
				}
				$$->add_children(sss);
				$$->copy_parameters($1,fp2,0);
				//cout<<"OOOOOO"<<endl;
				//print_parameters($$);
				//std::cout<<"Hello"<<endl;
		  }
	      ;
 

%%



int main(int argc,char *argv[])
{

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

	fp2= fopen("log.txt","w");
	fclose(fp2);
	fp3= fopen("parsetree.txt","w");
	fclose(fp3);
	fp4= fopen("error.txt","w");
	fclose(fp4);
	//fp5= fopen("assembly.txt","w");
	//fclose(fp5);
	
	fp2= fopen("log.txt","a");
	fp3= fopen("parsetree.txt","a");
	fp4= fopen("error.txt","a");
	//fp5= fopen("assembly.txt","w")
	

	yyin=fp;
	yyparse();
	

	fclose(fp2);
	fclose(fp3);
	fclose(fp4);
	//fclose(fp5);

	return 0;
	//#define YYSTYPE SymbolInfo*
}

