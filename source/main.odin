//========= Copyright © 2024, Sillies Industries, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: UntitledHorrorGame
// $Create Time: 15/01/2024 13:05
//=============================================================================//

package game

import "core:mem"
import "core:log"
import "core:fmt"

main :: proc() {
    tracking_allocator: mem.Tracking_Allocator

    // Init allocator
    mem.tracking_allocator_init(&tracking_allocator, context.allocator)
    defer mem.tracking_allocator_destroy(&tracking_allocator)
    context.allocator = mem.tracking_allocator(&tracking_allocator)

    // Game
    do_game()

    // Mem check
    for _, leak in tracking_allocator.allocation_map {
        fmt.printf("%v leaked %m\n", leak.location, leak.size)
    }
    for bad_free in tracking_allocator.bad_free_array {
        fmt.printf("%v allocation %p was freed badly\n", bad_free.location, bad_free.memory)
    }
}
