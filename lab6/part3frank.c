/*******************************************************************************
 * This program performs the following:
 *  1. checks if there is a sample ready to be read.
 * 	2. reads that sample from microphone channels.
 * 	3. writes that sample to the audio output channels.
 ******************************************************************************/
#define AUDIO_BASE			0xFF203040
#define SW_BASE	0xFF200040
int main(void) {
    // Audio codec Register address
    volatile int * audio_ptr = (int *) AUDIO_BASE;
	volatile int * sw_ptr = (int *) SW_BASE;

	int switch_value, period;
	
	// This is an infinite loop checking the RARC to see if there is at least a single
	// entry in the input fifos.   If there is, just copy it over to the output fifo.
	// The timing of the input fifo controls the timing of the output

    while (1) {
		// load both input microphone channels - just get one sample from each
		switch_value = *sw_ptr;
		
		if(switch_value==0) period = 80;
		else period = 80 - (log2(switch_value)+1) * 7;
		
		// store both of those samples to output channels
		for(int i = 0; i< period/2; i++){
			*(audio_ptr + 2) = 0x00ffffff;
			*(audio_ptr + 3) = 0x00ffffff;
		}
		
		for(int i = 0; i< period/2; i++){
			*(audio_ptr + 2) = 0;
			*(audio_ptr + 3) = 0;
		}
	}
}