`timescale 1ns / 1ps

module SPI_tb;

	// Inputs
	reg reset_n;
	// Master
	reg clock;
	reg start;
	reg write_enable_master;
	wire MISO;
	reg [7:0] dataToTransmit_master;
	reg [2:0] clock_div;
	// Slave
	wire sclk;
	wire ss;
	wire MOSI;
	reg write_enable_slave;
	reg [7:0] dataToTransmit_slave;

	// Outputs
	// Master
	wire done_master;
	wire [7:0] dataRecieved_master;
	// Slave
	wire done_slave;
	wire [7:0] dataRecieved_slave;
	
	// Instantiate Master
	SPI_master uut1 (
		.clock(clock), 
		.reset_n(reset_n), 
		.start(start), 
		.write_enable(write_enable_master), 
		.MISO(MISO), 
		.dataToTransmit(dataToTransmit_master), 
		.clock_div(clock_div), 
		.sclk(sclk), 
		.done(done_master), 
		.ss(ss), 
		.MOSI(MOSI), 
		.dataRecieved(dataRecieved_master)
	);
	// Instantiate Slave
	SPI_slave uut2 (
		.sclk(sclk), 
		.ss(ss), 
		.MOSI(MOSI), 
		.reset_n(reset_n), 
		.write_enable(write_enable_slave), 
		.dataToTransmit(dataToTransmit_slave), 
		.MISO(MISO), 
		.done(done_slave), 
		.dataRecieved(dataRecieved_slave)
	);
	
	always #10 clock = ~clock;

	initial begin
		// Initialize Inputs
		clock = 0;
		start = 0;
		write_enable_master = 0;
		dataToTransmit_master = 0;
		clock_div = 2;
		reset_n = 1;
		write_enable_slave = 1;
		dataToTransmit_slave = 0;

		#2 reset_n = 0;
		#2 reset_n = 1;

		#1 start = 1;
		dataToTransmit_master = 8'b10101010;
		
		#500;
		start = 0;
		if (dataToTransmit_master == dataRecieved_slave)
			$display ("SPI SLAVE RECEIVED SUCCESSFULLY .. PASSED");
		else
			$display ("SPI SLAVE did not RECEIVED SUCCESSFULLY .. FAILED");
			
		#2 start = 1;
		dataToTransmit_slave = 8'b01101101;
		write_enable_master = 1;
		write_enable_slave = 0;
		
		#500;
		start = 0;
		if (dataToTransmit_slave == dataRecieved_master)
			$display ("SPI master RECEIVED SUCCESSFULLY .. PASSED");
		else
			$display ("SPI master did not RECEIVED SUCCESSFULLY .. FAILED");
		
		//#100 $finish;
		
	end
      
endmodule

