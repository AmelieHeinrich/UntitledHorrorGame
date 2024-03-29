/**
 * @Author: Amélie Heinrich
 * @Create Time: 2024-02-27 17:03:03
 */

#include "forward_node.hpp"

#include <game.hpp>

#include <glm/gtc/type_ptr.hpp>

ForwardNode::ForwardNode()
{
    // NOTE(ahi): Default assets

    // TODO(ahi): This is stupid, we should have the error texture put in the code or
    //            be generated because if it's not there, the error texture will cause an error
    Image image;
    image.LoadFromFile("gamedata/assets/textures/default.png");

    _ErrorTexture = Texture::CreateFromImage(image);

    // NOTE(ahi): Forward

    GraphicsPipelineCreateInfo forwardInfo = {};
    forwardInfo.ccwWinding = false;
    forwardInfo.fill = PolygonFill::Fill;
    forwardInfo.depth = Comparison::Less;
    forwardInfo.cull = Cull::Back;
    forwardInfo.vertexShader = ShaderCompiler::CompileFromFile("gamedata/shaders/Forward/Forward_Vtx.hlsl", "vs_5_0");
    forwardInfo.pixelShader = ShaderCompiler::CompileFromFile("gamedata/shaders/Forward/Forward_Px.hlsl", "ps_5_0");
    _Forward = CreateRef<GraphicsPipeline>(forwardInfo);

    _ForwardTarget = CreateRef<Texture>(TextureType::TwoDimension, TextureLayout::RenderNode, state.width, state.height, DXGI_FORMAT_R32G32B32A32_FLOAT);
    _ForwardTarget->MakeRenderTarget();
    _ForwardTarget->MakeUnorderedAccess();
    _ForwardTarget->MakeShaderResource();
    _ForwardDepth = CreateRef<Texture>(TextureType::TwoDimension, TextureLayout::DepthStencil, state.width, state.height, DXGI_FORMAT_D32_FLOAT);
    _ForwardDepth->MakeDepthStencil();

    _CameraBuffer = CreateRef<Buffer>(sizeof(glm::mat4) * 2, sizeof(glm::mat4), BufferType::Constant);
    _ModelBuffer = CreateRef<Buffer>(sizeof(glm::mat4), sizeof(glm::mat4), BufferType::Constant);

    _ForwardSampler = CreateRef<Sampler>(Address::Wrap, Filter::Anisotropic, 4);
}

void ForwardNode::Render(Ref<Scene> scene)
{
    glm::mat4 matrices[2] = {
        scene->GetCamera().View(),
        scene->GetCamera().Projection()
    };
    _CameraBuffer->Upload(matrices, sizeof(matrices));

    RenderContext::SetViewport(state.width, state.height);
    RenderContext::BindRenderTarget(_ForwardTarget, _ForwardDepth);
    RenderContext::ClearRenderTarget(_ForwardTarget, 0.1f, 0.1f, 0.1f, 1.0f);
    RenderContext::ClearDepthTarget(_ForwardDepth, 1.0f, 0.0f);
    RenderContext::BindGraphicsPipeline(_Forward);
    RenderContext::BindGraphicsVertexConstantBuffer(_CameraBuffer, 0);

    for (auto object : scene->GetObjects()) {
        if (object->HasRenderable) {
            for (auto mesh : object->Renderable.Meshes) {
                Ref<Texture> albedoTexture = _ErrorTexture;

                if (object->Renderable.Textures[EntityTextureType::Albedo].Valid) {
                    albedoTexture = object->Renderable.Textures[EntityTextureType::Albedo].Texture;
                }

                _ModelBuffer->Upload(glm::value_ptr(object->Transform), sizeof(glm::mat4));
                RenderContext::BindGraphicsVertexConstantBuffer(_ModelBuffer, 1);
                RenderContext::BindGraphicsSampler(_ForwardSampler, 0);
                RenderContext::BindGraphicsShaderResource(albedoTexture, 0);
                RenderContext::BindBuffer(mesh.VertexBuffer);
                RenderContext::BindBuffer(mesh.IndexBuffer);

                RenderContext::DrawIndexed(mesh.IndexCount);
            
                RenderContext::UnbindGraphicsVertexConstantBuffer(1);
                RenderContext::UnbindGraphicsSampler(0);
                RenderContext::UnbindGraphicsShaderResource(0);
            }
        }
    }

    RenderContext::UnbindGraphicsVertexConstantBuffer(0);
    RenderContext::UnbindRenderTarget();
}
