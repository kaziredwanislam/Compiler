#include<iostream>
#include<cstdlib>
#include<sstream>
#include<cstring>
#include<fstream>
#include <vector>
#include <algorithm>
#include <cstdio>
typedef unsigned long long ul;
using namespace std;

static unsigned long long sdbm(string str)
{
    unsigned long long hash=0;
    int c=0;
    while((c!=str.length()))
    {
        hash=str[c]+(hash<<6)+(hash<<16)-hash;
        //hash=hash%total_buckets;
        c++;
    }
    return hash;
}


class SymbolInfo
{
    public:
    string Name="NULL";
    string Type="NULL";
    string real_Type="NULL";
    string Rules;
    int startLine;
    int arrayIndex=0;
    string arrayindex="";
    string function_name="NULL";
    int endLine;
    int stackOffset=0;
    bool terminal=true;
    bool isVoid=false;
    bool is_function=false;
    bool is_array=false;
    bool is_parameter=false;
    string return_type="NULL";
    vector<SymbolInfo*>children;
    vector<SymbolInfo*>parameters;
    vector<SymbolInfo*>factorList;
    //public:
        SymbolInfo* next=NULL;
        SymbolInfo* prev=NULL;
        int position=0;
        int hashindex=0;
        string scopeTable_Id;
        SymbolInfo()
        {

        }

        string get_real_Type()
        {
            return real_Type;
        }

        string get_Rules()
        {
            return Rules;
        }

        void set_function()
        {
            is_function=true;
            //std::cout<<is_function<<endl;
        }

        void set_Name(string w)
        {
            Name=w;
        }
        void set_Type(string t)
        {
            Type=t;
        }
        string get_Name()
        {
            return Name;
        }
        string get_Type()
        {
            return Type;
        }

        void add_children(SymbolInfo* ob)
        {
            children.push_back(ob);
            //cout<<get_Name()<<" "<<get_Type()<<" "<<ob->get_Type()<<endl;
        }

        void add_parameters(SymbolInfo* ob)
        {
            
            parameters.push_back(ob);
     
        }

       void copy_parameters(SymbolInfo* ob,FILE* fp4,int line_no)
        {
           //parameters.clear();
            for(int i=0;i<ob->parameters.size();i++)
            {
              
                add_parameters(ob->parameters[i]);
                    
            }
                //cout<<ob->Name<<" yeah"<<endl;
        }


        void add_factor(SymbolInfo* obj)
        {
            factorList.push_back(obj);
        }
        
        void copy_factors(SymbolInfo* obj)
        {
            for(int i=0;i<obj->factorList.size();i++)
            {
                factorList.push_back(obj->factorList[i]);
            }
        }

        bool is_terminal()
        {
            return terminal;
        }

        vector<SymbolInfo*> get_all_parameters()
        {
            return parameters;
        }

};


class scopeTable
{
    ul total_buckets;
    int hashcol=-1;
    int hashrow=-1;
    public:
        SymbolInfo** hashara;
        scopeTable* parentScope=NULL;
        scopeTable* childScope=NULL;
        string id;
        int no_of_child=0;
        scopeTable(ul size,string parent_id,int prev_id)
        {
            total_buckets=size;
            hashara=new SymbolInfo*[total_buckets];
            for(int i=0;i<total_buckets;i++)
            {
                hashara[i]=NULL;
            }
            if(parent_id=="0")
            {
                id=to_string(1);
            }
            else
            {
                int t=prev_id+1;
                //id=parent_id+"."+to_string(prev_id);
                id=std::to_string(t);
            }

        }

       ~scopeTable()
       {
            for(int i=0;i<total_buckets;i++)
            {
                SymbolInfo* current_ptr=hashara[i];
                if(current_ptr!=NULL)
                {
                    while(current_ptr->next!=NULL)
                    {
                        current_ptr=current_ptr->next;
                    }
                    while(current_ptr->prev!=NULL)
                    {
                        current_ptr=current_ptr->prev;
                        delete(current_ptr->next);
                    }
                    if(current_ptr->prev==NULL)delete(current_ptr);
                }

            }
            delete []hashara;
       }

        SymbolInfo* Look_up(string w)
        {
            SymbolInfo* p=NULL;
            ul hashindex=sdbm(w);
            hashindex=hashindex%total_buckets;
            p=hashara[hashindex];
            int hasfound=0;
            int Count=0;
            while(p!=NULL)
            {
                //cout<<"Yes"<<endl;
                if(p->get_Name()==w)
                {
                    hasfound=1;
                    break;
                }
                p=p->next;
                Count++;
            }
            if(hasfound==1)
            {
                hashcol=Count;
                hashrow=hashindex;
                p->position=Count;
                return p;
            }
            else
            {
                return NULL;
            }
        }

