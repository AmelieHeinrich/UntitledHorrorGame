//========= Copyright © 2024, Amélie Heinrich, All rights reserved. ============//
// $Author: Amélie Heinrich
// $Project: UntitledHorrorGame
// $Create Time: 05/02/2024 17:53
//=============================================================================//

package util

import "core:math/rand"

UUID :: distinct u64

uuid_generate :: proc() -> UUID {
    return UUID(rand.int63_max(922337203685477580))
}
