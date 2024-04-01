module fpga_cam_tb;

    logic                        clk;
    logic                        rst_n;
    logic                        wEn;
    logic[5 : 0]                 wAddr;
    logic[35 : 0]                wPatt;
    logic[35 : 0]                wMask;
    logic[15 : 0]                wKbit;
    logic[35 : 0]                mPatt;
    logic                        match;
    logic[5 : 0]                 mAddr;

    fpga_cam#( 
    .DEPTH(64),
    .WIDTH(36),
    .L(4),
    .N(4),
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
    wAddr = 6'h10;
    wPatt = 36'h1234;
    wMask = 36'h0;
    wKbit = 16'h0001;
    wEn = 1'b1;
    #1280;
    wEn = 1'b0;
    mPatt = 36'h1234;
    #40;
    $display("match = %b, mAddr = %h", match, mAddr);
    end
endmodule