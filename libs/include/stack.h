#ifndef STACK_H
#define STACK_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

typedef struct Stack {
    struct Stack* next;
    struct Stack* prev;
    char* data;
} Stack;

Stack* new_element(char* word);
void print_stack(Stack* st);
void push(Stack** st, char* word);
void pop(Stack** st);
char* top(Stack* st);

#endif
