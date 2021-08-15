package todo;

import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

public record Todo(@NotNull Integer id, @NotNull String content, @NotNull String status) {

    public static final String ACTIVE = "active";
    public static final String COMPLETED = "completed";

    public static boolean isLegalStatus(@Nullable String status) {
        return ACTIVE.equals(status) || COMPLETED.equals(status);
    }
}
