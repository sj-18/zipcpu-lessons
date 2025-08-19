/*This is a LED walker example where the LEDs are turned ON
 one after the other,i.e, one LED is awlays ON and moves
 back and forth like it is walking up and down*/

`default_nettype none

module led(i_clk, o_led);
    input wire i_clk;
    output reg[5:0] o_led; //Considering 6 LEDs on the TangNano 9K FPGA
    reg [3:0] led_index;

    initial o_led = 6'b11_1110; //For TangNano 9K LEDs need to pull-down to turn ON
    initial led_index = 0;

    always @(posedge i_clk)
    begin
        //if(stb)
        begin
            if (led_index > 4'h8)
                led_index <= 0;
            else
                led_index <= led_index + 1'b1;  
        end
    end

    always @(posedge i_clk)
    begin
    o_led <= 6'b11_1110;
    case(led_index)
    4'h0: o_led <= 6'b11_1110;
    4'h1: o_led <= 6'b11_1101;
    4'h2: o_led <= 6'b11_1011;
    4'h3: o_led <= 6'b11_0111;
    4'h4: o_led <= 6'b10_1111;
    4'h5: o_led <= 6'b01_1111;
    4'h6: o_led <= 6'b10_1111;
    4'h7: o_led <= 6'b11_0111;
    4'h8: o_led <= 6'b11_1011;
    4'h9: o_led <= 6'b11_1101;
    default: o_led <= 6'b11_1110;
    endcase
    end

    /* Uncomment this code if programming on the FPGA to make LEDs observable
    //stb and counter logic used to help slow down the LED walker
    parameter CSIZE = 26; //Change to increase/decrease walker speed
    reg [CSIZE-1:0] counter;
    reg stb;
    initial counter = 0;
    initial stb = 0;
        
    always @(posedge i_clk)
    begin
        if (counter == (1 << (CSIZE-1)) - 1)
        begin
            counter <= 0;
            stb <= 1; //Asserted everytime counter rolls-over
        end else begin
            counter <= counter + 1;
            stb <= 0;
        end
    end
    */


    /* Formal Verification done using SymbiYosys (led.sby file)
   The ifdef block prevents synthesis and placement on an actual FPGA
    */
`ifdef FORMAL  
    reg f_valid_output;
    
    always @(*)
        assert(led_index <= 4'h9);

    always @(*)
    begin
        /* If f_valid_ouput is not set to 1 at any point,
        the o_led state is illegal and the verification fails. 
        */
        f_valid_output = 0;
        
        case(o_led)
        6'b11_1110: f_valid_output = 1'b1;
        6'b11_1101: f_valid_output = 1'b1;
        6'b11_1011: f_valid_output = 1'b1;
        6'b11_0111: f_valid_output = 1'b1;
        6'b10_1111: f_valid_output = 1'b1;
        6'b01_1111: f_valid_output = 1'b1;
        endcase

        assert(f_valid_output);
    end

`endif

endmodule


