#include "include/linked_list.h"

Node* newNode(char* id_name){
    Node* temp=(Node*)malloc(sizeof(Node));
    temp->id_name=id_name;
    temp->next=NULL;
    return temp;
}

bool find_match(Linked_list* list,char* id_name){
    if (list->head == NULL ) return false;
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
    if(list->head == NULL ) return;
    Node* temp=list->head;

    while(temp!=NULL){
        list->head=temp->next;
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
