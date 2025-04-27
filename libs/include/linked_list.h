#ifndef LIST_H
#define LIST_H

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>

typedef struct Node{
    struct Node* next;
    char*  id_name;
}Node;

typedef struct Linked_list{
    struct Node* head;
    struct Node* tail;
}Linked_list;

bool find_match(Linked_list* list,char* id_name);//returns false if the id doesnt exist in the list and true if it exists
void delete_list(Linked_list* list);
void emplace_back(Linked_list* list,char* id_name);
Node* newNode(char* id_name);
Linked_list* newList();
void print_list(Linked_list* list);
#endif