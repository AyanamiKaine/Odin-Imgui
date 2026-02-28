package imgui_impl_sdlgpu3

import imgui "../"
import sdl "vendor:sdl3"

when ODIN_OS == .Windows {foreign import lib "../imgui_windows_x64.lib"} else when ODIN_OS == .Linux {foreign import lib "../imgui_linux_x64.a"} else when ODIN_OS == .Darwin {
	when ODIN_ARCH == .amd64 {foreign import lib "../imgui_darwin_x64.a"} else {foreign import lib "../imgui_darwin_arm64.a"}
}

// imgui_impl_sdlgpu3.h
// Last checked `v1.92.6-docking` (2a1b69f05)
InitInfo :: struct {
	Device:               ^sdl.GPUDevice,
	ColorTargetFormat:    sdl.GPUTextureFormat,
	MSAASamples:          sdl.GPUSampleCount,
	SwapchainComposition: sdl.GPUSwapchainComposition,
	PresentMode:          sdl.GPUPresentMode,
}

@(link_prefix = "ImGui_ImplSDLGPU3_")
foreign lib {
	Init :: proc(info: ^InitInfo) -> bool ---
	Shutdown :: proc() ---
	NewFrame :: proc() ---
	PrepareDrawData :: proc(draw_data: ^imgui.DrawData, command_buffer: ^sdl.GPUCommandBuffer) ---
	RenderDrawData :: proc(draw_data: ^imgui.DrawData, command_buffer: ^sdl.GPUCommandBuffer, render_pass: ^sdl.GPURenderPass, pipeline: ^sdl.GPUGraphicsPipeline = nil) ---

	// Use if you want to reset your rendering device without losing Dear ImGui state.
	CreateDeviceObjects :: proc() ---
	DestroyDeviceObjects :: proc() ---

	// (Advanced) Use e.g. if you need to precisely control the timing of texture updates.
	UpdateTexture :: proc(tex: ^imgui.TextureData) ---
}

// [BETA] Selected render state data shared with callbacks.
// This is temporarily stored in GetPlatformIO().Renderer_RenderState during the ImGui_ImplSDLGPU3_RenderDrawData() call.
// (Please open an issue if you feel you need access to more data)
RenderState :: struct {
	Device:         ^sdl.GPUDevice,
	SamplerLinear:  ^sdl.GPUSampler,
	SamplerNearest: ^sdl.GPUSampler,
	SamplerCurrent: ^sdl.GPUSampler,
}

// Tiny frame snippet (required order for this backend):
// 1) PrepareDrawData() BEFORE beginning the render pass.
// 2) RenderDrawData() INSIDE the render pass.
//
// Example:
//  draw_data := imgui.GetDrawData()
//  cmd := sdl.AcquireGPUCommandBuffer(gpu_device)
//  swapchain_tex: ^sdl.GPUTexture
//  sdl.WaitAndAcquireGPUSwapchainTexture(cmd, window, &swapchain_tex, nil, nil)
//  if swapchain_tex != nil {
//      PrepareDrawData(draw_data, cmd)
//      target_info: sdl.GPUColorTargetInfo
//      target_info.texture = swapchain_tex
//      target_info.load_op = .CLEAR
//      target_info.store_op = .STORE
//      pass := sdl.BeginGPURenderPass(cmd, &target_info, 1, nil)
//      RenderDrawData(draw_data, cmd, pass)
//      sdl.EndGPURenderPass(pass)
//  }
//  sdl.SubmitGPUCommandBuffer(cmd)
