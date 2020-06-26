`timescale 1ns / 1ps

module SPI_slave(
			input sclk, ss, MOSI, reset_n, write_enable,
			input [7:0] dataToTransmit,
			
			output reg MISO, done,
			output reg [7:0] dataRecieved
    );

	parameter idle         = 2'b00, //states
				 send_recieve = 2'b01,
				 finish       = 2'b11;
	
	reg [1:0] state, next_state;
	reg clear;
	reg [3:0] count;
	reg [7:0] Sregister;
	
	always @(posedge sclk or negedge reset_n)
	begin
		if (!reset_n)
		begin
			state <= idle;
		end //end reset
		else
		begin
			state <= next_state;
		end //end state
	end//end states always block 
	
	always @(*)
	begin
		case(state)
			idle:begin
				clear = 1'b1;
				done = 1'b1;
				if (!ss)
				begin
					done = 1'b0;
					next_state = send_recieve;
				end// end if ss = 0
				else
				begin
					next_state = idle;
				end// end if ss = 1
			end// end idle
			send_recieve:begin
				clear = 1'b0;
				if (write_enable == 0)//is write_enable == 0 and count == 0 then copy data to be transmitted
				begin
					if (count == 0)//copying data to be transmitted into shift register
					begin
						Sregister = dataToTransmit;
					end// end count = 0
				end// end if write_enable = 1
				if (count == 8)
				begin
					if (write_enable)
					begin
						dataRecieved = Sregister;
					end
					next_state = finish;
				end // end count == 8
				else
				begin
					next_state = send_recieve;
				end //end else (count != 8)
			end //end send_recieve
			finish:begin
					done = 1'b1;
					next_state = idle;
			end //end finish
		default: next_state = idle;
		endcase
	end// end always
	
	// send_recieve block
	always @(posedge sclk or posedge clear)
	begin
		if (clear == 1)
		begin
			count <= 0;
			Sregister <= 8'b1111_1111;
		end //end clear
		else
		begin
			if (!ss)
			begin
				count <= count + 1;
				if (write_enable)
				begin
					Sregister <= {MOSI , Sregister[7:1]};
				end// end recieve
				else
				begin
					MISO <= Sregister[0];
					Sregister <= {1'b1 , Sregister[7:1]};
				end// end transmit
			end// end if (ss == 0)
		end// end transmit or recieve
	end// end send_recieve always block
	
endmodule
