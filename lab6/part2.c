

struct audio_t {
    volatile unsigned int control;
    volatile unsigned char rarc;
    volatile unsigned char ralc;
    volatile unsigned char wsrc;
    volatile unsigned char wslc;
    volatile unsigned int left;
    volatile unsigned int right;
};

int main() {

    struct audio_t *audioPtr = 0xff203040;
    int leftSample, rightSample;

    while (1) {
        if (audioPtr->rarc > 0) {
            leftSample = audioPtr->left;
            rightSample = audioPtr->right;
            audioPtr->left = leftSample;
            audioPtr->right = rightSample;
        }
    }
}