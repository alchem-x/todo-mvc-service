package todo;

import com.fasterxml.jackson.core.JsonProcessingException;
import org.jetbrains.annotations.NotNull;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

import static java.nio.charset.StandardCharsets.UTF_8;

public class TodoMvcServiceTests {

    private static final HttpClient httpClient = HttpClient.newHttpClient();

    private static final TodoMvcService todoMvcService
            = new TodoMvcService(new TodoMvcService.Options("todo.json", 8080));

    @BeforeAll
    public static void setup() {
        todoMvcService.todoStore().prune();
        todoMvcService.start();
    }

    @AfterAll
    public static void done() {
        todoMvcService.stop();
        todoMvcService.todoStore().prune();
    }

    @Test
    public void test() {
        Assertions.assertEquals(0, getTodoList(null).size());

        addTodo("Todo");
        var todoList = getTodoList(null);
        Assertions.assertEquals(1, todoList.size());

        var todo = todoList.get(0);
        Assertions.assertEquals("Todo", todo.content());
        Assertions.assertEquals(Todo.ACTIVE, todo.status());

        addTodo("Another Todo");
        updateTodo(new Todo(todo.id(), todo.content(), Todo.COMPLETED));
        Assertions.assertEquals(1, getTodoList(Todo.COMPLETED).size());
        Assertions.assertEquals(1, getTodoList(Todo.ACTIVE).size());

        var idList = getTodoList(null).stream().map(Todo::id).toList();
        deleteTodo(idList);
        Assertions.assertEquals(0, getTodoList(null).size());
    }

    private static void addTodo(String content) {
        var body = """
                {
                    "content": "%s"
                }
                """.formatted(content);
        var httpRequest = HttpRequest.newBuilder()
                .POST(HttpRequest.BodyPublishers.ofString(body))
                .uri(URI.create("http://localhost:8080/todo"))
                .build();
        fetch(httpRequest, HttpResponse.BodyHandlers.discarding());
    }

    private static void updateTodo(Todo todo) {
        var httpRequest = HttpRequest.newBuilder()
                .PUT(HttpRequest.BodyPublishers.ofString(encodeTodo(todo)))
                .uri(URI.create("http://localhost:8080/todo"))
                .build();
        fetch(httpRequest, HttpResponse.BodyHandlers.discarding());
    }

    private static List<Todo> getTodoList(String status) {
        status = Objects.requireNonNullElse(status, "");
        var httpRequest = HttpRequest.newBuilder()
                .GET()
                .uri(URI.create("http://localhost:8080/todo/list?status=" + status))
                .build();
        var body = fetch(httpRequest, HttpResponse.BodyHandlers.ofString(UTF_8)).body();
        return decodeTodoList(body);
    }

    private static void deleteTodo(List<Integer> idList) {
        var qs = idList.stream().map("id=%s"::formatted).collect(Collectors.joining("&"));
        var httpRequest = HttpRequest.newBuilder()
                .DELETE()
                .uri(URI.create("http://localhost:8080/todo?" + qs))
                .build();
        fetch(httpRequest, HttpResponse.BodyHandlers.discarding());
    }

    private static String encodeTodo(Todo todo) {
        try {
            return TodoStore.objectMapper().writeValueAsString(todo);
        } catch (JsonProcessingException ex) {
            throw new RuntimeException(ex);
        }
    }

    private static List<Todo> decodeTodoList(String s) {
        try {
            return List.of(TodoStore.objectMapper().readValue(s, Todo[].class));
        } catch (JsonProcessingException ex) {
            throw new RuntimeException(ex);
        }
    }

    private static <T> HttpResponse<T> fetch(@NotNull HttpRequest httpRequest, HttpResponse.@NotNull BodyHandler<T> bodyHandler) {
        try {
            return httpClient.send(httpRequest, bodyHandler);
        } catch (IOException | InterruptedException ex) {
            throw new RuntimeException(ex);
        }
    }
}
