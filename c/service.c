#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "shttpd.h"
#include "store.h"

char* get_split_1(char* str, char* delimiter, char* drop){
    char *res=NULL;
    char * token;
    token = strtok(str, delimiter);
    while( token != NULL ) {
        if(strcmp(token, drop)){
            res = token;
            break;
        }
        token = strtok(NULL, delimiter);

    }
    return res;
}

char* get_status(char* query_string){
    if(query_string == NULL){
        return NULL;
    }
    return get_split_1(query_string, "=", "status");
}

char* get_ids(char* query_string){
    if(query_string == NULL){
        return NULL;
    }
    return get_split_1(query_string, "=", "id");
}

void get_todo(struct shttpd_arg *arg)
{
    const char * request_method = shttpd_get_env(arg, "REQUEST_METHOD");

    shttpd_printf(arg, "%s", "HTTP/1.1 200 OK\r\n");
    shttpd_printf(arg, "%s", "Content-Type: application/json\r\n\r\n");

    if (strcmp(request_method, "GET")) {
        return;
    }

    const char* query_string = shttpd_get_env(arg, "QUERY_STRING");
    char* status = get_status((char*)query_string);
    char* todo_str = list(status);
    shttpd_printf(arg, "%s", todo_str);
    free(todo_str);
    arg->flags |= SHTTPD_END_OF_OUTPUT;
}


void add_todo(struct shttpd_arg *arg)
{
    char content[20];

    if (arg->flags & SHTTPD_MORE_POST_DATA)
        return;
    shttpd_get_var("content", arg->in.buf, arg->in.len, content, sizeof(content));

    shttpd_printf(arg, "%s", "HTTP/1.1 200 OK\r\n");
    shttpd_printf(arg, "%s", "Content-Type: application/json\r\n\r\n");

    char* response = add(content);

    shttpd_printf(arg, "%s", response);
    arg->flags |= SHTTPD_END_OF_OUTPUT;
}


void update_todo(struct shttpd_arg *arg)
{
    char content[20];
    char status[20];
    char id[20];

    shttpd_printf(arg, "%s", "HTTP/1.1 200 OK\r\n");
    shttpd_printf(arg, "%s", "Content-Type: application/json\r\n\r\n");
    shttpd_get_var("id", arg->in.buf, arg->in.len, id, sizeof(id));
    shttpd_get_var("content", arg->in.buf, arg->in.len, content, sizeof(content));
    shttpd_get_var("status", arg->in.buf, arg->in.len, status, sizeof(status));
    int update_id = atoi(id);
    char* response = update(update_id, content, status);
    shttpd_printf(arg, "%s", response);
    arg->flags |= SHTTPD_END_OF_OUTPUT;
}

void delete_todo(struct shttpd_arg *arg)
{

    const char* query_string = shttpd_get_env(arg, "QUERY_STRING");
    shttpd_printf(arg, "%s", "HTTP/1.1 200 OK\r\n");
    shttpd_printf(arg, "%s", "Content-Type: application/json\r\n\r\n");

    char* res = get_ids((char *)query_string);

    char* token = strtok(res,",");
    int id;
    int flag=0;
    shttpd_printf(arg, "%s", "[");
    while( token != NULL ) {
        id = atoi(token);
        if(delete_item(id) == 0){
            if(flag != 0){
                shttpd_printf(arg, "%s", ",");
            }else{
                flag = 1;
            }
            shttpd_printf(arg, "%s", token);
        }
        token = strtok(NULL, ",");
    }
    shttpd_printf(arg, "%s", "]");
    arg->flags |= SHTTPD_END_OF_OUTPUT;
}


void action_todo(struct shttpd_arg *arg){
    const char* request_method = shttpd_get_env(arg, "REQUEST_METHOD");
    if (!strcmp(request_method, "POST")) {
        return add_todo(arg);
    }

    if (!strcmp(request_method, "PUT")) {
        return update_todo(arg);
    }

    if (!strcmp(request_method, "DELETE")) {
        return delete_todo(arg);
    }

}

//========================================


void request_env(struct shttpd_arg *arg)
{
    const char
            *request_method,
            *query_string,
            *request_uri,
            *remote_addr;

    request_method = shttpd_get_env(arg, "REQUEST_METHOD");
    request_uri = shttpd_get_env(arg, "REQUEST_URI");
    query_string = shttpd_get_env(arg, "QUERY_STRING");
    remote_addr = shttpd_get_env(arg, "REMOTE_ADDR");

    char name[20];
    char nick[20];
    char age[20];

//    char* status = get_status((char*)query_string);

    printf("len:%d\n", arg->in.len);

    if (!strcmp(request_method, "POST") || !strcmp(request_method, "PUT")) {
        if (arg->flags & SHTTPD_MORE_POST_DATA)
            return;
        shttpd_get_var("name", arg->in.buf, arg->in.len, name, sizeof(name));
        shttpd_get_var("nick", arg->in.buf, arg->in.len, nick, sizeof(nick));
        shttpd_get_var("age", arg->in.buf, arg->in.len, age, sizeof(age));
    }

    shttpd_printf(arg, "%s", "HTTP/1.1 200 OK\r\n");
    shttpd_printf(arg, "%s", "Content-Type: text/plain\r\n\r\n");
    shttpd_printf(arg, "request_method:%s\n", request_method);
    shttpd_printf(arg, "request_uri:%s\n", request_uri);
    shttpd_printf(arg, "query_string:%s\n", query_string);
    shttpd_printf(arg, "remote_addr:%s\n", remote_addr);
    shttpd_printf(arg, "name:%s\n", name);
    shttpd_printf(arg, "nick:%s\n", nick);
    shttpd_printf(arg, "age:%s\n", age);
//    shttpd_printf(arg, "status:%s\n", status);
    shttpd_printf(arg, "flags:%s\n", arg->flags);
    arg->flags |= SHTTPD_END_OF_OUTPUT;
}


void ok(struct shttpd_arg *arg)
{
    shttpd_printf(arg, "%s", "HTTP/1.1 200 OK\r\n");
    shttpd_printf(arg, "%s", "Content-Type: application/json\r\n\r\n");
    shttpd_printf(arg, "\"%s\"", "ok");
    arg->flags |= SHTTPD_END_OF_OUTPUT;
}

void ping(struct shttpd_arg *arg)
{
    shttpd_printf(arg, "%s", "HTTP/1.1 200 OK\r\n");
    shttpd_printf(arg, "%s", "Content-Type: application/json\r\n\r\n");
    shttpd_printf(arg, "\"%s\"", "pong");
    arg->flags |= SHTTPD_END_OF_OUTPUT;
}


void page_404(struct shttpd_arg *arg)
{
    shttpd_printf(arg, "%s", "HTTP/1.1 200 OK\r\n");
    shttpd_printf(arg, "%s", "Content-Type: text/plain\r\n\r\n");
    shttpd_printf(arg, "%s", "This is a custom error handler.");
    arg->flags |= SHTTPD_END_OF_OUTPUT;
}
