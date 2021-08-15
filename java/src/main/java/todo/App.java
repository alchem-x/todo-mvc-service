package todo;

public class App {

    public static void main(String[] args) {
        var options = new TodoMvcService.Options("todo.json", 8080);
        new TodoMvcService(options).start();
    }
}
