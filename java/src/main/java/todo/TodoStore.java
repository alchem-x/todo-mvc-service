package todo;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.jetbrains.annotations.NotNull;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import static java.util.Collections.emptyList;

public class TodoStore {

    private static final ObjectMapper objectMapper = new ObjectMapper();

    private final String storeFilePath;

    public TodoStore(String storeFilePath) {
        this.storeFilePath = storeFilePath;
    }

    public @NotNull List<@NotNull Todo> readTodoList() {
        var storeFilePath = Paths.get(this.storeFilePath);
        if (Files.notExists(storeFilePath)) {
            return emptyList();
        }
        try {
            var todos = objectMapper.readValue(storeFilePath.toFile(), Todo[].class);
            return List.of(todos);
        } catch (IOException ex) {
            throw new UncheckedIOException(ex);
        }
    }

    public void updateTodo(@NotNull Todo todo) {
        var todoList = this.readTodoList()
                .stream()
                .map(it -> Objects.equals(it.id(), todo.id()) ? todo : it)
                .toList();
        this.persistentTodoList(todoList);
    }

    public @NotNull Todo addNewTodo(@NotNull String content) {
        var todoList = this.readTodoList();
        var newTodoList = new ArrayList<Todo>();
        var newTodoId = 1;
        for (var it : todoList) {
            if (it.id() >= newTodoId) {
                newTodoId = it.id() + 1;
            }
            newTodoList.add(it);
        }
        var newTodo = new Todo(newTodoId, content, Todo.ACTIVE);
        newTodoList.add(newTodo);
        this.persistentTodoList(newTodoList);
        return newTodo;
    }

    public void bulkDeleteTodo(@NotNull List<@NotNull Integer> idList) {
        if (idList.size() == 0) {
            return;
        }
        var newTodoList = this.readTodoList()
                .stream()
                .filter(it -> !idList.contains(it.id()))
                .toList();
        this.persistentTodoList(newTodoList);
    }

    public void prune() {
        var storeFilePath = Paths.get(this.storeFilePath);
        try {
            Files.deleteIfExists(storeFilePath);
        } catch (IOException ex) {
            throw new UncheckedIOException(ex);
        }
    }

    private void persistentTodoList(@NotNull List<Todo> todoList) {
        var storeFilePath = Paths.get(this.storeFilePath);
        try {
            objectMapper.writeValue(storeFilePath.toFile(), todoList);
        } catch (IOException ex) {
            throw new UncheckedIOException(ex);
        }
    }

    public static ObjectMapper objectMapper() {
        return objectMapper;
    }
}
