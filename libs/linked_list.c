#include "include/linked_list.h"

Node* newNode(char* id_name){
    Node* temp=(Node*)malloc(sizeof(Node));
    if (temp == NULL) {
        printf("newNode: Memory allocation error");
        return NULL;
    }

    temp->id_name=strdup(id_name);
    temp->next=NULL;
    return temp;
}

bool find_match(Linked_list* list,char* id_name){
    if (list == NULL) return false;
    Node* parser=list->head;

    while (parser != NULL) {
        if (strcmp(parser->id_name,id_name) == 0){
            return true;
        }
        parser=parser->next;
    }

    return false;
}

void delete_list(Linked_list* list){
    if (list == NULL || list->head == NULL) return;
    Node* temp=list->head;

    while(temp!=NULL){
        list->head=temp->next;
        free(temp->id_name);
        free(temp);
        temp=list->head;
    }

    list->head=NULL;
    list->tail=NULL;
    free(list);
}

void emplace_back(Linked_list* list,char* id_name){
    if (list == NULL) {
        printf("emplace_back: List is NULL\n");
        return;
    }

    // Create new node
    Node* new_node = newNode(id_name);
    if (new_node == NULL) {
        printf("emplace_back: Failed to create new node\n");
        return;
    }

    if(list->head == NULL){
        list->head=new_node;
        list->tail=list->head;
    }
    else{
        (list->tail)->next=new_node;
        list->tail=list->tail->next;
    }
}

Linked_list* newList(){
    Linked_list* list=(Linked_list*)malloc(sizeof(Linked_list));
    if (list == NULL) {
        printf("newList: Memory allocation error");
        return NULL;
    }

    list->head=NULL;
    list->tail=NULL;
    return list;
}

void print_list(Linked_list* list){
    if (list == NULL) {
        printf("print_list: List is NULL\n");
        return;
    }
    if (list->head == NULL)  {
        printf("List is empty\n");
        return;
    }

    Node* temp=list->head;

    printf("\n");
    while(temp!=NULL){
        printf("id_name:%s ",temp->id_name);
        temp=temp->next;
    }
    printf("\n");
}

pNode* check_address(Address_list* list,char* id_name){
    if(list == NULL || list->head_address == NULL) return NULL;//if the list hasnt been created return null or f the list is empty return null
    
    pNode* temp=list->head_address;
    
    while(temp != NULL && strcmp(temp->address->id_name,id_name) !=0 ) temp=temp->next; //parse the list

    return temp;//if theres no hits temp will be null
}

pNode* newPnode(Node* node){
    pNode* temp=(pNode*)malloc(sizeof(pNode));
    temp->address=node;
    temp->next=NULL;
    temp->prev=NULL;
    return temp;
}

void insert_address(Address_list* list,Node* node){
    if(list->head_address == NULL){
        list->head_address =newPnode(node);
        list->tail_address=list->head_address;
    }
    else{
        (list->tail_address)->next=newPnode(node);
        list->tail_address->next->prev=list->tail_address;
        list->tail_address=list->tail_address->next;
    }
}

Address_list* newAddressList(){
    Address_list* list=(Address_list*)malloc(sizeof(Address_list));
    list->head_address=NULL;
    list->tail_address=NULL;
    return list;
}

void delete_address_list(Address_list* list){
    if(list == NULL || list->head_address == NULL ) return;

    pNode* temp=list->head_address;

    while(temp!=NULL){
        list->head_address=temp->next;
        //temp->address=NULL;//first set it to null because it can free a node from the list if we dont
        free(temp);
        temp=list->head_address;
    }

    list->head_address=NULL;
    list->tail_address=NULL;
    free(list);
}

void delete_address_node(Address_list* list, pNode* node){
    if(list == NULL || node == NULL) return;

    //update previous nodes next
    if(node->prev != NULL) {
        node->prev->next=node->next;
    } else {
        //node is head
        list->head_address=node->next;
    }

    //update next nodes prev
    if(node->next != NULL) {
        node->next->prev=node->prev;
    } else {
        //node is tail
        list->tail_address=node->prev;
    }

    //node->address=NULL;
    free(node);
}