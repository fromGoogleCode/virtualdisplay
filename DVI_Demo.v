// Revision:
// 12/4/2013
//
// This code is an example of how to use the 
// Virtual Display Color Processor (VDCP) module. See "VDCP.v" for detail
//
// This example is based on the factory sample code "TV_Demo" from Terasic.
// See Terasic's copyright in the following page.
//
// Two sections (commented with the keyword "VDCP") were modified.
// The first section removes the original DVI_RX block.
// The second section connects the DVI_RX interface with the VDCP.
//  
// Authors: 
// Wei-Chung Cheng, Chih-Lei Wu, and Aldo Badano
// 


// --------------------------------------------------------------------
// Copyright (c) 2009 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
//                                  QB3H/GEN/Port/Pin_Assign/2009/05/27        
// --------------------------------------------------------------------  
// 
// Button[3]: swich build-in test patter for DVI-TX
// Button[2]: toggle internal rx-tx loopback mode and tx-only mode
// Button[1]: write EEPROM EDID (Please remove the calbe at DVI-RX Port when update EEPROM EDID)
// LED[3:0]:
//	- blink: EEPROM EDID updating
//  - all lighten: loopback mode active
//  - other: pattern id in tx-only mode.


`include "vpg_source/vpg.h"

`define COLOR_RGB444	0

module DVI_Demo(

		////////// CLOCK //////////
		OSC1_50,


		////////// BUTTON //////////
		Button,

		////////// LED //////////
		Led,


		////////// HSTCC (J5 HSTC-C TOP/J6, HSTC-C BOTTOM), connect to DVI(DVI TX/RX Board) //////////
		HSTCC_DVI_RX_CLK,
		HSTCC_DVI_RX_CTL,
		HSTCC_DVI_RX_D,
		HSTCC_DVI_RX_DDCSCL,
		HSTCC_DVI_RX_DDCSDA,
		HSTCC_DVI_RX_DE,
		HSTCC_DVI_RX_HS,
		HSTCC_DVI_RX_SCDT,
		HSTCC_DVI_RX_VS,
		HSTCC_DVI_TX_CLK,
		HSTCC_DVI_TX_CTL,
		HSTCC_DVI_TX_D,
		HSTCC_DVI_TX_DDCSCL,
		HSTCC_DVI_TX_DDCSDA,
		HSTCC_DVI_TX_DE,
		HSTCC_DVI_TX_DKEN,
		HSTCC_DVI_TX_HS,
		HSTCC_DVI_TX_HTPLG,
		HSTCC_DVI_TX_ISEL,
		HSTCC_DVI_TX_MSEN,
		HSTCC_DVI_TX_SCL,
		HSTCC_DVI_TX_SDA,
		HSTCC_DVI_TX_VS,
		HSTCC_EDID_WP,
		HSTCC_HSMC_SCL,
		HSTCC_HSMC_SDA,
		HSTCC_TX_PD_N


	);

//=======================================================
//  PARAMETER declarations
//=======================================================

//=======================================================
//  PORT declarations
//=======================================================
////////// CLOCK //////////
input                     		OSC1_50;

 ///////// BUTTON //////////
input     	[3:0]           	Button;

////////// LED //////////
output     	[3:0]           	Led;


////////// HSTCC (J5 HSTC-C TOP/J6, HSTC-C BOTTOM), connect to DVI(DVI TX/RX Board) //////////
input                     		HSTCC_DVI_RX_CLK;
input     	[3:1]           	HSTCC_DVI_RX_CTL;
input     	[23:0]          	HSTCC_DVI_RX_D;
//output                    		HSTCC_DVI_RX_DDCSCL;
inout                    		HSTCC_DVI_RX_DDCSCL;
inout                     		HSTCC_DVI_RX_DDCSDA;
input                     		HSTCC_DVI_RX_DE;
input                     		HSTCC_DVI_RX_HS;
input                     		HSTCC_DVI_RX_SCDT;
input                     		HSTCC_DVI_RX_VS;
output                    		HSTCC_DVI_TX_CLK;
output    	[3:1]           	HSTCC_DVI_TX_CTL;
output    	[23:0]          	HSTCC_DVI_TX_D;
output                    		HSTCC_DVI_TX_DDCSCL;
inout                     		HSTCC_DVI_TX_DDCSDA;
output                    		HSTCC_DVI_TX_DE;
output                    		HSTCC_DVI_TX_DKEN;
output                    		HSTCC_DVI_TX_HS;
output                    		HSTCC_DVI_TX_HTPLG;
output                    		HSTCC_DVI_TX_ISEL;
output                    		HSTCC_DVI_TX_MSEN;
output                    		HSTCC_DVI_TX_SCL;
inout                     		HSTCC_DVI_TX_SDA;
output                    		HSTCC_DVI_TX_VS;
output                    		HSTCC_EDID_WP;
output                    		HSTCC_HSMC_SCL;
inout                     		HSTCC_HSMC_SDA;
output                    		HSTCC_TX_PD_N;


