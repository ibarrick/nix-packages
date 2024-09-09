

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <linux/input.h>
#include <time.h>

#define INPUT_DEVICE "/dev/input/by-id/usb-Razer_Razer_Naga_V2_Pro-if02-event-kbd"
#define INPUT_DEVICE2 "/dev/input/by-id/usb-Razer_Razer_Naga_V2_Pro-if01-event-kbd"
#define MAX_CMD_LENGTH 256
#define MAX_FDS 2

// Map Linux input event codes to wtype key names
const char* get_wtype_key_name(int code) {
	switch(code) {
        // Numeric keys
        case KEY_0: return "hyprctl dispatch cyclenext";
        case KEY_1: return "hyprctl dispatch focusworkspaceoncurrentmonitor 1";
        case KEY_2: return "hyprctl dispatch focusworkspaceoncurrentmonitor 2";
        case KEY_3: return "hyprctl dispatch focusworkspaceoncurrentmonitor 3";
        case KEY_4: return "hyprctl dispatch focusworkspaceoncurrentmonitor 4";
        case KEY_5: return "hyprctl dispatch focusworkspaceoncurrentmonitor 5";
        case KEY_6: return "hyprctl dispatch focusworkspaceoncurrentmonitor 6";
        case KEY_7: return "hyprctl dispatch focusworkspaceoncurrentmonitor 7";
        case KEY_8: return "hyprctl dispatch focusworkspaceoncurrentmonitor 8";
        case KEY_9: return "hyprctl dispatch focusworkspaceoncurrentmonitor 9";

        // Special characters
        case KEY_MINUS: return "hyprctl dispatch focusworkspaceoncurrentmonitor 10";
        case KEY_EQUAL: return "playerctl play-pause";
		default: return NULL;
	}
}

void log_event(int code, int value) {
    time_t now;
    struct tm *local;
    char timestamp[20];

    time(&now);
    local = localtime(&now);
    strftime(timestamp, sizeof(timestamp), "%Y-%m-%d %H:%M:%S", local);

    const char* key_name = get_wtype_key_name(code);
    const char* action = (value == 1) ? "pressed" : (value == 0) ? "released" : "repeated";

    printf("[%s] Key event - Code: %d, Action: %s", timestamp, code, action);
    if (key_name) {
        printf(", Key: %s", key_name);
    }
    printf("\n");
    fflush(stdout);  // Ensure the output is printed immediately
}

void send_key_with_win(int code, int value) {
    char cmd[MAX_CMD_LENGTH];
    const char* key_name = get_wtype_key_name(code);
    
    log_event(code, value);  // Log the event before processing

    if (key_name == NULL) {
        printf("Unknown key code: %d\n", code);
        return;
    }
    
    if (value == 1) { // Key press
        snprintf(cmd, sizeof(cmd), "%s", key_name);
    } else if (value == 0) { // Key release
		return;
    } else {
        return; // Ignore key repeat events
    }
    
    system(cmd);
}

int main() {
    int fds[MAX_FDS];
    fd_set readfds;
    struct input_event ev;
    int max_fd = -1;

    // Open INPUT_DEVICE
    fds[0] = open(INPUT_DEVICE, O_RDONLY);
    if (fds[0] < 0) {
        perror("Failed to open INPUT_DEVICE");
        return 1;
    }
    ioctl(fds[0], EVIOCGRAB, 1);

    // Open INPUT_DEVICE2
    fds[1] = open(INPUT_DEVICE2, O_RDONLY);
    if (fds[1] < 0) {
        perror("Failed to open INPUT_DEVICE2");
        close(fds[0]);
        return 1;
    }
    ioctl(fds[1], EVIOCGRAB, 1);

    // Find the maximum file descriptor
    for (int i = 0; i < MAX_FDS; i++) {
        if (fds[i] > max_fd) {
            max_fd = fds[i];
        }
    }

    printf("Starting Razer Naga Key Modifier. Logging all key events from both devices...\n");

    while (1) {
        FD_ZERO(&readfds);
        for (int i = 0; i < MAX_FDS; i++) {
            FD_SET(fds[i], &readfds);
        }

        // Wait for input on any of the devices
        if (select(max_fd + 1, &readfds, NULL, NULL, NULL) < 0) {
            perror("Error in select");
            break;
        }

        // Check which device has input and read from it
        for (int i = 0; i < MAX_FDS; i++) {
            if (FD_ISSET(fds[i], &readfds)) {
                if (read(fds[i], &ev, sizeof(ev)) < sizeof(ev)) {
                    perror("Error reading input event");
                    continue;
                }
                if (ev.type == EV_KEY) {
                    send_key_with_win(ev.code, ev.value);
                }
            }
        }
    }

    // Close all file descriptors
    for (int i = 0; i < MAX_FDS; i++) {
        close(fds[i]);
    }

    return 0;
    /* int fd = open(INPUT_DEVICE, O_RDONLY); */
    /* if (fd < 0) { */
    /*     perror("Failed to open input device"); */
    /*     return 1; */
    /* } */

	/* ioctl(fd, EVIOCGRAB, 1);// Give application exclusive control over side buttons. */

    /* printf("Starting Razer Naga Key Modifier. Logging all key events...\n"); */

    /* struct input_event ev; */
    /* while (1) { */
    /*     if (read(fd, &ev, sizeof(ev)) < sizeof(ev)) { */
    /*         perror("Error reading input event"); */
    /*         break; */
    /*     } */

    /*     if (ev.type == EV_KEY) { */
    /*         send_key_with_win(ev.code, ev.value); */
    /*     } */
    /* } */

    /* close(fd); */
    /* return 0; */
}
