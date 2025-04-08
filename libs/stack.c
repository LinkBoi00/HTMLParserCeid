#include "include/stack.h"

struct StackNode* new_element(char* word) {
    struct StackNode* st = (struct StackNode*) malloc(sizeof(struct StackNode));
    st->data = (char*) malloc(sizeof(char));
    st->data = strdup(word);

    st->prev=NULL;
    st->next=NULL;
    
    return st;
}

void print_stack(Stack* st) {
    if (st == NULL) {
        fprintf(stderr, "print_stack: Stack is empty");
        return;
    }
    
    struct StackNode* temp = st;
    while(temp != NULL) {
        printf("%s\n", temp->data);
        temp = temp->prev;
   }
}

void push(Stack** st, char* word) {
    if (*st == NULL) {
        fprintf(stderr, "push: Stack is empty");
        return;
    }

    (*st)->next = new_element(word);
    (*st)->next->prev = *st;
    *st = (*st)->next;;
}

void pop(Stack** st) {
    if (*st == NULL) {
        fprintf(stderr, "pop: Stack is empty");
        return;
    }

    struct StackNode* temp = *st;
    *st = (*st)->prev;
    (*st)->next = NULL;

    free(temp->data);
    free(temp);
}

char* top(Stack* st) {
    return (st) ? st->data : NULL;
}
