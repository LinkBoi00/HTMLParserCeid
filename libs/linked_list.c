#include "include/linked_list.h"

Node* newNode(char* id_name){
    Node* temp=(Node*)malloc(sizeof(Node));
    temp->id_name=id_name;
    temp->next=NULL;
    return temp;
}

bool find_match(Linked_list* list,char* id_name){
    if (list == NULL ) return false;

    Node* parcer=list->head;

    while(parcer != NULL ){
        if (strcmp(parcer->id_name,id_name) == 0){
            return true;
        }
        parcer=parcer->next;
    }

    return false;
}

void delete_list(Linked_list* list){
    if(list == NULL || list->head == NULL ) return;
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
    if(list->head == NULL){
        list->head=newNode(id_name);
        list->tail=list->head;
    }
    else{
        (list->tail)->next=newNode(id_name);
        list->tail=list->tail->next;
    }
}

Linked_list* newList(){
    Linked_list* list=(Linked_list*)malloc(sizeof(Linked_list));
    list->head=NULL;
    list->tail=NULL;
    return list;
}

void print_list(Linked_list* list){
    if(list->head == NULL ) printf(" list is empty \n");
    Node* temp=list->head;

    printf("\n");
    while(temp!=NULL){
        printf("id_name:%s ",temp->id_name);
        temp=temp->next;
    }
    printf("\n");
}

pNode* check_adress(Adress_list* list,char* id_name){
    if(list == NULL || list->head_adress == NULL) return NULL;//if the list hasnt been created return null or f the list is empty return null
    
    pNode* temp=list->head_adress;
    
    while(temp != NULL && strcmp(temp->adress->id_name,id_name) !=0 ) temp=temp->next; //parse the list

    return temp;//if theres no hits temp will be null
}

pNode* newPnode(Node* node){
    pNode* temp=(pNode*)malloc(sizeof(pNode));
    temp->adress=node;
    temp->next=NULL;
    temp->prev=NULL;
    return temp;
}

void insert_adress(Adress_list* list,Node* node){
    if(list->head_adress == NULL){
        list->head_adress =newPnode(node);
        list->tail_adress=list->head_adress;
    }
    else{
        (list->tail_adress)->next=newPnode(node);
        list->tail_adress->next->prev=list->tail_adress;
        list->tail_adress=list->tail_adress->next;
    }
}

Adress_list* newAdressList(){
    Adress_list* list=(Adress_list*)malloc(sizeof(Adress_list));
    list->head_adress=NULL;
    list->tail_adress=NULL;
    return list;
}

void delete_adress_list(Adress_list* list){
    if(list == NULL || list->head_adress == NULL ) return;

    pNode* temp=list->head_adress;

    while(temp!=NULL){
        list->head_adress=temp->next;
        //temp->adress=NULL;//first set it to null because it can free a node from the list if we dont
        free(temp);
        temp=list->head_adress;
    }

    list->head_adress=NULL;
    list->tail_adress=NULL;
    free(list);
}

void delete_adress_node(Adress_list* list, pNode* node){
    if(list == NULL || node == NULL) return;

    //update previous nodes next
    if(node->prev != NULL) {
        node->prev->next=node->next;
    } else {
        //node is head
        list->head_adress=node->next;
    }

    //update next nodes prev
    if(node->next != NULL) {
        node->next->prev=node->prev;
    } else {
        //node is tail
        list->tail_adress=node->prev;
    }

    //node->adress=NULL;
    free(node);
}