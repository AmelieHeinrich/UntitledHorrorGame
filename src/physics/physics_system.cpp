/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-26 19:11:27
 */

#include "physics_system.hpp"

#include <core/logger.hpp>

#include <Jolt/Jolt.h>
#include <Jolt/RegisterTypes.h>
#include <Jolt/Core/Factory.h>
#include <Jolt/Core/JobSystemThreadPool.h>
#include <Jolt/Physics/PhysicsSettings.h>

#include <cstdarg>

static void TraceImpl(const char* inFMT, ...)
{
    va_list list;
	va_start(list, inFMT);
	char buffer[1024];
	vsnprintf(buffer, sizeof(buffer), inFMT, list);
	va_end(list);

    LOG_ERROR("%s", buffer);
}

void PhysicsSystem::Init()
{
    JPH::RegisterDefaultAllocator();
    JPH::Trace = TraceImpl;
    JPH::Factory::sInstance = new JPH::Factory;
    JPH::RegisterTypes();
}

void PhysicsSystem::Exit()
{
    JPH::UnregisterTypes();
    
    delete JPH::Factory::sInstance;
    JPH::Factory::sInstance = nullptr;
}

