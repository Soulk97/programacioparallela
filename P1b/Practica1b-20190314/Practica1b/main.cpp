#include <iostream>
#include <omp.h>

#define WIDTH 3840
#define HEIGHT 2160

typedef unsigned char uchar;

struct _uchar3 {
    uchar x;
    uchar y;
    uchar z;
};

using uchar3 = _uchar3;

struct _uchar4 {
    uchar x;
    uchar y;
    uchar z;
    uchar w;
};

using uchar4 = _uchar4;

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

void convertBGR2RGBA(uchar3* bgr, uchar4* rgba, int width, int height) {
    int i;
    for (int y=0; y<height; ++y) {
    	for (int x=0; y<width; ++x) {	
            i = width *y +x;
            rgba[i].x = bgr[i].z;
            rgba[i].y = bgr[i].y;
            rgba[i].z = bgr[i].x;
            rgba[i].w = 255;
	}
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

    convertBGR2RGBA(h_bgr, h_rgba, WIDTH, HEIGHT);

    bool ok = checkResults(h_rgba, h_bgr, WIDTH*HEIGHT);

    if (ok) {
        std::cout << "Executed!! Results OK." << std::endl;
    } else {
        std::cout << "Executed!! Results NOT OK." << std::endl;
    }

    return 0;

}