        bool Insert_secondpass(string n,string t,int stackpointer)
        {
                        SymbolInfo* checkptr=Look_up(n);
            //cout<<"ooooo"<<endl;
            if(checkptr==NULL)
            {
                SymbolInfo *ob=new SymbolInfo();
                ob->set_Name(n);
                ob->set_Type(t);
                ob->stackOffset=stackpointer;
                ob->scopeTable_Id=id;
                ul hashpos=sdbm(n);
                //cout<<hashpos<<"jkl"<<endl;
                hashpos=hashpos%total_buckets;
                //cout<<hashpos<<"next"<<endl;
                ob->hashindex=hashpos;
                SymbolInfo* curr_pos=hashara[hashpos];
                if(curr_pos==NULL)
                {
                    hashara[hashpos]=ob;
                    //cout<<hashpos<<endl;
                    return true;
                }
                while(curr_pos->next!=NULL)
                {
                    curr_pos=curr_pos->next;
                    ob->position++;
                }
                ob->position++;
                curr_pos->next=ob;
                curr_pos->next->prev=curr_pos;
                curr_pos=ob;
                //cout<<hashpos<<"kkkk"<<endl;
                return true;
            }
            else
            {
                //fprintf(outfile,"\t%s already exists in the current ScopeTable\n",n.c_str());
                return false;
            }
        }

        bool Insert(string n,string t,bool is_function,string return_type,FILE* outfile,bool is_array,bool is_parameter)
        {
            //cout<<"uhuhu"<<endl;
            SymbolInfo* checkptr=Look_up(n);
            //cout<<"ooooo"<<endl;
            if(checkptr==NULL)
            {
                SymbolInfo *ob=new SymbolInfo();
                ob->set_Name(n);
                ob->set_Type(t);
                if(is_function==true)
                {
                    ob->is_function=true;
                    ob->return_type=t;
                }
                if(is_array==true)
                {
                    ob->is_array=true;
                    ob->Type="ARRAY";
                    ob->real_Type=t;
                }
                if(is_parameter==true)
                {
                    ob->is_parameter=true;
                }
                ob->scopeTable_Id=id;
                ul hashpos=sdbm(n);
                //cout<<hashpos<<"jkl"<<endl;
                hashpos=hashpos%total_buckets;
                //cout<<hashpos<<"next"<<endl;
                ob->hashindex=hashpos;
                SymbolInfo* curr_pos=hashara[hashpos];
                if(curr_pos==NULL)
                {
                    hashara[hashpos]=ob;
                    //cout<<hashpos<<endl;
                    return true;
                }
                while(curr_pos->next!=NULL)
                {
                    curr_pos=curr_pos->next;
                    ob->position++;
                }
                ob->position++;
                curr_pos->next=ob;
                curr_pos->next->prev=curr_pos;
                curr_pos=ob;
                //cout<<hashpos<<"kkkk"<<endl;
                return true;
            }
            else
            {
                //fprintf(outfile,"\t%s already exists in the current ScopeTable\n",n.c_str());
                return false;
            }
        }

        
        bool Insert_Function(string n,string t,bool is_function,string return_type,FILE* outfile,bool is_array,bool is_parameter,vector<SymbolInfo*>params)
        {
            //cout<<"uhuhu"<<endl;
            SymbolInfo* checkptr=Look_up(n);
            //cout<<"ooooo"<<endl;
            if(checkptr==NULL)
            {
                SymbolInfo *ob=new SymbolInfo();
                ob->set_Name(n);
                ob->set_Type(t);
                if(is_function==true)
                {
                    ob->is_function=true;
                    ob->return_type=t;
                    for(int i=0;i<params.size();i++)
                    {
                        ob->parameters.push_back(params[i]);
                    }
                }
                if(is_array==true)
                {
                    ob->is_array=true;
                    ob->Type="ARRAY";
                }
                if(is_parameter==true)
                {
                    ob->is_parameter=true;
                }
                ob->scopeTable_Id=id;
                ul hashpos=sdbm(n);
                //cout<<hashpos<<"jkl"<<endl;
                hashpos=hashpos%total_buckets;
                //cout<<hashpos<<"next"<<endl;
                ob->hashindex=hashpos;
                SymbolInfo* curr_pos=hashara[hashpos];
                if(curr_pos==NULL)
                {
                    hashara[hashpos]=ob;
                    //cout<<hashpos<<endl;
                    return true;
                }
                while(curr_pos->next!=NULL)
                {
                    curr_pos=curr_pos->next;
                    ob->position++;
                }
                ob->position++;
                curr_pos->next=ob;
                curr_pos->next->prev=curr_pos;
                curr_pos=ob;
                //cout<<hashpos<<"kkkk"<<endl;
                return true;
            }
            else
            {
                //fprintf(outfile,"\t%s already exists in the current ScopeTable\n",n.c_str());
                return false;
            }
        }

