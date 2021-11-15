#include "cJSON.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#define todo_file "todo.json"

int save_file(cJSON* object){
    char* todo_str = cJSON_Print(object);
    FILE * file;
    file = fopen(todo_file, "w");
    if(file == NULL){
        free(todo_str);
        return -1;
    }
    fprintf(file, "%s\n", todo_str);
    fclose(file);
    free(todo_str);
    return 0;
}

cJSON * load_file(){
    FILE *file = NULL;
    char *data = NULL;
    long len = 0 ;
    file = fopen(todo_file, "rb");
    if(file == NULL){
        return NULL;
    }

    fseek(file, 0, SEEK_END);
    len = ftell(file);
    fseek(file,0,SEEK_SET);
    data = (char *)malloc(len + 1);
    fread(data,1,len,file);
    fclose(file);

    cJSON *todo_list = cJSON_Parse(data);
    free(data);
    return todo_list;

}

char* add(char* content){
    cJSON *todo_list = load_file();
    int max_id=0;
    if(todo_list != NULL){
        int array_size = cJSON_GetArraySize(todo_list);
        cJSON* object = cJSON_GetArrayItem(todo_list, array_size-1);
        cJSON* oitem = cJSON_GetObjectItem(object, "id");
        max_id = oitem->valueint;
    }else{
        todo_list = cJSON_CreateArray();
    }

    cJSON* item  = cJSON_CreateObject();
    cJSON_AddNumberToObject(item, "id", max_id + 1);
    cJSON_AddStringToObject(item, "content", content);
    cJSON_AddStringToObject(item, "status", "active");

    cJSON_AddItemToArray(todo_list, item);

    save_file(todo_list);
    char* item_str = cJSON_Print(item);
    cJSON_Delete(todo_list);

    return item_str;
}

char * list(char* status){
    cJSON* todo_list = load_file();
    char* item_status;
    char* todo_str;
    if(status!=NULL){
        cJSON * res = cJSON_CreateArray();
        int array_size = cJSON_GetArraySize(todo_list);
        cJSON *object;
        for (int i=0;i < array_size;i++){
            object = cJSON_GetArrayItem(todo_list, i);
            item_status = cJSON_GetObjectItem(object, "status")->valuestring;
//            printf("status:%s item_status:%s\n", status, item_status);
            if(!strcmp(item_status, status)){

                cJSON_AddItemReferenceToArray(res, object);
            }
        }
        todo_str = cJSON_Print(res);
        cJSON_Delete(res);
    }else{
        todo_str = cJSON_Print(todo_list);
    }

    cJSON_Delete(todo_list);
    return todo_str;
}
char* update(int update_id, char* content, char* status){
    cJSON *todo_list = load_file();
    int array_size = cJSON_GetArraySize(todo_list);

    cJSON* item  = cJSON_CreateObject();
    cJSON_AddNumberToObject(item, "id", update_id);
    cJSON_AddStringToObject(item, "content", content);
    cJSON_AddStringToObject(item, "status", status);

    for (int i=0;i < array_size;i++){
        cJSON *object = cJSON_GetArrayItem(todo_list, i);
        int item_id = cJSON_GetObjectItem(object, "id")->valueint;
        if(update_id == item_id){
            cJSON_ReplaceItemInArray(todo_list, i, item);
            break;
        }
    }
    save_file(todo_list);
    char* item_str = cJSON_Print(item);
    cJSON_Delete(todo_list);
    return item_str;
}

int delete_item(int id){
    cJSON *todo_list = load_file();
    int array_size = cJSON_GetArraySize(todo_list);
    int flag=1;
    for (int i=0;i < array_size;i++){
        cJSON *object = cJSON_GetArrayItem(todo_list, i);
        int item_id = cJSON_GetObjectItem(object, "id")->valueint;
        if(id == item_id){
            cJSON_DeleteItemFromArray(todo_list, i);
            flag = 0;
            break;
        }
    }
    save_file(todo_list);
    cJSON_Delete(todo_list);
    return flag;
}

