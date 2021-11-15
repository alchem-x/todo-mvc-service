#ifndef HEADER_FILE
#define HEADER_FILE
#include "cJSON.h"
#include <stdio.h>
#include <stdlib.h>
#define todo_file "todo.json"

int save_file(cJSON* object);
cJSON * load_file();
char* add(char* content);
char* list(char* status);
char* update(int update_id, char* content, char* status);
int delete_item(int id);

#endif