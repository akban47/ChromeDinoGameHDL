// VGA Controller Module for 640x480 @ 60Hz
// Generates proper timing signals for VGA display
// Author: [Nathan, Akash]
// Date: [5/19]

module vga_controller(
    input clk_100MHz,           // Basys3 100MHz system clock
    output [9:0] pixel_x,       // Current pixel X coordinate 
    output [9:0] pixel_y,       // Current pixel Y coordinate 
    output hsync,               // Horizontal sync signal 
    output vsync,               // Vertical sync signal 
    output video_on,            // High when in active display area
    output frame_tick           // Pulse at end of each frame
);

    // VGA 640x480 @ 60Hz
    parameter H_DISPLAY = 640;    // Horizontal display area
    parameter H_FRONT = 16;       // Horizontal front porch
    parameter H_SYNC = 96;        // Horizontal sync pulse width
    parameter H_BACK = 48;        // Horizontal back porch
    parameter H_TOTAL = 800;      // Total horizontal pixels per line
    
    parameter V_DISPLAY = 480;    // Vertical display area
    parameter V_FRONT = 10;       // Vertical front porch
    parameter V_SYNC = 2;         // Vertical sync pulse width
    parameter V_BACK = 33;        // Vertical back porch
    parameter V_TOTAL = 525;      // Total vertical lines per frame

    // Clock divider to create 25MHz pixel clock from 100MHz system clock
    reg [1:0] clk_div = 0;
    always @(posedge clk_100MHz) begin
        clk_div <= clk_div + 1;
    end
    wire clk_25MHz = clk_div[1];

    // Horizontal pixel counter
    reg [9:0] h_count = 0;
    always @(posedge clk_25MHz) begin
        if (h_count == H_TOTAL - 1)
            h_count <= 0;
        else
            h_count <= h_count + 1;
    end

    // Vertical line counter
    reg [9:0] v_count = 0;
    always @(posedge clk_25MHz) begin
        if (h_count == H_TOTAL - 1) begin
            if (v_count == V_TOTAL - 1)
                v_count <= 0;
            else
                v_count <= v_count + 1;
        end
    end

    assign hsync = ~((h_count >= (H_DISPLAY + H_FRONT)) && 
                     (h_count < (H_DISPLAY + H_FRONT + H_SYNC)));
    assign vsync = ~((v_count >= (V_DISPLAY + V_FRONT)) && 
                     (v_count < (V_DISPLAY + V_FRONT + V_SYNC)));

    assign video_on = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);

    assign pixel_x = (h_count < H_DISPLAY) ? h_count : 0;
    assign pixel_y = (v_count < V_DISPLAY) ? v_count : 0;

    assign frame_tick = (h_count == 0) && (v_count == 0);

endmodule