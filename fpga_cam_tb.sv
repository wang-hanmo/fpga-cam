module fpga_cam_tb;

    logic                               clk;
    logic                               rst_n;
    logic[3 : 0]                        wEn;
    logic[3 : 0][5 : 0]                 wAddr;
    logic[3 : 0][35 : 0]                wPatt;
    logic[3 : 0][35 : 0]                wMask;
    logic[3 : 0][15 : 0]                wKbit;
    logic[3 : 0][35 : 0]                mPatt;
    logic[3 : 0]                        match;
    logic[3 : 0][5 : 0]                 mAddr;

    fpga_cam#( 
    .DEPTH(64),
    .WIDTH(36),
    .L(4),
    .N(4),
    .WPNUM(1),
    .RPNUM(1),
    .TYPE("BRAM")
    ) inst_fpga_cam( 
        .clk(clk),
        .rst_n(rst_n),
        .wEn(wEn),
        .wAddr(wAddr),
        .wPatt(wPatt),
        .wMask(wMask),
        .wKbit(wKbit),
        .mPatt(mPatt),
        .match(match),
        .mAddr(mAddr)
    );

    initial clk = 1'b0;
    always #10 clk = ~clk;

    initial begin
    rst_n = 1'b0;
    #100;
    rst_n = 1'b1;
    #100;
    wAddr[0] = 6'h10;
    wPatt[0] = 36'h1234;
    wMask[0] = 36'h0;
    wKbit[0] = 16'h0001;
    wEn[0] = 1'b1;
    // wAddr[1] = 6'h0f;
    // wPatt[1] = 36'h808080808;
    // wMask[1] = 36'hffff11111;
    // wKbit[1] = 16'h5678;
    // wEn[1] = 1'b0;
    // wAddr[2] = 6'h3e;
    // wPatt[2] = 36'habcdefabc;
    // wMask[2] = 36'h868686868;
    // wKbit[2] = 16'h9abc;
    // wEn[2] = 1'b0;
    // wAddr[3] = 6'h10;
    // wPatt[3] = 36'h777777777;
    // wMask[3] = 36'hdeadbeaf0;
    // wKbit[3] = 16'hdef2;
    // wEn[3] = 1'b0;
    #1280;
    wEn = '0;
    mPatt[0] = 36'h1234;
    // mPatt[1] = 36'hffff;
    // mPatt[2] = 36'h1111;
    // mPatt[3] = 36'h8000;
    #40;
    $display("match_0 = %b, mAddr_0 = %h", match[0], mAddr[0]);
    // $display("match_1 = %b, mAddr_1 = %h", match[1], mAddr[1]);
    // $display("match_2 = %b, mAddr_2 = %h", match[2], mAddr[2]);
    // $display("match_3 = %b, mAddr_3 = %h", match[3], mAddr[3]);
    end
endmodule