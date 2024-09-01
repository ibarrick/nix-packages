

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <linux/input.h>
#include <time.h>

#define INPUT_DEVICE "/dev/input/by-id/usb-Razer_Razer_Naga_V2_Pro-if02-event-kbd"
#define MAX_CMD_LENGTH 256

// Map Linux input event codes to wtype key names
const char* get_wtype_key_name(int code) {
	switch(code) {
        // Numeric keys
        case KEY_0: return "0";
        case KEY_1: return "1";
        case KEY_2: return "2";
        case KEY_3: return "3";
        case KEY_4: return "4";
        case KEY_5: return "5";
        case KEY_6: return "6";
        case KEY_7: return "7";
        case KEY_8: return "8";
        case KEY_9: return "9";

        // Special characters
        case KEY_MINUS: return "minus";
        case KEY_EQUAL: return "equal";
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
        snprintf(cmd, sizeof(cmd), "wtype -P Super -p %s -r Super", key_name);
    } else if (value == 0) { // Key release
        snprintf(cmd, sizeof(cmd), "wtype -r %s", key_name);
    } else {
        return; // Ignore key repeat events
    }
    
    system(cmd);
}

int main() {
    int fd = open(INPUT_DEVICE, O_RDONLY);
    if (fd < 0) {
        perror("Failed to open input device");
        return 1;
    }

    printf("Starting Razer Naga Key Modifier. Logging all key events...\n");

    struct input_event ev;
    while (1) {
        if (read(fd, &ev, sizeof(ev)) < sizeof(ev)) {
            perror("Error reading input event");
            break;
        }

        if (ev.type == EV_KEY) {
            send_key_with_win(ev.code, ev.value);
        }
    }

    close(fd);
    return 0;
}
