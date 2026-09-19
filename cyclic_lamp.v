module cyclic_lamp(
          input clk,
			 input rst,
			 output reg[2:0] light);
			 
			 parameter clk_freq = 50_000_000;   //make fpga to a clock
          parameter hold_sec = 1;  // delay for each color
			 localparam max=clk_freq*hold_sec-1;
			 localparam s0=2'd0,s1=2'd1,s2=2'd2;
			 localparam RED=3'b100,GREEN=3'b010,YELLOW=3'b001;
			 reg[1:0] state;
			 
			  reg [31:0] count;
           wire tick = (count == max);

    // Timer: one-cycle tick every HOLD_SEC
          always @(posedge clk) begin
            if (rst || tick)
               count <= 0;
            else
               count <= count + 1;
           end
			  
			 always @(posedge clk)begin
			  if(rst)
			    state<=s0;
			  else if(tick) begin
			   case(state)
			     s0:state<=s1;
				  s1:state<=s2;
				  s2:state<=s0;
				  default:state<=s0;
				endcase
			  end
			end
				
			always@(*)
			case(state)
			s0:light=RED;
			s1:light=GREEN;
			s2:light=YELLOW;
			default:light=RED;
			endcase
endmodule
				