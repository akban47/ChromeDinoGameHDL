`timescale 1ns / 1ps

module top_game(
	input clk,
	input [15:0] sw,     
	input btnC, btnU,    
	output [15:0] led,   	
	output [3:0] vgaRed,
	output [3:0] vgaBlue,
	output [3:0] vgaGreen,
	output Hsync,
	output Vsync,
	output [6:0] segment,	
	output [3:0] an      
);
	
	reg [1:0] clk_div = 0;
	wire clk_25MHz;
    
	always @(posedge clk) begin
    	clk_div <= clk_div + 1;
	end
	assign clk_25MHz = clk_div[1];
	reg [19:0] game_clock_counter = 0;
	wire game_clock;
    
	always @(posedge clk) begin
    	game_clock_counter <= game_clock_counter + 1;
	end
	assign game_clock = game_clock_counter[19]; 
    
	wire video_on;
	wire [9:0] pixel_x;
	wire [9:0] pixel_y;
	reg [1:0] lives = 3;         
	reg [15:0] score = 0;        	
	reg [15:0] score_display = 0;	
	reg [15:0] max_score = 0;
	reg [3:0] score_tick_counter = 0; 
	reg [3:0] max_score_tick = 0;
	reg game_over = 0;           	
    
	reg [9:0] dino_x = 150;       	
	reg [9:0] dino_y = 358;      
	parameter DINO_HEIGHT = 32;  	
	parameter DINO_WIDTH = 24;   	
	reg dino_jumping = 0;        	
	reg [9:0] jump_height = 20;   
	reg [4:0] jump_counter = 0;  	
    
	reg [9:0] obstacle_x = 640;  	
	reg [9:0] obstacle_y = 370;  	
	reg [9:0] obstacle_width = 12; 
	reg [9:0] obstacle_height = 20;  
	reg [9:0] obstacle_speed = 5;	
	reg speed_increase = 0;
	parameter GROUND_Y = 390;
    
	vga_control vga_controller (
    	.clk(clk),
    	.clk_25MHz(clk_25MHz),
    	.o_Hsync(Hsync),
    	.o_Vsync(Vsync),
    	.video_on(video_on),
    	.pixel_x(pixel_x),
    	.pixel_y(pixel_y)
	);
    
	reg btnU_prev = 0;
	wire btnU_pressed;
    reg [9:0] rand_height = 0;
	always @(posedge game_clock) begin
    	btnU_prev <= btnU;
	end
	assign btnU_pressed = ~btnU_prev & btnU;
    
	always @(posedge game_clock) begin
    	if (btnC) begin
        	lives <= 3;
        	score <= 0;
        	score_display <= 0;
        	score_tick_counter <= 0;
        	obstacle_x <= 640;
        	dino_y <= 358;
        	jump_height <= 0;
        	dino_jumping <= 0;
        	game_over <= 0;
        	speed_increase <= 0;
        	rand_height <= 0;
        	max_score <= 0;
        	max_score_tick <= 0;
    	end
    	else if (!game_over) begin
        	score <= score + 1;
            score_tick_counter <= score_tick_counter + 1;
        	if (score_tick_counter >= 9) begin
            	score_display <= score_display + 1;
            	score_tick_counter <= 0;
        	end
       	 
        	if (btnU_pressed && !dino_jumping) begin
            	dino_jumping <= 1;
            	jump_counter <= 0;
        	end
       	 
        	if (dino_jumping) begin
            	jump_counter <= jump_counter + 1;
           	 
            	if (jump_counter < 15)
                	jump_height <= jump_height + 6;    
            	else if (jump_counter < 30)
                	jump_height <= jump_height - 6;
            	else begin
                	dino_jumping <= 0;
                	jump_height <= 0;
                	jump_counter <= 0;
            	end
        	end
       	 
        	if (obstacle_x <= 0) begin
            	obstacle_x <= 640;
            	obstacle_height <= 20;
            	rand_height <= $random % 20;
            	obstacle_height <= obstacle_height + rand_height;
            	obstacle_y <= GROUND_Y - obstacle_height;
            end
            	
        	else begin
            	if (score % 50 == 0) begin
               	speed_increase <= speed_increase + 1;
               	end
               	obstacle_x <= obstacle_x - obstacle_speed - speed_increase;
           	end
          	 
        	if ((dino_x + DINO_WIDTH > obstacle_x) &&
            	(dino_x < obstacle_x + obstacle_width) &&
            	(dino_y - jump_height + DINO_HEIGHT > obstacle_y) &&
            	(dino_y - jump_height < obstacle_y + obstacle_height)) begin
           	 
            	if (lives > 0)
                	lives <= lives - 1;
               	 
            	obstacle_x <= 640;
           	 
            	if (lives == 1)
                	game_over <= 1;
                	if (score > max_score) begin
                	   max_score <= score;
                	   max_score_tick <= score_tick_counter;
                	end
        	end
    	end
	end
    
	wire dino_pixel;
	wire [4:0] dino_rel_x = (pixel_x - dino_x);
	wire [4:0] dino_rel_y = (pixel_y - (dino_y - jump_height));
    
	assign dino_pixel = ((pixel_x >= dino_x) && (pixel_x < dino_x + DINO_WIDTH) &&
                    	(pixel_y >= dino_y - jump_height) && (pixel_y < dino_y - jump_height + DINO_HEIGHT)) &&
                    	(
                        	((dino_rel_y <= 8) && (dino_rel_x >= 6) && (dino_rel_x <= 18)) ||
                        	((dino_rel_y >= 8) && (dino_rel_y <= 24) && (dino_rel_x >= 2) && (dino_rel_x <= 20)) ||
                        	((dino_rel_y >= 24) && (dino_rel_y <= 32) && (dino_rel_x >= 5) && (dino_rel_x <= 8)) ||
                        	((dino_rel_y >= 24) && (dino_rel_y <= 32) && (dino_rel_x >= 13) && (dino_rel_x <= 16))
                    	);
    
	reg [3:0] red, green, blue;
    
	always @(*) begin
    	red = 4'b1111;
    	green = 4'b1111;
    	blue = 4'b1111;
   	 
    	if (video_on) begin
        	if (pixel_y == GROUND_Y) begin
            	red = 4'b0000;
            	green = 4'b0000;
            	blue = 4'b0000;
        	end
       	 
        	if (dino_pixel) begin
            	red = 4'b0000;  
            	green = 4'b0000;
            	blue = 4'b0000;
        	end
       	 
        	if ((pixel_x >= obstacle_x) && (pixel_x < obstacle_x + obstacle_width) &&
            	(pixel_y >= obstacle_y) && (pixel_y < obstacle_y + obstacle_height)) begin
            	red = 4'b0000; 
            	green = 4'b1000;
            	blue = 4'b0000;
        	end
       	 
        	if (game_over && (pixel_y > 100) && (pixel_y < 300) && (pixel_x > 300) && (pixel_x < 350)) begin
            	red = 4'b1111;
            	green = 4'b0000;
            	blue = 4'b0000;
        	end
       	 
        	if (game_over && (pixel_y > 250) && (pixel_y < 300) && (pixel_x > 300) && (pixel_x < 450)) begin
            	red = 4'b1111;
            	green = 4'b0000;
            	blue = 4'b0000;
        	end
       	 

        	if ((lives >= 3) && (pixel_x < 620) && (pixel_x > 600) && (pixel_y < 40) && (pixel_y > 20)) begin
           	red = 4'b1111;
           	green = 4'b0000;
           	blue = 4'b0000;
        	end
        	if ((lives >= 2) && (pixel_x < 580) && (pixel_x > 560) && (pixel_y < 40) && (pixel_y > 20)) begin
           	red = 4'b1111;
           	green = 4'b0000;
           	blue = 4'b0000;
        	end
        	if ((lives >= 1) && (pixel_x < 540) && (pixel_x > 520) && (pixel_y < 40) && (pixel_y > 20)) begin
           	red = 4'b1111;
           	green = 4'b0000;
           	blue = 4'b0000;
        	end
       	 
    	end
    	else begin
        	red = 4'b0000;
        	green = 4'b0000;
        	blue = 4'b0000;
    	end
	end
    
	assign vgaRed = red;
	assign vgaGreen = green;
	assign vgaBlue = blue;
    
    
	reg [15:0] display_counter = 0;
	reg [1:0] digit_select = 0;
	reg [3:0] current_digit;
    
	always @(posedge clk) begin
    	display_counter <= display_counter + 1;
    	if (display_counter == 0) begin
        	digit_select <= digit_select + 1;
    	end
	end
    
	reg [3:0] bcd_thousands = 0;
	reg [3:0] bcd_hundreds = 0;
	reg [3:0] bcd_tens = 0;
	reg [3:0] bcd_ones = 0;
    
	always @(posedge game_clock) begin
    	if (btnC) begin
        	bcd_thousands <= 0;
        	bcd_hundreds <= 0;
        	bcd_tens <= 0;
        	bcd_ones <= 0;
    	end
    	else if (!game_over && score_tick_counter >= 9) begin
        	if (bcd_ones == 9) begin
            	bcd_ones <= 0;
            	if (bcd_tens == 9) begin
                	bcd_tens <= 0;
                	if (bcd_hundreds == 9) begin
                    	bcd_hundreds <= 0;
                    	if (bcd_thousands < 9)
                        	bcd_thousands <= bcd_thousands + 1;
                	end else begin
                    	bcd_hundreds <= bcd_hundreds + 1;
                	end
            	end else begin
                	bcd_tens <= bcd_tens + 1;
            	end
        	end else begin
            	bcd_ones <= bcd_ones + 1;
        	end
    	end
    	
	end
    
    
    
	always @(*) begin
    	case (digit_select)
        	2'b00: current_digit = bcd_ones;    	// Rightmost digit (AN0)
        	2'b01: current_digit = bcd_tens;    	// Second from right (AN1)
        	2'b10: current_digit = bcd_hundreds;	// Third from right (AN2)
        	2'b11: current_digit = bcd_thousands;   // Leftmost digit (AN3)
    	endcase
	end
    always @(*) begin
        if (game_over && sw[0] == 1) begin
            2'b00: current_digit = max_score_tick[0];
            2'b01: current_digit = max_score_tick[1];
            2'b10: current_digit = max_score_tick[2];
            2'b11: current_digit = max_score_tick[3];
    	end
    end
    
	reg [6:0] seg_pattern;
	always @(*) begin
    	case (current_digit)
        	4'd0: seg_pattern = 7'b1000000; // 0
        	4'd1: seg_pattern = 7'b1111001; // 1
        	4'd2: seg_pattern = 7'b0100100; // 2
        	4'd3: seg_pattern = 7'b0110000; // 3
        	4'd4: seg_pattern = 7'b0011001; // 4
        	4'd5: seg_pattern = 7'b0010010; // 5
        	4'd6: seg_pattern = 7'b0000010; // 6
        	4'd7: seg_pattern = 7'b1111000; // 7
        	4'd8: seg_pattern = 7'b0000000; // 8
        	4'd9: seg_pattern = 7'b0010000; // 9
        	default: seg_pattern = 7'b1111111; // Blank
    	endcase
	end
    
	assign segment = seg_pattern;
    
	assign an[3] = ~(digit_select == 2'b11);
	assign an[2] = ~(digit_select == 2'b10);
	assign an[1] = ~(digit_select == 2'b01);
	assign an[0] = ~(digit_select == 2'b00);
    
endmodule
