#include "stack.h"

void print_stack(Stack* st){
    if(st==NULL) printf("\e[38;5;124mStack is empty\e[0m\n");
   Stack* temp=st;
   while(temp!=NULL){
        printf("\e[96m %s \n\e[0m ",temp->data);
        temp=temp->prev;
   }
}

void push(Stack** st,char* word){
    if(*st){
        (*st)->next=new_element(word);
        (*st)->next->prev=*st;
        *st=(*st)->next;
    }
    else *st=new_element(word);
}

void pop(Stack** st){
    if(*st){
        Stack* temp=*st;
        *st=(*st)->prev;
        (*st)->next=NULL;
        free(temp->data);
        free(temp);
    }
    else printf("\e[38;5;124mStack is empty\e[0m\n");
}

char* top(Stack* st){
    return (st)? st->data : NULL;//if t is null it will return else else it will return the top of our stack
}