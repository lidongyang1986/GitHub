#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <sched.h>
#include <pthread.h>
#include <fcntl.h>
#include <pthread.h>
#include <string.h>

#define DEVPATH "/dev/nvme0n1"

//#define measure_check_debug 
//#define measure_during_proceeding

int measure_page_number=362;
int ASC_convertor_address_load=1;
int ASC_convertor_address_FPGA=131073;
int warmup_rd_addr_unrelate=128;
int warmup_rd_addr_iteration=100;
int debug_print_number=100;


/* CPU_MIN: minimum amount of CPU the benchmark has to clock up */
const  double CPU_MIN = 2.0;

void usage()
{
  printf(" Usage:\n");
  printf("bench <matrix.mtx>\n");
}
main(int argc, char *argv[])
{
  FILE* fp;
  int n,m,nz;
  int *ia, *ja, *ic, *jc;
  int i,ii,jj;
  double *a, *c;
  int ind_base, nz1;
  int *irn,*jcn, *nrow;
  double *val;
  clock_t clock_sta,clock_sto;
  double avg;
  enum {MAXLINE = 100000};
  char line[MAXLINE+1];
  /* number of runs to clock up the CPU to exceed CPU_MIN */
  int nrun;
  long flops;
  double tcomp1,tcomp2;
  int measure_loops;



    if ( (fp = fopen(argv[1],"r")) == NULL) {
      printf(" can not open file %s\n",argv[1]);
      usage();
      return 0;
    }


/*operate nvme dev start*/
    int nvme_device;
    int file_rd_return;
    int pagesize;
    char* buffer;
    char* rd_buf; 
    int ret_nvme_op=0; 	


    pagesize = getpagesize();
    //printf("pagesize is %d\n", pagesize);
    
    if(0 != posix_memalign((void**)&buffer, pagesize, pagesize * measure_page_number)){
        printf("Errori in posix_memalign\n");
    }
    if(0 != posix_memalign((void**)&rd_buf, pagesize, pagesize * measure_page_number)){
        printf("Errori in posix_memalign\n");
    }

	file_rd_return=fread (buffer,measure_page_number,pagesize,fp);
	//printf("Rd file page size= %d\n", file_rd_return);



	//printf("\n************write to Host_addr***********\n");
	    if(!(nvme_device = open(DEVPATH, O_RDWR| O_DIRECT))){                    
		//printf("3open nvme device error\n");            
		return 1;    
	    }else{
		//printf("3Open nvme device %s\n", DEVPATH);
	    }
	for(measure_loops=0; measure_loops<measure_page_number; measure_loops++)
	{
        lseek(nvme_device, pagesize * (measure_loops+ASC_convertor_address_load), SEEK_SET);
        ret_nvme_op = write(nvme_device, buffer + pagesize * measure_loops, pagesize);
	}

	close(nvme_device);










/*scan nvme file start*/


    FILE *fp_nvme_file;
    int  *irn_nvme,*jcn_nvme;
    //int *irn_nvme;

    if(!(fp_nvme_file = fopen(DEVPATH, "r"))){
        //printf("1open nvme_file device error %s\n", DEVPATH);
        return 1;
    }else{
        //printf("1open nvme_file device successful %s\n", DEVPATH);
    }
    fseek (fp_nvme_file , pagesize *ASC_convertor_address_load, SEEK_SET);

      /* get rid of comments */
      do {
	fgets(line, MAXLINE, fp_nvme_file);
      } while (line[0] == '%');


      /* read in he row and columb sizes and the number of nonzeros */
      sscanf(line," %d %d %d",&n, &m, &nz) ;  


      /* read in the matrix in .mtx format */
      irn_nvme = malloc((nz)*sizeof(int));
      if (irn_nvme == NULL) {
	printf("fail allocating for irn\n");
	return 1;
      }
      jcn_nvme = malloc((nz)*sizeof(int));
      if (jcn_nvme == NULL) {
	printf("fail allocating for jcn\n");
	return 1;
      }
/*
    if(0 != posix_memalign((void**)&irn_nvme, pagesize, pagesize * measure_page_number)){
        printf("Errori in posix_memalign\n");
    }
*/

#ifdef measure_during_proceeding
     	fseek (fp_nvme_file , (ASC_convertor_address_FPGA+warmup_rd_addr_unrelate) * pagesize , SEEK_SET);
        for (i = 0; i < debug_print_number * warmup_rd_addr_iteration; i++) {
	 	fscanf(fp_nvme_file,"%d ",&irn_nvme[i]);
        }
#endif

	int fscanf_return;
	long fscanf_loops=0;

      fseek (fp_nvme_file , ASC_convertor_address_load * pagesize , SEEK_SET);
      clock_sta = clock();
      
      while(1){
	fscanf_return=fscanf(fp_nvme_file,"%d %d",&irn_nvme[fscanf_loops],&jcn_nvme[fscanf_loops]);
	if(fscanf_return==0){printf("scanf_loop=%ld\n", fscanf_loops);break;}
	fscanf_loops++;
      }
      clock_sto = clock();
	tcomp1=(clock_sto - clock_sta)/(double) CLOCKS_PER_SEC;
	printf("\nHost scanf file func = %g s \n\n", tcomp1);

#ifdef measure_check_debug
	//printf("Host check file head : \n%d\t%d\t%d\t", n,m,nz);
	printf("Host check file head : \n");
	for (i = 0; i < debug_print_number/2; i++)
	{
	printf("%d\t", irn_nvme[i]);
	printf("%d\t", jcn_nvme[i]);	
	}
#endif


	fclose(fp_nvme_file);

/*scan nvme file end*/
















/*read JASAP data up from FPGA*/
	sleep(1);

	unsigned int *ibuf;

	    if(!(nvme_device = open(DEVPATH, O_RDWR| O_DIRECT))){                    
		//printf("3open nvme device error\n");            
		return 1;    
	    }else{
		//printf("3Open nvme device %s\n", DEVPATH);
	    }

#ifdef measure_during_proceeding
	for(measure_loops=0;measure_loops<warmup_rd_addr_iteration;measure_loops++)
	{
	lseek(nvme_device, pagesize *(ASC_convertor_address_FPGA+measure_loops+warmup_rd_addr_unrelate), SEEK_SET);
        ret_nvme_op = read(nvme_device, rd_buf, pagesize);	
	}
#endif


        ibuf = (unsigned int *)rd_buf;

	clock_sta = clock();
	for(measure_loops=0; measure_loops<measure_page_number; measure_loops++)
	{
		lseek(nvme_device, pagesize * (measure_loops + ASC_convertor_address_FPGA), SEEK_SET);
		ret_nvme_op = read(nvme_device, rd_buf + pagesize * measure_loops, pagesize);
	}	
        clock_sto = clock();

#ifdef measure_check_debug
	    	printf("\nFPGA check file data :	\n");
		int print_loop;
		for(print_loop=0;print_loop<debug_print_number;print_loop++)
		{
		printf("%d\t", ibuf[print_loop]);
		}

#endif

	tcomp2=(clock_sto - clock_sta)/(double) CLOCKS_PER_SEC; 
	printf("\nFPGA scanf file func = %g s \n\n", tcomp2);



	long checking=0;
	while(1)
	{
		if((ibuf[checking*2]!=irn_nvme[checking])|(ibuf[checking*2+1]!=jcn_nvme[checking]))
		{printf("mistake at %ld\n", checking);break;}
		else checking++;
	}


	printf("Host=%d %d %d %d %d %d\n",irn_nvme[0],jcn_nvme[0],irn_nvme[1],jcn_nvme[1],irn_nvme[2],jcn_nvme[2]);
	printf("FPGA=%d %d %d %d %d %d\n",ibuf[0],ibuf[1],ibuf[2],ibuf[3],ibuf[4],ibuf[5]);

	close(nvme_device);

}
