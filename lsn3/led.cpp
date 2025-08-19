#include <stdio.h>
#include <stdlib.h>
#include "Vled.h"
#include "verilated.h"
#include "verilated_vcd_c.h"


void tick(int tickcount, Vled *tb, VerilatedVcdC *tfp)
{
    tb -> eval();
    if(tfp)
    {
        tfp->dump(tickcount * 10 - 2);
    }
    tb -> i_clk = 1;
    tb -> eval();
    if(tfp)
    {
        tfp->dump(tickcount * 10);
    }
    tb -> i_clk = 0;
    tb -> eval();
    if(tfp)
    {
        tfp->dump(tickcount * 10 + 5);
        tfp->flush();
    }    
    
}

int main(int argc , char **argv)
{
    //Call commandArgs first
    Verilated :: commandArgs(argc , argv);
    
    //Instatiate our design
    Vled *tb = new Vled;

    //Generate a trace
    unsigned tickcount = 0;
    Verilated :: traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    tb -> trace(tfp , 99);
    tfp -> open("ledtrace.vcd");
    
    int last_led;
    last_led = tb -> o_led;

	for(int k=0; k<(1<<10); k++) {
		tick(++tickcount, tb, tfp);

		// Now let's print our results
		if (last_led != tb->o_led) {
			printf("k = %7d, ", k);
			printf("led = %02x:", tb->o_led);
			for(int j=0; j<6; j++) {
				if(tb->o_led & (1<<j))
					printf("O");
				else
					printf("-");
			} printf("\n");
		} last_led = tb->o_led;
	}
}
