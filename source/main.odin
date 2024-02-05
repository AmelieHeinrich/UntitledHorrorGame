//========= Copyright © 2024, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: UntitledHorrorGame
// $Create Time: 15/01/2024 13:05
//=============================================================================//

package game

import "core:mem"
import "core:log"
import "core:fmt"
import "core:os"

main :: proc() {
    tracking_allocator: mem.Tracking_Allocator

    // Init allocator
    mem.tracking_allocator_init(&tracking_allocator, context.allocator)
    defer mem.tracking_allocator_destroy(&tracking_allocator)
    context.allocator = mem.tracking_allocator(&tracking_allocator)

    // Init logger
    if os.exists("gamedata/log.txt") {
        os.remove("gamedata/log.txt")
    }

    handle, err := os.open("gamedata/log.txt", os.O_CREATE | os.O_RDWR)
    if err != 0 {
        fmt.eprintln("[ERROR] Failed to create log file!")
        return
    }

    console_logger := log.create_console_logger()
    file_logger := log.create_file_logger(handle)
    multi_logger := log.create_multi_logger(console_logger, file_logger)
    context.logger = multi_logger

    // Game
    do_game()

    // Free loggers
    os.close(handle)
    log.destroy_console_logger(console_logger)
    log.destroy_file_logger(&file_logger)
    log.destroy_multi_logger(&multi_logger)

    // Mem check
    for _, leak in tracking_allocator.allocation_map {
        log.errorf("%v leaked %m", leak.location, leak.size)
    }
    for bad_free in tracking_allocator.bad_free_array {
        log.errorf("%v allocation %p was freed badly", bad_free.location, bad_free.memory)
    }
}
