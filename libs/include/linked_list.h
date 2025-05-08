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
    struct Node* address;
    struct pNode* next;
    struct pNode* prev;
}pNode;

typedef struct Linked_list{
    struct Node* head;
    struct Node* tail;
}Linked_list;

typedef struct Address_list{
    struct pNode* head_address;
    struct pNode* tail_address;
}Address_list;//essentially the address list holds addresses to nodes of a list

bool find_match(Linked_list* list,char* id_name);//returns false if the id doesnt exist in the list and true if it exists
void delete_list(Linked_list* list);//deletes the hole list
void emplace_back(Linked_list* list,char* id_name);//adds one ellement at the end of the list
Node* newNode(char* id_name);//creates a new node for a list
Linked_list* newList();//creates a new list
void print_list(Linked_list* list);//for debugging it prints all the contents of a list

pNode* check_address(Address_list* list,char* id_name);//compares the content of the addresses that eatch node of the address list has with the inputed char if it finds a match it returns the pNode that had it else it returns NULL
void insert_address(Address_list* list,Node* node);//just adds the address of the node at the end
pNode* newPnode(Node* node);//allocates space for a pnode
Address_list* newAddressList();//creates a new addresslist
void delete_address_list(Address_list* list);//deletes teh hole address list
void delete_address_node(Address_list* list,pNode* node);//deletes the pNode you input
void print_adr_list(Address_list* list);//the equivelant print list of address list
#endif