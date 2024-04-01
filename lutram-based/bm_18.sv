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
    logic [5:0] addra_sel;
    logic [5:0] addrb_sel;
    logic [5:0] addrc_sel;

    assign addra_sel = we ? addrd : addra;
    assign addrb_sel = we ? addrd : addrb;
    assign addrc_sel = we ? addrd : addrc;

    lutram #(
        .Depth(64),
        .Width(1)
    ) inst_luta (
        .clk(clk),
        .wen(we),
        .addr(addra_sel),
        .din(dia), 
        .dout(doa) 
    );
    lutram #(
        .Depth(64),
        .Width(1)
    ) inst_lutb (
        .clk(clk),
        .wen(we),
        .addr(addrb_sel),
        .din(dib), 
        .dout(dob) 
    );
    lutram #(
        .Depth(64),
        .Width(1)
    ) inst_lutc (
        .clk(clk),
        .wen(we),
        .addr(addrc_sel),
        .din(dic), 
        .dout(doc) 
    );
    lutram #(
        .Depth(64),
        .Width(1)
    ) inst_lutd (
        .clk(clk),
        .wen(we),
        .addr(addrd),
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