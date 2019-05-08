#include <iostream>
#include <cuda.h>

#define WIDTH 3833
#define HEIGHT 2160

bool checkResults(uchar4* rgba, uchar3* bgr, int size) {

    bool correct = true;

    for (int i=0; i < size; ++i) {
        correct &= rgba[i].x == bgr[i].z;
        correct &= rgba[i].y == bgr[i].y;
        correct &= rgba[i].z == bgr[i].x;
        correct &= rgba[i].w == 255;
    }

    return correct;
}

__global__ void convertBGR2RGBA(uchar3 *bgr, uchar4* rgba, int width, int height) {

	int position = 0;// 0 is not correct. Compute each thread position;

	// Protection to avoid segmentation fault
	if (position < width * height) {	
		rgba[position].x == bgr[position].z;
		rgba[position].y == bgr[position].y;
		rgba[position].z == bgr[position].x;
		rgba[position].w == 255;
	}
}

int main() {

    uchar3 *h_bgr, *d_bgr;
    uchar4 *h_rgba, *d_rgba;

    int bar_widht = HEIGHT/3;

    // Alloc and generate BGR bars.
    h_bgr = (uchar3*)malloc(sizeof(uchar3)*WIDTH*HEIGHT);
    for (int i=0; i < WIDTH * HEIGHT; ++i) {
        if (i < bar_widht) { h_bgr[i] = { 255, 0, 0 }; }
        else if (i < bar_widht*2) { h_bgr[i] = { 0, 255, 0 }; }
        else { h_bgr[i] = { 0, 0, 255 }; }
    }

    // Alloc RGBA pointers
    h_rgba = (uchar4*)malloc(sizeof(uchar4)*WIDTH*HEIGHT);

    // Alloc gpu pointers
    cudaError_t error = cudaMalloc(&d_bgr, sizeof(uchar3) * WIDTH * HEIGHT);
    if (error != cudaSuccess) {
	std::cout << "Error in cudaMalloc" << std::endl;
    }

    error = cudaMalloc(&d_rgba, sizeof(uchar4) * WIDTH * HEIGHT);
    if (error != cudaSuccess) {
	std::cout << "Error in cudaMalloc" << std::endl;
    }
    
    // Copy data to GPU
    error = cudaMemcpy(d_bgr, h_bgr, sizeof(uchar3) * WIDTH * HEIGHT, cudaMemcpyHostToDevice);
    if (error != cudaSuccess) {
	std::cout << "Error in cudaMemcpy" << std::endl;
    }

    dim3 block(512, 1, 1);
    dim3 grid(ceil(WIDTH*HEIGHT/(float)block.x), 1, 1);
    convertBGR2RGBA<<<grid, block, 0, 0>>>(d_bgr, d_rgba, WIDTH, HEIGHT);

    error = cudaMemcpy(h_rgba, d_rgba, sizeof(uchar4) * WIDTH * HEIGHT, cudaMemcpyDeviceToHost);
    if (error != cudaSuccess) {
	std::cout << "Error in cudaMemcpy" << std::endl;
    }

    bool ok = checkResults(h_rgba, h_bgr, WIDTH*HEIGHT);

    if (ok) {
        std::cout << "Executed!! Results OK." << std::endl;
    } else {
        std::cout << "Executed!! Results NOT OK." << std::endl;
    }

    return 0;

}
