//
//  GameHandler.swift
//  GameOfLife
//
//  Created by Lorenzo Sonnino on 05/05/2024.
//

import MetalKit
import simd

func pointerToArray(pointer: UnsafeMutablePointer<Bool>, length: Int) -> [Bool] {
    var array = Array(repeating: false, count: length)
    var usePointer = pointer;
    
    for i in 0..<length {
        array[i] = usePointer.pointee
        usePointer = usePointer.advanced(by: 1)
    }
    
    return array
}

class GameHandler: ObservableObject {
    @Published var game: Game
    @Published var play: Bool = false
    
    let device: MTLDevice!
    let commandQueue: MTLCommandQueue!
    let pipelineState: MTLComputePipelineState
    let compute: MTLFunction!
    
    let maxThreadsPerThreadGroup: Int
    
    var timer: Timer? = nil
    
    init(size: Int, borders: Bool = false) {
        self.game = Game(size, border: borders)
        
        // Get GPU device
        if let device = MTLCreateSystemDefaultDevice() {
            self.device = device
        } else {
            fatalError()
        }
        // Create FIFO queue to send commands to the GPU
        commandQueue = device.makeCommandQueue()
        // Get functions library
        let gpuLib = device.makeDefaultLibrary()
        
        // Get compute function
        if let compute = gpuLib?.makeFunction(name: "game_of_life") {
            self.compute = compute
        } else {
            fatalError()
        }
        
        // Add compute function to the pipeline state
        do {
            self.pipelineState = try device.makeComputePipelineState(function: compute)
        }
        catch {
            fatalError()
        }
        
        // Get the maximum number of threads each group can compute on
        self.maxThreadsPerThreadGroup = pipelineState.maxTotalThreadsPerThreadgroup
    }
    
    func setup() {
        // Setup timer
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if self.play {
                self.update()
            }
        }
    }
    
    func setSize(_ size: Int) {
        self.game = Game(size, border: game.border)
    }
    
    func update() {
        let linearSize = game.size * game.size
        
        var params = params_t()
        params.size = UInt32(game.size)
        params.borders = game.border ? 1 : 0
        
        // Create buffer to send commands to the queue
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            fatalError()
        }
        // Create encoder to send commands to the GPU function
        guard let commandEncoder = commandBuffer.makeComputeCommandEncoder() else {
            fatalError()
        }
        commandEncoder.setComputePipelineState(self.pipelineState)
        
        // Pass data to the GPU
        let flattenedState = Array(game.state.joined())
        let stateBuffer = device.makeBuffer(bytes: flattenedState,
                                            length: linearSize * MemoryLayout<Bool>.stride,
                                            options: .storageModeShared)
        let paramsBuffer = device.makeBuffer(bytes: &params,
                                             length: MemoryLayout<params_t>.stride,
                                             options: [])
        let resultBuffer = device.makeBuffer(length: linearSize * MemoryLayout<Bool>.stride,
                                             options: .storageModeShared)
        
        
        
        // Set buffers
        commandEncoder.setBuffer(stateBuffer, offset: 0, index: 0)
        commandEncoder.setBuffer(paramsBuffer, offset: 0, index: 1)
        commandEncoder.setBuffer(resultBuffer, offset: 0, index: 2)
        
        // Dispatch threads
        let threadsPerGrid = MTLSize(width: linearSize, height: 1, depth: 1)
        let threadsPerThreadGroup = MTLSize(width: maxThreadsPerThreadGroup, height: 1, depth: 1)
        commandEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadGroup)
        
        // We don't need anything more
        commandEncoder.endEncoding()
        // Send command to command queue
        commandBuffer.commit()
        
        // Wait for GPU to finish
        commandBuffer.waitUntilCompleted()
        
        // Retrieve result
        let result = resultBuffer?.contents().bindMemory(to: Bool.self, capacity: MemoryLayout<Float>.size * linearSize)
        let resultArray = pointerToArray(pointer: result!, length: linearSize)
        
        game.state = resultArray.unflatten(dim: game.size)
    }
}
