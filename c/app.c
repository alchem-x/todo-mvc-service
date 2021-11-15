#include <sys/types.h>
#include <sys/select.h>
#include <sys/wait.h>

#ifndef _WIN32_WCE /* Some ANSI #includes are not available on Windows CE */
#include <time.h>
#include <errno.h>
#include <signal.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

#include "shttpd.h"
#include "service.h"

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

int main(int argc, char *argv[])
{
    struct shttpd_ctx	*ctx;

#ifndef _WIN32
    signal(SIGPIPE, SIG_IGN);
    signal(SIGCHLD, &signal_handler);
#endif /* !_WIN32 */

    ctx = shttpd_init(argc, argv);
    shttpd_set_option(ctx, "ports", "8080");

    shttpd_register_uri(ctx, "/", &ok, (void *) NULL);
    shttpd_register_uri(ctx, "/ping", &ping, NULL);
    shttpd_register_uri(ctx, "/env", &request_env, NULL);

    shttpd_register_uri(ctx, "/todo/list", &get_todo, NULL);
    shttpd_register_uri(ctx, "/todo", &action_todo, NULL);

    shttpd_handle_error(ctx, 404, page_404, NULL);

    for (;;)
        shttpd_poll(ctx, 1000);

    shttpd_fini(ctx);

    return (EXIT_SUCCESS);
}
