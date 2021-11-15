#ifndef HEADER_FILE
#define HEADER_FILE

#include <string.h>
#include "shttpd.h"
#include "store.h"

void get_todo(struct shttpd_arg *arg);
void add_todo(struct shttpd_arg *arg);
void update_todo(struct shttpd_arg *arg);
void delete_todo(struct shttpd_arg *arg);

void action_todo(struct shttpd_arg *arg);

//========================================

void request_env(struct shttpd_arg *arg);
void ok(struct shttpd_arg *arg);
void ping(struct shttpd_arg *arg);
void page_404(struct shttpd_arg *arg);

#endif