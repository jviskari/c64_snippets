//#include <stdio.h>
#define printf(...)
#include <c64.h>
#include <cbm.h>
#include <device.h>

#define LFN_IN (1)
#define LFN_OUT (2)

 
static unsigned char file_amount = 0;
static struct cbm_dirent dirent[128];


static unsigned char dev_in = 8;
static unsigned char dev_out = 9;

static unsigned char block[0x1fff];

static void getDir(unsigned char dev)
{
    unsigned char i;
	unsigned char rv = 0;
    rv = cbm_opendir(LFN_IN,dev);
    
	while (rv == 0)
	{
		rv = cbm_readdir(LFN_IN,&dirent[file_amount]);
		if ( rv == 0 )
		{
			file_amount++;
		}      
	}

	for(i = 1; i < file_amount; i++)
	{
        printf("%s\n", &(dirent[i].name[0]));
	}

    cbm_closedir(1);
}

static void copyFile(unsigned char fn, unsigned char devOut, unsigned char devIn)
{
     int bytesRead;
	 int bytesWritten;
	 unsigned char rv;
     rv = cbm_open (LFN_IN  ,devIn, CBM_READ, &(dirent[fn].name[0]));
	 printf ("Source(%d:%s): st:%d\n", devIn, &(dirent[fn].name[0]),rv);
     rv = cbm_open (LFN_OUT ,devOut, CBM_WRITE, &(dirent[fn].name[0]));                                
     printf ("Dest(%d:%s): :st%d\n", devOut, &(dirent[fn].name[0]),rv);
    
	 do
	 {

		bytesRead = cbm_read (LFN_IN, &block, sizeof(block));
		if (bytesRead > 0 )
		{
			bytesWritten = cbm_write (LFN_OUT, &block, bytesRead);
		}
		else
		{
			bytesWritten = 0;
		}
        printf ("Read:%d Write:%d\n",bytesRead, bytesWritten);

	 }while( bytesRead > 0 );

     printf("Done\n");

     cbm_close(LFN_IN);
	 cbm_close(LFN_OUT);
}

int main(int argc, char *argv[])
 {
	unsigned char fileNum = 1;
    dev_in = getcurrentdevice();

	getDir(dev_in);
		
	while(fileNum < file_amount)
	{
        copyFile(fileNum++, dev_out, dev_in);
	}


}