/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-21 23:45:40
 */

#include "reload_queue.hpp"

std::stack<ReloadRequest> ReloadQueue::_Requests;

void ReloadQueue::PushRequest(const ReloadRequest& request)
{
    _Requests.push(request);
}

void ReloadQueue::ProcessRequests()
{
    if (_Requests.empty()) {
        return;
    }

    while (!_Requests.empty()) {
        ReloadRequest request = _Requests.top();
        switch (request.Type) {
            case ReloadRequestType::Model: {
                request.Object->FreeRender();
                request.Object->InitRender(request.Path);
                break;
            }
            case ReloadRequestType::Albedo: {
                request.Object->FreeTexture(EntityTextureType::Albedo);
                request.Object->InitTexture(EntityTextureType::Albedo, request.Path);
                break;
            }
        }

        _Requests.pop();
    }
}
