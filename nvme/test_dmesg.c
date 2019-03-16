
#include <linux/nvme.h>
#include <sys/ioctl.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <signal.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>


int main(int argc, char **argv)
{
   unsigned char buf[4096];
   unsigned char txbf[4096];
   FILE *fp;
   int bytes_read;
   //int Success;
 
   fp = fopen("/dev/nvme0n1","r+"); // read mode   "r" "w+" "r+"
 
   if( fp == NULL )
   {
      perror("Error while opening the file.\n");
      exit(EXIT_FAILURE);
   }
   else 
	printf("dev open good\n");

	int i;


	for(i=0;i<4096;i++)
	buf[i]=i+0x30;
/*
   	fseek (fp , 81920 , SEEK_SET);
 	bytes_read = fwrite(buf, 1, 4096, fp);
	printf("Write %d byte\n", bytes_read);


	buf[i]=0;


    	fseek (fp , 20480 , SEEK_SET);
 	bytes_read = fread(buf, 1, 4096, fp);
	printf("Read %d byte\n Rx=%x\n", bytes_read,buf[0]);
   	
	fseek (fp , 81920 , SEEK_SET);
 	bytes_read = fread(buf, 1, 4096, fp);
	printf("Read %d byte\n Rx=%x\n", bytes_read,buf[0]);

   	fseek (fp , 8192 , SEEK_SET);
 	bytes_read = fread(buf, 1, 4096, fp);
	printf("Read %d byte\n Rx=%x\n", bytes_read,buf[0]);

   	fseek (fp , 4096 , SEEK_SET);
 	bytes_read = fread(buf, 1, 4096, fp);
	printf("Read %d byte\n Rx=%x\n", bytes_read,buf[0]);
*/

    	fseek (fp , 409600 , SEEK_SET);
 	bytes_read = fread(buf, 1, 4096, fp);
	printf("Read %d byte\n Rx=%x\n", bytes_read,buf[0]);


   fclose(fp);
   return 0;
}

