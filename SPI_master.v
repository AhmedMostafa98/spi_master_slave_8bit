`timescale 1ns / 1ps

module SPI_master(
						input clock, reset_n, start, write_enable,
						input MISO,
						input [7:0] dataToTransmit,
						input [2:0] clock_div,
						
						output reg sclk, done, ss,
						output reg MOSI,
						output reg [7:0] dataRecieved
					  );
					  
	parameter idle         = 2'b00, //states
				 send_recieve = 2'b01,
				 finish       = 2'b11;
				 	
	reg [1:0] state, next_state;
	reg clear;
	reg [3:0] count, clock_count;
	reg [7:0] Sregister;
	
	always @(posedge sclk or negedge reset_n)
	begin
		if (!reset_n)
		begin
			state <= finish;
		end //end reset
		else
		begin
			state <= next_state;
			if (next_state == finish && write_enable)
			begin
				dataRecieved <= Sregister;
			end
		end //end state
	end //end states always block 

	always @(*)
	begin
		case(state)
			idle:begin
				clear = 1'b1;
				if (start == 1)
				begin
					done = 1'b0;
					ss = 1'b0;
					next_state = send_recieve;
				end //end start == 1
				else
				begin
					done = 1'b1;
					ss = 1'b1;
					next_state = idle;
				end
			end // end idle
			send_recieve:begin
							clear = 1'b0;
							done = 1'b0;
							ss = 1'b0;
							if (write_enable)
							begin
								if (count == 10)
								begin
									next_state = finish;
								end// end count == 8
								else
								begin
									next_state = send_recieve;
								end// end count != 8
							end// end write_enable == 1
							else
							begin
								if (count == 8)
								begin
									next_state = finish;
								end// end count == 10
								else
								begin
									next_state = send_recieve;
								end// end count != 10
							end// end write_enable == 0
			end //end send_recieve
		finish:begin
					clear = 1'b0;
					done = 1'b0;
					ss = 1'b0;
					next_state = idle;
				end// end finish
		default:begin 
					clear = 1'b0;
					done = 1'b0;
					ss = 1'b0;
					next_state = finish;
				end// end default to prevent latches
		endcase
	end//end always
	
	// clock divider block
	always @(posedge clock or negedge reset_n)
	begin
		if (!reset_n)
		begin
			clock_count <= 0;
			sclk <= 1;
		end// end clear 
		else
		begin
			if (clock_count == (clock_div / 2) - 1)
			begin
				sclk <= ~sclk;
				clock_count <= 0;
			end// end if counter == index for clock division
			else
			begin
				clock_count <= clock_count + 1;
			end// end if counter != index for clock division
		end// end if not clear
	end// end clock divider block
	
	
	
	// send_recieve block
	always @(posedge sclk or posedge clear)
	begin
		if (clear == 1)
		begin
			count <= 0;
			Sregister <= dataToTransmit;
		end //end clear
		else
		begin
			if (!ss)
			begin
				count <= count + 1;
				if (write_enable)
				begin
					Sregister <= {MISO , Sregister[7:1]};
				end// end recieve
				else
				begin
					MOSI <= Sregister[0];
					Sregister <= {1'b1 , Sregister[7:1]};
				end// end transmit
			end// end if (ss == 0)
		end// end transmit or recieve
	end// end send_recieve always block
	

endmodule
