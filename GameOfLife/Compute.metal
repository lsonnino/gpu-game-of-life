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

int64_t get_value(const device int64_t *array, int x, int y, unsigned int size, bool borders) {
    if (is_in_borders(x, y, size)) {
        return array[y * size + x] > 0 ? 1 : 0;
    }
    else {
        return borders ? 1 : 0;
    }
}

kernel void game_of_life(const device int64_t *previous [[buffer(0)]],
                         constant params_t &params [[buffer(1)]],
                         device int64_t *next [[buffer(2)]],
                         uint index [[thread_position_in_grid]]) {
    
    int64_t cell = previous[index];
    int x = index % params.size;
    int y = index / params.size;
    
    int64_t next_cell = 0;
    
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
    
    if (params.use_super) {
        switch (cell) {
            case 0: next_cell = (neighbours == 3) ? 1 : 0; break;
            case 1: next_cell = ((neighbours == 2) || (neighbours == 3)) ? 2 : 0; break;
            case 2: next_cell = ((neighbours == 2) || (neighbours == 3)) ? 2 : 1; break;
            default: next_cell = cell; // Should never happen
        }
    }
    else {
        if (cell == 0) {
            next_cell = (neighbours == 3) ? 1 : 0;
        }
        else {
            next_cell = ((neighbours == 2) || (neighbours == 3)) ? 1 : 0;
        }
    }
    
    next[index] = next_cell;
}
