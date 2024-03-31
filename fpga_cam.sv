module fpga_cam
#( 
   parameter                    DEPTH = 512,     // CAM depth
   parameter                    WIDTH = 36,     // CAM width
   parameter                    L = 4,          // vertical partition
   parameter                    N = 4,          // horizontal partition
   parameter                    TYPE = "FF"
)( 
    input  logic                        clk,    // clock
    input  logic                        rst_n,  // reset
    input  logic                        wEn,    // write enable
    input  logic[$clog2(DEPTH)-1 : 0]   wAddr,  // write address
    input  logic[WIDTH-1 : 0]           wPatt,  // write pattern
    input  logic[WIDTH-1 : 0]           wMask,  // pattern mask    
    input  logic[WIDTH-1 : 0]           mPatt,  // patern to match
    output logic                        match,  // match indicator 
    output logic[$clog2(DEPTH)-1 : 0]   mAddr   // matched address
);
    logic                        wEn_r;
    logic[$clog2(DEPTH)-1 : 0]   wAddr_r;
    logic[WIDTH-1 : 0]           wPatt_r;
    logic[WIDTH-1 : 0]           wMask_r; 
    logic[WIDTH-1 : 0]           mPatt_r;
    logic                        match_r; 
    logic[$clog2(DEPTH)-1 : 0]   mAddr_r;

    // input register
    always_ff @ (posedge clk) begin
        if(!rst_n) begin
            wEn_r <= 1'b0;
            wAddr_r <= '0;
            wPatt_r <= '0;
            wMask_r <= '0; 
            mPatt_r <= '0;
        end
        else begin
            wEn_r <= wEn;
            wAddr_r <= wAddr;
            wPatt_r <= wPatt;
            wMask_r <= wMask; 
            mPatt_r <= mPatt;
        end
    end

    generate
        if (TYPE=="BRAM") begin
            // UE-CAM(BRAM-based)
            ue_tcam #( 
                .DEPTH(DEPTH),
                .WIDTH(WIDTH),
                .L(L),
                .N(N)
            ) inst_ue_tcam ( 
                .clk(clk),
                .rst_n(rst_n),
                .wEn(wEn_r),
                .wAddr(wAddr_r),
                .wPatt(wPatt_r),
                .wMask(wMask_r), 
                .mPatt(mPatt_r),
                .match(match_r), 
                .mAddr(mAddr_r)
            );
        end
        else if(TYPE=="LUTRAM") begin
            dure_tcam #( 
                .DEPTH(DEPTH),
                .WIDTH(WIDTH)
            ) inst_dure_tcam ( 
                .clk(clk),
                .rst_n(rst_n),
                .wEn(wEn_r),
                .wAddr(wAddr_r),
                .wPatt(wPatt_r),
                .wMask(wMask_r), 
                .mPatt(mPatt_r),
                .match(match_r), 
                .mAddr(mAddr_r)
            );
        end
        else begin
            // G-AETCAM(FF-based)
            g_aetcam #( 
                .DEPTH(DEPTH),
                .WIDTH(WIDTH)
            ) inst_g_aetcam ( 
                .clk(clk),
                .rst_n(rst_n),
                .wEn(wEn_r),
                .wAddr(wAddr_r),
                .wPatt(wPatt_r),
                .wMask(wMask_r), 
                .mPatt(mPatt_r),
                .match(match_r), 
                .mAddr(mAddr_r)
            );
        end
    endgenerate

    // output register
    always_ff @ (posedge clk) begin
        if(!rst_n) begin
            mAddr <= '0;
            match <= 1'b0; 
        end
        else begin
            mAddr <= mAddr_r;
            match <= match_r; 
        end
    end

endmodule