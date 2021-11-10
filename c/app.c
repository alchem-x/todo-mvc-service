#include <sys/types.h>
#include <sys/select.h>
#include <sys/wait.h>

#include <time.h>
#include <errno.h>
#include <signal.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "shttpd.h"
#include "cJSON.h"

static void
show_404(struct shttpd_arg *arg)
{
    shttpd_printf(arg, "%s", "HTTP/1.1 200 OK\r\n");
    shttpd_printf(arg, "%s", "Content-Type: text/plain\r\n\r\n");
    shttpd_printf(arg, "%s", "This is a custom error handler.");
    arg->flags |= SHTTPD_END_OF_OUTPUT;
}


static void
signal_handler(int sig_num)
{
    switch (sig_num) {
#ifndef _WIN32
        case SIGCHLD:
            while (waitpid(-1, &sig_num, WNOHANG) > 0) ;
            break;
#endif /* !_WIN32 */
        default:
            break;
    }
}


////从缓冲区中解析出JSON结构
//cJSON *json = cJSON_Parse(char_json);
//
//if (json == NULL)
//{
//return;
//}
//
////将传入的JSON结构转化为字符串
//char *buf = NULL;
//buf = cJSON_Print(json);


static void
json(struct shttpd_arg *arg)
{
    char *char_json = "{\"hello\":\"你好\"}";

    shttpd_printf(arg, "%s", "HTTP/1.1 200 OK\r\n");
    shttpd_printf(arg, "%s", "Content-Type: application/json\r\n\r\n");
    shttpd_printf(arg, "%s", "{\"hello\":\"你好\"}");
    arg->flags |= SHTTPD_END_OF_OUTPUT;
}

static void
ping(struct shttpd_arg *arg)
{
    shttpd_printf(arg, "%s", "HTTP/1.1 200 OK\r\n");
    shttpd_printf(arg, "%s", "Content-Type: text/plain\r\n\r\n");
    shttpd_printf(arg, "%s", "pong");
    arg->flags |= SHTTPD_END_OF_OUTPUT;
}


int main(int argc, char *argv[])
{
    int			data = 1234567;
    struct shttpd_ctx	*ctx;

#ifndef _WIN32
    signal(SIGPIPE, SIG_IGN);
    signal(SIGCHLD, &signal_handler);
#endif /* !_WIN32 */

    ctx = shttpd_init(argc, argv);
    shttpd_set_option(ctx, "ports", "8080");

    shttpd_register_uri(ctx, "/ping", &ping, (void *) &data);
    shttpd_register_uri(ctx, "/json", &json, (void *) &data);

    shttpd_handle_error(ctx, 404, show_404, NULL);

    /* Serve connections infinitely until someone kills us */
    for (;;)
        shttpd_poll(ctx, 1000);

    /* Probably unreached, because we will be killed by a signal */
    shttpd_fini(ctx);

    return (EXIT_SUCCESS);
}
