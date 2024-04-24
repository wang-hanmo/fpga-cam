module fpga_cam
#( 
   parameter                    DEPTH = 64,     // CAM depth
   parameter                    WIDTH = 36,     // CAM width
   parameter                    L = 4,          // vertical partition
   parameter                    N = 4,          // horizontal partition
   parameter                    WPNUM = 1,      // write port number
   parameter                    RPNUM = 1,      // read port number
   parameter                    TYPE = "BRAM"
)( 
    input  logic                                     clk,    // clock
    input  logic                                     rst_n,  // reset
    input  logic[WPNUM-1 : 0]                        wEn,    // write enable
    input  logic[WPNUM-1 : 0][$clog2(DEPTH)-1 : 0]   wAddr,  // write address
    input  logic[WPNUM-1 : 0][WIDTH-1 : 0]           wPatt,  // write pattern
    input  logic[WPNUM-1 : 0][WIDTH-1 : 0]           wMask,  // pattern mask (only for G-AETCAM)
    input  logic[WPNUM-1 : 0][DEPTH/L-1 : 0]         wKbit,  // Address coding (only for UE-TCAM)
    input  logic[RPNUM-1 : 0][WIDTH-1 : 0]           mPatt,  // patern to match
    output logic[RPNUM-1 : 0]                        match,  // match indicator 
    output logic[RPNUM-1 : 0][$clog2(DEPTH)-1 : 0]   mAddr   // matched address
);
    logic[WPNUM-1 : 0]                        wEn_r;
    logic[WPNUM-1 : 0][$clog2(DEPTH)-1 : 0]   wAddr_r;
    logic[WPNUM-1 : 0][WIDTH-1 : 0]           wPatt_r;
    logic[WPNUM-1 : 0][WIDTH-1 : 0]           wMask_r; 
    logic[WPNUM-1 : 0][DEPTH/L-1 : 0]         wKbit_r;
    logic[RPNUM-1 : 0][WIDTH-1 : 0]           mPatt_r;
    logic[RPNUM-1 : 0]                        match_r; 
    logic[RPNUM-1 : 0][$clog2(DEPTH)-1 : 0]   mAddr_r;

    // input register
    always_ff @ (posedge clk) begin
        if(!rst_n) begin
            wEn_r <= '0;
            wAddr_r <= '0;
            wPatt_r <= '0;
            wMask_r <= '0; 
            wKbit_r <= '0;
            mPatt_r <= '0;
        end
        else begin
            wEn_r <= wEn;
            wAddr_r <= wAddr;
            wPatt_r <= wPatt;
            wMask_r <= wMask; 
            wKbit_r <= wKbit;
            mPatt_r <= mPatt;
        end
    end

    generate
        if (TYPE=="BRAM") begin
            // UE-CAM(BRAM-based)
            if(WPNUM == 2 && RPNUM == 2) begin
                dual_port_ue_tcam #( 
                    .DEPTH(DEPTH),
                    .WIDTH(WIDTH),
                    .L(L),
                    .N(N)
                ) inst_ue_tcam ( 
                    .clk(clk),
                    .rst_n(rst_n),
                    .wEn_0(wEn_r[0]),
                    .wAddr_0(wAddr_r[0]),
                    .wPatt_0(wPatt_r[0]),
                    .wKbit_0(wKbit_r[0]),
                    .mPatt_0(mPatt_r[0]),
                    .match_0(match_r[0]), 
                    .mAddr_0(mAddr_r[0]),
                    .wEn_1(wEn_r[1]),
                    .wAddr_1(wAddr_r[1]),
                    .wPatt_1(wPatt_r[1]),
                    .wKbit_1(wKbit_r[1]),
                    .mPatt_1(mPatt_r[1]),
                    .match_1(match_r[1]), 
                    .mAddr_1(mAddr_r[1])
                );
            end
            else begin
                ue_tcam #( 
                    .DEPTH(DEPTH),
                    .WIDTH(WIDTH),
                    .L(L),
                    .N(N)
                ) inst_ue_tcam ( 
                    .clk(clk),
                    .rst_n(rst_n),
                    .wEn(wEn_r[0]),
                    .wAddr(wAddr_r[0]),
                    .wPatt(wPatt_r[0]),
                    .wKbit(wKbit_r[0]),
                    .mPatt(mPatt_r[0]),
                    .match(match_r[0]), 
                    .mAddr(mAddr_r[0])
                );
            end
        end
        else if(TYPE=="LUTRAM") begin
            dure_tcam #( 
                .DEPTH(DEPTH),
                .WIDTH(WIDTH)
            ) inst_dure_tcam ( 
                .clk(clk),
                .rst_n(rst_n),
                .wEn(wEn_r[0]),
                .wAddr(wAddr_r[0]),
                .wPatt(wPatt_r[0]),
                .mPatt(mPatt_r[0]),
                .match(match_r[0]), 
                .mAddr(mAddr_r[0])
            );
        end
        else begin
            // G-AETCAM(FF-based)
            if(WPNUM == 4 && RPNUM == 4) begin
            quad_port_g_aetcam #( 
                .DEPTH(DEPTH),
                .WIDTH(WIDTH)
            ) inst_g_aetcam ( 
                .clk(clk),
                .rst_n(rst_n),
                .wEn_0(wEn_r[0]),
                .wAddr_0(wAddr_r[0]),
                .wPatt_0(wPatt_r[0]),
                .wMask_0(wMask_r[0]), 
                .mPatt_0(mPatt_r[0]),
                .match_0(match_r[0]), 
                .mAddr_0(mAddr_r[0]),
                .wEn_1(wEn_r[1]),
                .wAddr_1(wAddr_r[1]),
                .wPatt_1(wPatt_r[1]),
                .wMask_1(wMask_r[1]), 
                .mPatt_1(mPatt_r[1]),
                .match_1(match_r[1]), 
                .mAddr_1(mAddr_r[1]),
                .wEn_2(wEn_r[2]),
                .wAddr_2(wAddr_r[2]),
                .wPatt_2(wPatt_r[2]),
                .wMask_2(wMask_r[2]), 
                .mPatt_2(mPatt_r[2]),
                .match_2(match_r[2]), 
                .mAddr_2(mAddr_r[2]),
                .wEn_3(wEn_r[3]),
                .wAddr_3(wAddr_r[3]),
                .wPatt_3(wPatt_r[3]),
                .wMask_3(wMask_r[3]), 
                .mPatt_3(mPatt_r[3]),
                .match_3(match_r[3]), 
                .mAddr_3(mAddr_r[3])
            );
            end
            else if(WPNUM == 3 && RPNUM == 3) begin
            triple_port_g_aetcam #( 
                .DEPTH(DEPTH),
                .WIDTH(WIDTH)
            ) inst_g_aetcam ( 
                .clk(clk),
                .rst_n(rst_n),
                .wEn_0(wEn_r[0]),
                .wAddr_0(wAddr_r[0]),
                .wPatt_0(wPatt_r[0]),
                .wMask_0(wMask_r[0]), 
                .mPatt_0(mPatt_r[0]),
                .match_0(match_r[0]), 
                .mAddr_0(mAddr_r[0]),
                .wEn_1(wEn_r[1]),
                .wAddr_1(wAddr_r[1]),
                .wPatt_1(wPatt_r[1]),
                .wMask_1(wMask_r[1]), 
                .mPatt_1(mPatt_r[1]),
                .match_1(match_r[1]), 
                .mAddr_1(mAddr_r[1]),
                .wEn_2(wEn_r[2]),
                .wAddr_2(wAddr_r[2]),
                .wPatt_2(wPatt_r[2]),
                .wMask_2(wMask_r[2]), 
                .mPatt_2(mPatt_r[2]),
                .match_2(match_r[2]), 
                .mAddr_2(mAddr_r[2])
            );
            end
            else if(WPNUM == 2 && RPNUM == 2) begin
            dual_port_g_aetcam #( 
                .DEPTH(DEPTH),
                .WIDTH(WIDTH)
            ) inst_g_aetcam ( 
                .clk(clk),
                .rst_n(rst_n),
                .wEn_0(wEn_r[0]),
                .wAddr_0(wAddr_r[0]),
                .wPatt_0(wPatt_r[0]),
                .wMask_0(wMask_r[0]), 
                .mPatt_0(mPatt_r[0]),
                .match_0(match_r[0]), 
                .mAddr_0(mAddr_r[0]),
                .wEn_1(wEn_r[1]),
                .wAddr_1(wAddr_r[1]),
                .wPatt_1(wPatt_r[1]),
                .wMask_1(wMask_r[1]), 
                .mPatt_1(mPatt_r[1]),
                .match_1(match_r[1]), 
                .mAddr_1(mAddr_r[1])
            );
            end
            else begin
            g_aetcam #( 
                .DEPTH(DEPTH),
                .WIDTH(WIDTH)
            ) inst_g_aetcam ( 
                .clk(clk),
                .rst_n(rst_n),
                .wEn(wEn_r[0]),
                .wAddr(wAddr_r[0]),
                .wPatt(wPatt_r[0]),
                .wMask(wMask_r[0]), 
                .mPatt(mPatt_r[0]),
                .match(match_r[0]), 
                .mAddr(mAddr_r[0])
            );
            end
        end
    endgenerate

    // output register
    always_ff @ (posedge clk) begin
        if(!rst_n) begin
            mAddr <= '0;
            match <= '0; 
        end
        else begin
            mAddr <= mAddr_r;
            match <= match_r; 
        end
    end

endmodule