        bool Delete(string w,int &row,int &pos)
        {
            SymbolInfo* ptr=Look_up(w);
            //cout<<hashrow<<" hhh "<<hashcol<<endl;
            if(ptr!=NULL)
            {
                SymbolInfo *curr_place=hashara[hashrow];
                //cout<<hashrow<<" kkk "<<hashcol<<endl;
                row=curr_place->hashindex;
                pos=curr_place->position;
                for(int i=0;i<hashcol;i++)
                {
                    curr_place=curr_place->next;
                }
                //cout<<hashcol<<"jjjjj"<<endl;
                if(curr_place->prev==NULL &&curr_place->next==NULL)
                {
                    hashara[hashrow]=NULL;
                }
                else if(curr_place->prev==NULL)
                {
                    hashara[hashrow]=curr_place->next;
                    curr_place->prev=NULL;
                }
                else if(curr_place->next==NULL){
                    curr_place->prev->next=NULL;
                }
                else
                {
                    curr_place->prev->next=curr_place->next;
                    curr_place->next->prev=curr_place->prev;
                    //delete(curr_place);
                }
                delete(ptr);
                hashrow=-1;hashcol=-1;
                return true;
            }
            return false;
        }
        void print(FILE* outfile)
        {
            for(int i=0;i<total_buckets;i++)
            {
                SymbolInfo* curr_ptr=hashara[i];
                //cout<<i+1;
                //outfile<<'\t'<<i+1;
                if(curr_ptr!=NULL)
                {
                    fprintf(outfile,"\t%d",i+1);
                     fprintf(outfile,"-->");
                while(curr_ptr!=NULL)
                {
                    //cout<<" -->";
                    //outfile<<" -->";
                   
                    //cout<<"("<<curr_ptr->get_Name()<<","<<curr_ptr->get_Type()<<")";
                    //outfile<<" ("<<curr_ptr->get_Name()<<","<<curr_ptr->get_Type()<<")";
                    if(curr_ptr->is_function==false)
                    {
                        //std::cout<<"Not Function "<<curr_ptr->Name<<endl;
                        fprintf(outfile," <%s,",curr_ptr->get_Name().c_str());
                        fprintf(outfile,"%s>",curr_ptr->get_Type().c_str());
                    }
                    else
                    {
                        fprintf(outfile," <%s, FUNCTION, %s>",curr_ptr->get_Name().c_str(),curr_ptr->return_type.c_str());
                    }
                    curr_ptr=curr_ptr->next;
                }
                //cout<<endl;
                //outfile<<endl;
                fprintf(outfile,"\n");
                }

            }
        }

};

class SymbolTable{
    scopeTable* curr_table;
    scopeTable* origin;
    int total_buckets;
    public:
    //string parent_id="0";
    int curr_position=0;
    SymbolTable(int Size)
    {
        total_buckets=Size;
        curr_table=new scopeTable(total_buckets,"0",0);
        origin=curr_table;
    }
    SymbolTable()
    {
        total_buckets=11;
        curr_table=new scopeTable(total_buckets,"0",0);
        origin=curr_table;
    }
    ~SymbolTable()
    {
        //scopeTable* deleting_table=curr_table;
        if(curr_table!=NULL)
        {
            while(curr_table!=origin)
            {
                //cout<<curr_table->id<<endl;
                ExitScope();
            }
            if(origin!=NULL)
            {
                delete_origin_table();
                //delete origin;
            }

        }

    }
    scopeTable* Enter_Scope()
    {
        /*if(curr_table==NULL)
        {
            curr_table=new scopeTable(total_buckets,"0",0);
            origin=curr_table;
        }*/
        //else
        //{

            curr_table->no_of_child++;
            scopeTable* c=new scopeTable(total_buckets,curr_table->id,curr_table->no_of_child);
            //curr_position++;
            curr_table->childScope=c;
            curr_table->childScope->parentScope=curr_table;
            curr_table=c;
            return curr_table;
        //}
    }
    bool Insert_into_parent_table(string n,string t,FILE* outfile,vector<SymbolInfo*>params)
    {
        //scopeTable* sc=curr_table->parentScope;
        bool val=curr_table->Insert_Function(n,t,true,t,outfile,false,false,params);
        return val;
    }


