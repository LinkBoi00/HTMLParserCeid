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

typedef struct pNode{
    struct Node* adress;
    struct pNode* next;
    struct pNode* prev;
}pNode;

typedef struct Linked_list{
    struct Node* head;
    struct Node* tail;
}Linked_list;

typedef struct Adress_list{
    struct pNode* head_adress;
    struct pNode* tail_adress;
}Adress_list;//essentially the adress list holds adresses to nodes of a list

bool find_match(Linked_list* list,char* id_name);//returns false if the id doesnt exist in the list and true if it exists
void delete_list(Linked_list* list);//deletes the hole list
void emplace_back(Linked_list* list,char* id_name);//adds one ellement at the end of the list
Node* newNode(char* id_name);//creates a new node for a list
Linked_list* newList();//creates a new list
void print_list(Linked_list* list);//for debugging it prints all the contents of a list

pNode* check_adress(Adress_list* list,char* id_name);//compares the content of the adresses that eatch node of the adress list has with the inputed char if it finds a match it returns the pNode that had it else it returns NULL
void insert_adress(Adress_list* list,Node* node);//just adds the adress of the node at the end
pNode* newPnode(Node* node);//allocates space for a pnode
Adress_list* newAdressList();//creates a new adresslist
void delete_adress_list(Adress_list* list);//deletes teh hole adress list
void delete_adress_node(Adress_list* list,pNode* node);//deletes the pNode you input
void print_adr_list(Adress_list* list);//the equivelant print list of adress list
#endif