//=======================================================
//  REG/WIRE declarations
//=======================================================



//=======================================================
//  Structural coding
//=======================================================
wire reset_n;
wire pll_100M;
wire pll_100K;

wire gen_sck;
wire gen_i2s;
wire gen_ws;



sys_pll sys_pll_inst(
	.areset(1'b0),
	.inclk0(OSC1_50),
	.c0(pll_100M),
	.c1(pll_100K),
	.locked(reset_n)
	);
	


//---------------------------------------------------//
//				Mode Change Button Monitor 			 //
//---------------------------------------------------//
wire			mode_button;
reg				pre_mode_button;
reg		[15:0]	debounce_cnt;
reg		[3:0]	vpg_mode;	
reg				vpg_mode_change;


	assign mode_button = ~Button[3];
	always@(posedge pll_100M or negedge reset_n)
		begin
			if (!reset_n)
				begin
					vpg_mode <= `VGA_640x480p60;
					debounce_cnt <= 1;
					vpg_mode_change <= 1'b1;
				end
			else if (vpg_mode_change)
				vpg_mode_change <= 1'b0;
			else if (debounce_cnt)
				debounce_cnt <= debounce_cnt + 1'b1;
			else if (mode_button && !pre_mode_button)
				begin
					debounce_cnt <= 1;
					vpg_mode_change <= 1'b1;
					if (vpg_mode == `VESA_1600x1200p60)
						vpg_mode <= `VGA_640x480p60;
					else
						vpg_mode <= vpg_mode + 1'b1;
				end
		end

	always@(posedge pll_100M)
		begin
			pre_mode_button <= mode_button;
		end


//----------------------------------------------//
// 			 Video Pattern Generator	  	   	//
//----------------------------------------------//
wire [3:0]	vpg_disp_mode;
wire [1:0]	vpg_disp_color;

wire vpg_pclk;
wire vpg_de;
wire vpg_hs;
wire vpg_vs;
wire [23:0]	vpg_data;


vpg	vpg_inst(
	.clk_100(pll_100M),
	.reset_n(reset_n),
	.mode(vpg_mode),
	.mode_change(vpg_mode_change),
	.disp_color(`COLOR_RGB444),       
	.vpg_pclk(vpg_pclk),
	.vpg_de(vpg_de),
	.vpg_hs(vpg_hs),
	.vpg_vs(vpg_vs),
	.vpg_r(vpg_data[23:16]),
	.vpg_g(vpg_data[15:8]),
	.vpg_b(vpg_data[7:0])
);

//----------------------------------------------//
// 				DVI receiver					//
//----------------------------------------------//
//
// VDCP: The following section was commented.
//
// In schematic OCK_INV=GND, latches output data on falling edge
/*wire rx_clk;
reg	[23:0]	rx_data;
reg			rx_de;
reg			rx_hs;
reg			rx_vs;
assign rx_clk = ~HSTCC_DVI_RX_CLK;
always@(posedge rx_clk) // OCK_INV=GND, latches output data on falling edge
begin
	rx_data <= {HSTCC_DVI_RX_D[23:16], HSTCC_DVI_RX_D[15:8], HSTCC_DVI_RX_D[7:0]};
	rx_de <= HSTCC_DVI_RX_DE;
	rx_hs <= HSTCC_DVI_RX_HS;
	rx_vs <= HSTCC_DVI_RX_VS;
	
end*/

