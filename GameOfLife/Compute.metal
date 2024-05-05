//
//  Compute.metal
//  GameOfLife
//
//  Created by Lorenzo Sonnino on 05/05/2024.
//

#include <metal_stdlib>
using namespace metal;

#include "definitions.h"

bool is_in_borders(int x, int y, unsigned int size) {
    return ((x >= 0) && (((unsigned) x) < size) &&
            (y >= 0) && (((unsigned) y) < size));
}

bool get_value(const device bool *array, int x, int y, unsigned int size, bool borders) {
    if (is_in_borders(x, y, size)) {
        return array[y * size + x];
    }
    else {
        return borders;
    }
}

kernel void game_of_life(const device bool *previous [[buffer(0)]],
                         constant params_t &params [[buffer(1)]],
                         device bool *next [[buffer(2)]],
                         uint index [[thread_position_in_grid]]) {
    
    bool cell = previous[index];
    int x = index % params.size;
    int y = index / params.size;
    
    bool next_cell = false;
    
    int neighbours = (// Orthogonal neighbours
                      get_value(previous, x-1, y, params.size, params.borders) +
                      get_value(previous, x+1, y, params.size, params.borders) +
                      get_value(previous, x, y-1, params.size, params.borders) +
                      get_value(previous, x, y+1, params.size, params.borders) +
                      // Diagonal neighbours
                      get_value(previous, x-1, y-1, params.size, params.borders) +
                      get_value(previous, x+1, y-1, params.size, params.borders) +
                      get_value(previous, x-1, y+1, params.size, params.borders) +
                      get_value(previous, x+1, y+1, params.size, params.borders));
    
    if (cell) {
        next_cell = (neighbours == 2) || (neighbours == 3);
    }
    else {
        next_cell = (neighbours == 3);
    }
    
    next[index] = next_cell;
}
