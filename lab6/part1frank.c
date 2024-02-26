	int main()
{
    volatile int *LEDR_ptr = 0xFF200000;    
	volatile int *KEY_BASE = 0xFF200050;

    int value;

    while (1){
        value = *(KEY_BASE+3);
		if(value == 1){
			*LEDR_ptr = 0xFFFF;
        	*(KEY_BASE+3) = 0xFFFF;
		}else if(value == 2){
			*LEDR_ptr = 0;
        	*(KEY_BASE+3) = 0xFFFF;
		}
    }
}

