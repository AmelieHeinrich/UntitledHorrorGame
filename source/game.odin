//========= Copyright © 2023, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: Silly
// $Create Time: 15/01/2024 13:05
//=============================================================================//

package duvet

import "core:fmt"
import "core:log"
import "core:os"

Program_Mode :: enum {
    GAME
}

main :: proc() {
    // Init logger
    handle, err := os.open("gamedata/log.txt", os.O_CREATE)
    if err != 0 {
        fmt.eprintln("[ERROR] Failed to create log file!")
        return
    }
    console_logger := log.create_console_logger()
    file_logger := log.create_file_logger(handle)
    multi_logger := log.create_multi_logger(console_logger, file_logger)
    context.logger = multi_logger

    // Destroy logger
    log.destroy_multi_logger(&multi_logger)
    log.destroy_file_logger(&file_logger)
    log.destroy_console_logger(console_logger)
    os.close(handle)
}
