module sync_fifo1(
    clk             ,                                   
    srst            ,     
    din             , 
    wr_en           , 
    rd_en           , 
    dout            ,     
    full            , 
    almost_full     ,  
    empty           , 
    data_count
   
  ); 
                    
   parameter DATA_WIDTH       = 128;                   
   parameter ADDR_WIDTH       = 12;                   
   parameter RAM_DEPTH        = 1 << ADDR_WIDTH;        
   
   
   parameter SRAM_TYPE        = 0;
   parameter ASIC             = 1; 
   parameter FPGA             = 0;    
                 
   parameter ALMOST_FULL_NUM  = 2;     //将满值设置最多不能大于RAM_DEPTH
                 
                 
    input                               clk             ;           
    input                               srst            ;           
    input         [DATA_WIDTH-1:0]      din             ;           
    input                               wr_en           ;           
    input                               rd_en           ;           
    output      [DATA_WIDTH-1:0]        dout            ;           
    output   reg                        full            ;           
    output   reg                        almost_full     ;           
    output   reg                        empty           ;           
    output   reg  [ADDR_WIDTH:0]        data_count      ;  //data_count即作为控制空满信号用又作为输出信号用，比地址位宽多一位  
    
    
    
    //wire                      wr_en_allow ;       
    //wire                      rd_en_allow ;
    reg    [ADDR_WIDTH-1:0]   waddr;  
    reg    [ADDR_WIDTH-1:0]   raddr;
                                   
                 
    always@(posedge clk or negedge srst)
    begin
        if (srst == 1'b0)    data_count <= {(ADDR_WIDTH+1){1'b0}};
        else if (wr_en == 1'b1 && rd_en == 1'b0) 
        begin
            data_count <= data_count + 1'd1; //当FIFO进行写但不读时 增加1
        end
        else if (wr_en == 1'b0 && rd_en == 1'b1) 
        begin
            data_count <= data_count - 1'd1; //当FIFO进行读但不写时 减1 
        end
        else; //如果FIFO又读又写或不读也不写 则该计数器不变
    end
    
    always@(*)
    begin        
        if ( (rd_en == 1'b0 && data_count == RAM_DEPTH ) || (wr_en == 1'b1 && data_count == (RAM_DEPTH-1) ))
        begin
            full <= 1'b1; //如果FIFO不读并且data_count等于FIFO的深度时,或者data_count等于(data_count-1)并且写使能有效时满标志应该置1 其余情况置为0
        end
        else 
        begin
            full <= 1'b0;
        end
    end
    
    always@(*)
    begin
        if ((data_count == 0 ) || (rd_en == 1'b1 && data_count == 1  ) )
        begin
            empty <= 1'b1; //当FIFO中的data_count等于0或者等于1并且读有效时 Empty就应置1读空
        end
        else
        begin
            empty <= 1'b0;
        end

    end
                                  
    always@(*)
    begin
        if (data_count >  (RAM_DEPTH - ALMOST_FULL_NUM-2) )
        begin
            almost_full <= 1'b1; //data_count大于RAM的深度减去ALMOST_FULL_NUM时置有效，ALMOST_FULL_NUM可配
        end
        else 
        begin
            almost_full <= 1'b0;
        end
    end             
                                  
   // assign  wr_en_allow = wr_en;               
   // assign  rd_en_allow = rd_en;          
    
    
    always@(posedge clk or negedge srst)
    begin
        if (srst == 1'b0)    waddr <= 0;
        else if (wr_en == 1'b1)
        begin
            waddr <= waddr +1'b1;  
        end
        else;
    end     
    
    always@(posedge clk or negedge srst)
    begin
        if (srst == 1'b0)    raddr <= 0;
        else if (rd_en == 1'b1)
        begin
            raddr <= raddr +1'b1;  
        end
        else;
    end             
                 
      
  
    blk_ram1  #(
              .DATA_WIDTH    (DATA_WIDTH        ),
              .ADDR_WIDTH    (ADDR_WIDTH        )
              )
              
              u_blk_ram1(
                   .clka     (clk         ),
                   .clkb     (clk         ),
                   .ena      (wr_en       ),
                   .enb      (rd_en       ),
                   .addra    (waddr       ),
                   .addrb    (raddr       ),
                   .dina     (din         ),
                   .wea      (wr_en       ),
                   .doutb    (dout        )
              
                    );

      
endmodule

