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
