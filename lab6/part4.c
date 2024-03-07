
/*
delay of 0.4s

sampling period of 0.000125s

delay lasts for 3200 samples

*/

struct audio_t {
    volatile unsigned int control;
    volatile unsigned char rarc;
    volatile unsigned char ralc;
    volatile unsigned char warc;
    volatile unsigned char walc;
    volatile unsigned int ldata;
    volatile unsigned int rdata;
};

unsigned int outputs[3200]; 

struct audio_t *const audioPtr = ((struct audio_t *)0xff203040);

int main() {

    for (int head = 0; head < 3200; head++) {
        outputs[head] = 0;
    }

    int head = 0;
    while (1) {
        if (audioPtr->rarc > 0) {
            unsigned int temp = audioPtr->rdata; // this is read then thrown away
            temp = audioPtr->ldata;

            temp = temp + 0.5 * outputs[head];
            audioPtr->ldata = temp;
            audioPtr->rdata = temp;
            outputs[head] = temp;
        }

        head++;
        if (head >= 3200)
            head = 0;
    }
}