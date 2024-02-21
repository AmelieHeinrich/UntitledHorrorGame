/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 23:13:51
 */

#pragma once

#include <string>
#include <stack>

#include "game_object.hpp"

enum class ReloadRequestType
{
    Model,
    Albedo
};

struct ReloadRequest
{
    ReloadRequestType Type;
    std::string Path;
    GameObject* Object;
};

class ReloadQueue
{
public:
    static void PushRequest(const ReloadRequest& request);
    static void ProcessRequests();
private:
    static std::stack<ReloadRequest> _Requests;
};
