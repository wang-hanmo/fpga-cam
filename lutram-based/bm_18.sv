module bm_18
(
    input  logic        clk,
    input  logic        we,
    input  logic [5:0]  addra,
    input  logic        dia,
    input  logic [5:0]  addrb,
    input  logic        dib,
    input  logic [5:0]  addrc,
    input  logic        dic,
    input  logic [5:0]  addrd,
    input  logic        did,
    input  logic        cin,
    output logic        cout
);
    logic doa, dob, doc, dod;

    lutram #(
        .Depth(64),
        .Width(1)
    ) inst_luta (
        .clk(clk),
        .wen(we),
        .raddr(addra),
        .waddr(addrd),
        .din(dia), 
        .dout(doa) 
    );
    lutram #(
        .Depth(64),
        .Width(1)
    ) inst_lutb (
        .clk(clk),
        .wen(we),
        .raddr(addrb),
        .waddr(addrd),
        .din(dib), 
        .dout(dob) 
    );
    lutram #(
        .Depth(64),
        .Width(1)
    ) inst_lutc (
        .clk(clk),
        .wen(we),
        .raddr(addrc),
        .waddr(addrd),
        .din(dic), 
        .dout(doc) 
    );
    lutram #(
        .Depth(64),
        .Width(1)
    ) inst_lutd (
        .clk(clk),
        .wen(we),
        .raddr(addrd),
        .waddr(addrd),
        .din(did), 
        .dout(dod) 
    );

    always_comb begin : carry_chains
        if(dod) begin
            if(doc) begin
                if(dob) begin
                    if(doa) begin
                        cout = cin;
                    end 
                    else begin
                        cout = 1'b0;
                    end
                end 
                else begin
                    cout = 1'b0;
                end
            end 
            else begin
                cout = 1'b0;
            end
        end 
        else begin
            cout = 1'b0;
        end
    end

endmodule