//
// VDCP: The following section is added to use the VDCP module.
//
wire rx_clk;
wire	[23:0]	rx_data;
wire			rx_de;
wire			rx_hs;
wire			rx_vs;
VDCP DVI_RX(	
							.reset_n(reset_n),
							.DVI_RX_CLK(HSTCC_DVI_RX_CLK),
							.DVI_RX_DE(HSTCC_DVI_RX_DE),
							.DVI_RX_HS(HSTCC_DVI_RX_HS),
							.DVI_RX_VS(HSTCC_DVI_RX_VS),
							.DVI_RX_D(HSTCC_DVI_RX_D),
							.pll_100K(pll_100K),
							.rx_clk(rx_clk),
							.rx_data(rx_data), 
							.rx_de(rx_de),
							.rx_hs(rx_hs),
							.rx_vs(rx_vs)
							
							);
		


//----------------------------------------------//
// 			 DVI TX                 	  	   	//
//----------------------------------------------//
//=============== DVI TX CONFIG ==================
assign HSTCC_DVI_TX_ISEL 	= 1'b0; 	// disable i2c
assign HSTCC_DVI_TX_SCL 	= 1'b1; 	// BSEL=0, 12-bit, dual-edge input
assign HSTCC_DVI_TX_HTPLG 	= 1'b1; 	// Note. *** EDGE=1, primary latch to occur on the rising edge of the input clock IDCK+
assign HSTCC_DVI_TX_SDA 	= 1'b1;  	// DSEL=X (VREF=3.3V)
assign HSTCC_TX_PD_N 		= 1;

//
reg			loopback_mode;
reg	[15:0]	disable_cnt;
reg			pre_loopback_btn;
wire        loopback_btn;
assign loopback_btn = ~Button[2];

always @ (posedge pll_100K)
begin
	if (disable_cnt)
	begin
		disable_cnt <= disable_cnt + 1'b1;
	end
	else if (loopback_btn && !pre_loopback_btn && disable_cnt == 0)
	begin
		loopback_mode <= loopback_mode + 1'b1;
		disable_cnt <= 16'hFFFF;
	end
	//
	pre_loopback_btn <= loopback_btn;
end

clk_selector clk_selector_inst(
	.data0(vpg_pclk),
	.data1(rx_clk),
	.sel(loopback_mode),
	.result(HSTCC_DVI_TX_CLK)
	);

video_selector video_selector_inst(
	.clock(HSTCC_DVI_TX_CLK),
	.data0x({vpg_de, vpg_vs, vpg_hs, vpg_data}),
	.data1x({rx_de, rx_vs, rx_hs, rx_data}),
	.sel(loopback_mode),
	.result({HSTCC_DVI_TX_DE, HSTCC_DVI_TX_VS, HSTCC_DVI_TX_HS, HSTCC_DVI_TX_D})
	);

//----------------------------------------------//
// 			 DVI RX EDID (EEPROM Writing)  	   	//
//----------------------------------------------//
wire edid_writing;
WRITE_EDID WRITE_EDID_inst(
		.CLK_I2C_100K(pll_100K),
		.EDID_WRITE_TRIGGER(~Button[1]),
		.EDID_WRITING(edid_writing),
		.EDID_WP(HSTCC_EDID_WP),
		.EDID_DDCSCL(HSTCC_DVI_RX_DDCSCL),
		.EDID_DDCSDA(HSTCC_DVI_RX_DDCSDA)
		);

	
		
// edid-writing: led indication
reg [3:0] 	edid_writing_led;		
reg [12:0] 	edid_led_cnt;		
always @(posedge pll_100K)
begin
	if (edid_writing)
	begin
		if (edid_led_cnt == 0)
			edid_writing_led <= edid_writing_led ^ 4'hF;
		edid_led_cnt <= edid_led_cnt + 1'b1;
	end
	else
	begin
		edid_writing_led <= 4'hF;
		edid_led_cnt <= 0;
	end
end		

//==================== LED indication
assign Led[3:0] = edid_writing?edid_writing_led:(loopback_mode?4'h0:~vpg_mode); // 4 leds are turn on for loopback mode		


endmodule