    bool ExitScope()
    {
        //std::cout << "exiting " << curr_table->id << std::endl;
        scopeTable* deletingTable=curr_table;
        //cout<<deletingTable->id<<" nnnbbvv"<<endl;
        if(curr_table->parentScope==NULL)
        {
            return false;
        }
        else
        {
            curr_table=curr_table->parentScope;

        }

        for(int i=0;i<total_buckets;i++)
        {

            if(deletingTable->hashara[i]!=NULL)
            {

                SymbolInfo* st=deletingTable->hashara[i];

                while(st->next!=NULL)
                {
                    //cout<<st->get_Name()<<"kkkkkkk"<<endl;
                    st=st->next;
                    //st->prev=NULL;
                    delete st->prev;

                }

                    //cout<<st->get_Name()<<"jjjjjjllllmm"<<endl;
                    delete(st);
            }
        }

            //delete deletingTable;
            return true;
    }

    bool insertsp(string n,string t,int stackpointer)
    {
        bool check_var=curr_table->Insert_secondpass(n,t,stackpointer);
        return check_var;
    }

    bool Insert(string n,string t,FILE* outfile)
    {
        bool check_var=curr_table->Insert(n,t,false,"NULL",outfile,false,false);
        return check_var;
    }

    bool Insert_Function_declaration(string n,string t,bool is_Function,FILE* outfile,vector<SymbolInfo*>params)
    {
        bool check_var=curr_table->Insert_Function(n,t,is_Function,t,outfile,false,false,params);
        return check_var;
    }

    bool Insert_parameter(string n,string t,FILE* outfile,bool is_parameter)
    {
        bool check_var=curr_table->Insert(n,t,false,t,outfile,false,true);
        return check_var;
    }

    bool Insert(string n,string t,FILE* outfile,bool is_array)
    {
        bool check_var=curr_table->Insert(n,t,false,"NULL",outfile,true,false);
        return check_var;
    }
    bool remove(string n,int &row,int &pos)
    {

        /*scopeTable* check_table=curr_table;
        bool checkval=false;
        while(check_table!=origin)
        {
            checkval=check_table->Delete(n);
            if(checkval==true)return checkval;
            check_table=check_table->parentScope;
        }
        if(check_table==origin)
        {
            checkval=check_table->Delete(n);
            return checkval;
        }
        else return checkval;
        */
        bool checkval=false;
        checkval=curr_table->Delete(n,row,pos);
        return checkval;
    }

    SymbolInfo* Look_up(string w)
    {
        scopeTable* check_table=curr_table;
        while(check_table!=origin)
        {
            SymbolInfo* return_ptr=check_table->Look_up(w);
            if(return_ptr!=NULL)return return_ptr;
            check_table=check_table->parentScope;
        }
        if(check_table==origin)
        {
            //cout<<w<<endl;
            SymbolInfo* return_ptr=check_table->Look_up(w);
            if(return_ptr!=NULL)return return_ptr;
            //if(return_ptr==NULL)cout<<"*88"<<endl;
            return NULL;
        }
    }

    bool make_function(string name,string return_type)
    {
        SymbolInfo* sii=Look_up(name);
        if(sii==NULL)return false;
        sii->is_function=true;
        sii->return_type=return_type;
        return true;
    }

    SymbolInfo* Look_up_in_current_scope_table(string w)
    {
        SymbolInfo* return_ptr=NULL;
        if(curr_table!=NULL)
        {
            return_ptr=curr_table->Look_up(w);

        }

        return return_ptr;
    }
    string get_curr_table_id()
    {
        return curr_table->id;
    }


    void print_current_scope_table(ofstream & outfile)
    {
        //cout<<"kkk"<<endl;
        //cout<<"ScopeTable# "<<curr_table->id<<endl;
        //outfile<<"\tScopeTable# "<<curr_table->id<<endl;
        //curr_table->print(outfile);
    }

    scopeTable* get_current_table()
    {
        return curr_table;
    }

    void delete_origin_table()
    {

            if(origin!=NULL)
            {
                for(int i=0;i<total_buckets;i++)
                {
                    if(origin->hashara[i]!=NULL)
                    {

                    SymbolInfo* st=origin->hashara[i];

                    while(st->next!=NULL)
                    {
                        //cout<<st->get_Name()<<"kkkkkkk"<<endl;
                        st=st->next;
                        //st->prev=NULL;
                        delete st->prev;

                    }

                        delete(st);
                    }
                }
            }
    }

    void print_all_scope_table(FILE* outfile)
    {
        scopeTable* check_table=curr_table;
        while(check_table!=origin)
        {
            //cout<<"ScopeTable# "<<check_table->id<<endl;
            //outfile<<"\tScopeTable# "<<check_table->id<<endl;
            fprintf(outfile,"\tScopeTable# %s\n",check_table->id.c_str());
            check_table->print(outfile);
            check_table=check_table->parentScope;
        }

        if(check_table==origin)
        {
            //cout<<"ScopeTable# "<<check_table->id<<endl;
            //outfile<<"\tScopeTable# "<<check_table->id<<endl;
            fprintf(outfile,"\tScopeTable# %s\n",check_table->id.c_str());
            check_table->print(outfile);
        }
    }
};
