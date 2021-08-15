package todo;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.net.InetSocketAddress;
import java.net.URLDecoder;
import java.util.*;
import java.util.concurrent.ForkJoinPool;

import static java.nio.charset.StandardCharsets.UTF_8;

public class TodoMvcService {

    private final Map<Route, HttpHandler> router = new HashMap<>();

    private final int port;
    private final TodoStore todoStore;

    public TodoMvcService(@NotNull Options options) {
        this.todoStore = new TodoStore(options.storeFilePath());
        this.port = options.port();
    }

    private void handleHi(@NotNull HttpExchange httpExchange) throws IOException {
        this.reply200(httpExchange, "Todo MVC Service");
    }

    private void handleGetTodoList(@NotNull HttpExchange httpExchange) throws IOException {
        var query = httpExchange.getRequestURI().getQuery();
        var responseHeaders = httpExchange.getResponseHeaders();
        responseHeaders.set("Content-Type", "application/json; charset=UTF-8");
        var todoList = this.todoStore.readTodoList();
        var status = getTodoStatusFromQuery(query);
        if (Todo.isLegalStatus(status)) {
            todoList = todoList.stream().filter(it -> Objects.equals(it.status(), status)).toList();
        }
        var data = TodoStore.objectMapper().writeValueAsString(todoList);
        this.reply200(httpExchange, data);
    }

    private void handleAddNewTodo(@NotNull HttpExchange httpExchange) throws IOException {
        var todo = TodoStore.objectMapper().readValue(httpExchange.getRequestBody(), Todo.class);
        var newTodo = this.todoStore.addNewTodo(todo.content());
        var responseHeaders = httpExchange.getResponseHeaders();
        responseHeaders.set("Content-Type", "application/json; charset=UTF-8");
        var data = TodoStore.objectMapper().writeValueAsString(newTodo);
        this.reply200(httpExchange, data);
    }

    private void handleUpdateTodo(@NotNull HttpExchange httpExchange) throws IOException {
        var todo = TodoStore.objectMapper().readValue(httpExchange.getRequestBody(), Todo.class);
        if (!Todo.isLegalStatus(todo.status())) {
            throw new IllegalArgumentException("Illegal Todo status");
        }
        this.todoStore.updateTodo(todo);
        this.reply200(httpExchange);
    }

    private void handleBulkDeleteTodo(@NotNull HttpExchange httpExchange) throws IOException {
        var query = httpExchange.getRequestURI().getQuery();
        var idList = getTodoIdListFromQuery(query);
        this.todoStore.bulkDeleteTodo(idList);
        this.reply200(httpExchange);
    }

    public void start() {
        this.router.put(new Route("GET", "/"), this::handleHi);
        this.router.put(new Route("GET", "/todo/list"), this::handleGetTodoList);
        this.router.put(new Route("POST", "/todo"), this::handleAddNewTodo);
        this.router.put(new Route("PUT", "/todo"), this::handleUpdateTodo);
        this.router.put(new Route("DELETE", "/todo"), this::handleBulkDeleteTodo);
        //
        var server = createHttpServer(this.port);
        server.createContext("/", (httpExchange) -> {
            var path = httpExchange.getRequestURI().getPath();
            var method = httpExchange.getRequestMethod();
            var handler = this.router.get(new Route(method, path));
            if (handler == null) {
                this.reply404(httpExchange);
                return;
            }
            try {
                handler.handle(httpExchange);
            } catch (Exception ex) {
                var message = Objects.requireNonNullElse(ex.getMessage(), "Bad Request");
                this.reply400(httpExchange, message);
            }
        });
        server.setExecutor(ForkJoinPool.commonPool());
        server.start();
    }

    private void reply200(@NotNull HttpExchange httpExchange) throws IOException {
        this.reply200(httpExchange, null);
    }

    private void reply200(@NotNull HttpExchange httpExchange, @Nullable String data) throws IOException {
        try (var responseBody = httpExchange.getResponseBody()) {
            data = Objects.requireNonNullElse(data, "");
            var body = data.getBytes(UTF_8);
            httpExchange.sendResponseHeaders(200, body.length);
            responseBody.write(body);
        }
    }

    private void reply400(@NotNull HttpExchange httpExchange, @Nullable String message) throws IOException {
        try (var responseBody = httpExchange.getResponseBody()) {
            message = Objects.requireNonNullElse(message, "400 Bad Request");
            var body = message.getBytes(UTF_8);
            httpExchange.sendResponseHeaders(400, body.length);
            responseBody.write(body);
        }
    }

    private void reply404(@NotNull HttpExchange httpExchange) throws IOException {
        try (var responseBody = httpExchange.getResponseBody()) {
            var body = "404 Not Found".getBytes(UTF_8);
            httpExchange.sendResponseHeaders(404, body.length);
            responseBody.write(body);
        }
    }

    private static @NotNull List<Integer> getTodoIdListFromQuery(@Nullable String queryString) {
        var idList = getParameterList(queryString, "id");
        return idList.stream()
                .map(TodoMvcService::parseInt)
                .filter(Objects::nonNull)
                .toList();
    }

    private static @Nullable String getTodoStatusFromQuery(@Nullable String queryString) {
        var parameterList = getParameterList(queryString, "status");
        return parameterList.size() == 0 ? null : parameterList.get(0);
    }

    private static @NotNull List<@NotNull String> getParameterList(@Nullable String queryString, @NotNull String name) {
        if (queryString == null || "".equals(queryString.trim())) {
            return Collections.emptyList();
        }
        var parameterList = new ArrayList<String>();
        var split = queryString.split("&");
        Arrays.stream(split)
                .filter(it -> it.contains("="))
                .map(it -> it.split("="))
                .filter(it -> it.length > 0)
                .forEach(it -> {
                    if (Objects.equals(decode(it[0]), name)) {
                        parameterList.add(it.length == 1 ? "" : decode(it[1]));
                    }
                });
        return parameterList;
    }

    private static String decode(@NotNull String s) {
        return URLDecoder.decode(s, UTF_8);
    }

    private static @Nullable Integer parseInt(@NotNull String s) {
        try {
            return Integer.parseInt(s);
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private static @NotNull HttpServer createHttpServer(int port) {
        try {
            var address = new InetSocketAddress(port);
            return HttpServer.create(address, 0);
        } catch (IOException ex) {
            throw new UncheckedIOException(ex);
        }
    }

    public record Options(@NotNull String storeFilePath, @NotNull Integer port) {
    }

    private record Route(@NotNull String method, @NotNull String path) {
    }
}
