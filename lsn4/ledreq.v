`default_nettype none

module ledreq(i_clk, i_request, i_we, i_addr, i_data, i_cyc, o_stall, o_led, o_ack, o_data);

input wire i_clk, i_request, i_we, i_cyc, i_addr; //Wishbone bus slave interface
input wire[31:0] i_data;

output reg o_ack;
output reg[5:0] o_led; //LED walker
output wire[31:0] o_data; //32 bits output data that will contain the state
output wire o_stall;

reg[3:0] state; //Current state of the FSM
wire busy;

initial state = 4'b0;
initial o_ack = 1'b0;
initial o_led = 6'b0;

always @(posedge i_clk)
begin
    o_ack <= (i_request) && (!o_stall);   //Immediately ack on request and when not stalled
end

assign o_stall = (busy) && (i_we);
assign o_data = {28'h0, state};

always @(posedge i_clk)
begin
    if((i_request) && (!busy) && (i_we))
        begin
            state <= 4'h1;
        end else if(state >= 4'hb) begin
            state <= 4'h0;
        end else if (state != 0) begin
            state <= state + 1'b1;
        end
end
assign busy = (state != 0);

always @(posedge i_clk)
begin
    case(state)
    4'h1: o_led <= 6'b00_0001;
    4'h2: o_led <= 6'b00_0010;
    4'h3: o_led <= 6'b00_0100;
    4'h4: o_led <= 6'b00_1000;
    4'h5: o_led <= 6'b01_0000;
    4'h6: o_led <= 6'b10_0000;
    4'h7: o_led <= 6'b01_0000;
    4'h8: o_led <= 6'b00_1000;
    4'h9: o_led <= 6'b00_0100;
    4'ha: o_led <= 6'b00_0010;
    4'hb: o_led <= 6'b00_0001;
    default: o_led <= 6'b00_0000;
    endcase
end

//verilator lint_off UNUSEDSIGNAL
wire [33:0] unused;
assign unused = { i_addr, i_cyc, i_data}; //We just added these to keep the standard bus interface signals
//verilator lint_on UNUSEDSIGNAL


endmodule
