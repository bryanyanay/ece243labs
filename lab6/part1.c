


int main(void) {

    volatile int *ledPtr = 0xff200000;
    volatile int *keyPtr = 0xff200050;
    int ledStatus = 0;

    // turn off leds and clear key edge capture bits just in case
    *ledPtr = 0;
    *(keyPtr+3) = 0xffffffff;

    while (1) {
        if (ledStatus) {
            if (*(keyPtr+3) & 0x2) {
                *(keyPtr+3) = 0xffffffff;
                *(ledPtr) = 0;
                ledStatus = 0;
            }
        } else {
            if (*(keyPtr+3) & 0x1) {
                *(keyPtr+3) = 0xffffffff;
                *(ledPtr) = 0xffffffff;
                ledStatus = 1;
            }
        }
    }
}