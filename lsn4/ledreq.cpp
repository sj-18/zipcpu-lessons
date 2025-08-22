#include <stdio.h>
#include <stdlib.h>
#include "Vledreq.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

    
//Instatiate our design
Vledreq *tb;
unsigned int tickcount = 0;
VerilatedVcdC* tfp;

void tick(void)
{
    tickcount++;
    tb->eval();
    if(tfp)
    {
        tfp->dump(tickcount * 10 - 2);  //Combinational logic settled before posedge of clk
    }
    tb->i_clk = 1;
    tb->eval();  //Actual positive edge of the clock
    if(tfp)
    {
        tfp->dump(tickcount * 10);  
    }
    tb->i_clk = 0;
    tb->eval();  // Negative edge of the clock
    if(tfp)
    {
        tfp->dump(tickcount * 10 + 5); 
        tfp->flush();
    }    
    
}

unsigned wb_read(unsigned a) //Wishbone Read
{
tb->i_we = 0; 
tb->i_request = tb->i_cyc = 1;
tb->eval();
tb->i_addr = a;

//Make the read request
while(tb->o_stall) //If stalled, wait
    tick();
tick();
tb->i_request = 0;

//Wait for the ack
while(!tb->o_ack)
    tick();

//Idle the bus and read the response
tb->i_cyc = 0;
return tb->o_data;
}

void wb_write(unsigned a, unsigned d) //Wishbone Write
{
tb->i_we = 1;
tb->i_request = tb->i_cyc = 1;
tb->eval();
tb->i_addr = a;
tb->i_data = d;

//Make the write request
while(tb->o_stall) //If stalled, wait
    tick();
tick();
tb->i_request = 0;

//Wait for the ack
while(!tb->o_ack)
    tick();

//Idle the bus and return
tb->i_cyc = 0;
}

int main(int argc , char **argv)
{
    //Call commandArgs first
    Verilated::commandArgs(argc , argv);

    // Instantiate our design
    tb = new Vledreq;
    
    //Generate a trace
    Verilated::traceEverOn(true); 
    tfp = new VerilatedVcdC;
    tb->trace(tfp , 99);
    tfp->open("ledreqtrace.vcd");
    
    int last_led, last_state, state;
    last_led = tb->o_led;
    last_state = 0;
    state = wb_read(0);
    printf("Initial State is %d \n",state);

	for(int k=0; k<2; k++)  //2 cycles
    {
        for(int i=0; i<5; i++) //5 empty cycles at the start
            tick();

        wb_write(0,0); //Start the LED walker
        tick();

        while( (state=wb_read(0) ) != 0)
        {
            if((tb->o_led != last_led) || (state != last_state))
            {
                printf("%6d: State #%2d ", tickcount, state);
                for(int j=0; j<6; j++)
                {
                    if(tb->o_led & (1<<j))
                        printf("1");
                    else
                        printf("0");
                }
            printf("\n");
            }
            //tick();
            last_state = state;
            last_led = tb->o_led;
        }		
	}
	tfp->close();
	delete tfp;
	delete tb;
}