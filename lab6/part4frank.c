/*******************************************************************************
 * This program performs the following:
 *  1. checks if there is a sample ready to be read.
 * 	2. reads that sample from microphone channels.
 * 	3. writes that sample to the audio output channels.
 ******************************************************************************/
#define AUDIO_BASE			0xFF203040
#define DAMPING_FACTOR        0.6   // Damping factor for the echo
#define DELAY_TIME_SEC        0.4   // 0.4 second delay
#define SAMPLE_RATE 8000
#define BUFFER_SIZE (int)(SAMPLE_RATE * DELAY_TIME_SEC)	
	
	
int bufferLeft[BUFFER_SIZE];
int bufferRight[BUFFER_SIZE];

volatile int * audio_ptr = (int *) AUDIO_BASE;

int 
echo(int t, int lor) {
	if(t<0) return 0;
	if(t<BUFFER_SIZE && lor != 0){
		if(lor == -1)return bufferLeft[t];
		else return bufferRight[t];
	}
	if(t == 2*BUFFER_SIZE) t = BUFFER_SIZE;
	int fifospace = *(audio_ptr + 1); // read the audio port fifospace register
	if ((fifospace & 0x000000FF) > 0) // check RARC to see if there is data to read
	{
		int left = *(audio_ptr + 2);
		int right = *(audio_ptr + 3);
		left += DAMPING_FACTOR*echo(t-BUFFER_SIZE, -1);
		right += DAMPING_FACTOR*echo(t-BUFFER_SIZE, 1);
		bufferLeft[t] = left;
		// load both input microphone channels - just get one sample from each
		bufferRight[t] = right;
		*(audio_ptr + 2) = left;
		*(audio_ptr + 3) = right;
		t++;
	}
	return echo(t, 0);
}

int main(void) {
    echo(0, 0);
}