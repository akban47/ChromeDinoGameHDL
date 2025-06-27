`timescale 1ns / 1ps

module vga_control(
	input clk,                	// 100MHz system clock
	input clk_25MHz,          	// 25MHz pixel clock
	output reg o_Hsync = 0,
	output reg o_Vsync = 0,
	output video_on,          	// Active video area flag
	output [9:0] pixel_x,     	// Current pixel X position
	output [9:0] pixel_y      	// Current pixel Y position
);
	// Standard VGA 640x480@60Hz timing
	parameter H_ACTIVE = 640;
	parameter H_FRONT_PORCH = 16;
	parameter H_SYNC_PULSE = 96;
	parameter H_BACK_PORCH = 48;
	parameter H_TOTAL = 800;
    
	parameter V_ACTIVE = 480;
	parameter V_FRONT_PORCH = 10;
	parameter V_SYNC_PULSE = 2;
	parameter V_BACK_PORCH = 33;
	parameter V_TOTAL = 525;
    
	// Counter registers
	reg [9:0] h_count = 0;
	reg [9:0] v_count = 0;
    
	// Video on/off flag
	wire h_active, v_active;
    
	// Horizontal counter
	always @(posedge clk_25MHz) begin
    	if (h_count == H_TOTAL-1)
        	h_count <= 0;
    	else
        	h_count <= h_count + 1;
	end
    
	// Vertical counter
	always @(posedge clk_25MHz) begin
    	if (h_count == H_TOTAL-1) begin
        	if (v_count == V_TOTAL-1)
            	v_count <= 0;
        	else
            	v_count <= v_count + 1;
    	end
	end
    
	// Generate horizontal sync signal (negative polarity)
	always @(posedge clk_25MHz) begin
    	if ((h_count >= H_ACTIVE + H_FRONT_PORCH) &&
        	(h_count < H_ACTIVE + H_FRONT_PORCH + H_SYNC_PULSE))
        	o_Hsync <= 0;  // Active low
    	else
        	o_Hsync <= 1;
	end
    
	// Generate vertical sync signal (negative polarity)
	always @(posedge clk_25MHz) begin
    	if ((v_count >= V_ACTIVE + V_FRONT_PORCH) &&
        	(v_count < V_ACTIVE + V_FRONT_PORCH + V_SYNC_PULSE))
        	o_Vsync <= 0;  // Active low
    	else
        	o_Vsync <= 1;
	end
    
	// Generate video on/off signals
	assign h_active = (h_count < H_ACTIVE);
	assign v_active = (v_count < V_ACTIVE);
	assign video_on = h_active && v_active;
    
	// Output current pixel coordinates
	assign pixel_x = h_count;
	assign pixel_y = v_count;
    
endmodule
