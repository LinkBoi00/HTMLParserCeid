#ifndef STACK_H
#define STACK_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

typedef struct Stack
{
    Stack* next;
    Stack* prev;
    char* data;
}Stack;

Stack* new_element(char* word){
    Stack* st=(Stack*)malloc(sizeof(Stack));
    st->data=(char*)malloc(sizeof(char));
    st->data= strdup(word);
    st->prev=NULL;
    st->next=NULL;
    return st;
}

void print_stack(Stack* st);
void push(Stack** st,char* word);
void pop(Stack** st);
char* top(Stack* st);

#endif