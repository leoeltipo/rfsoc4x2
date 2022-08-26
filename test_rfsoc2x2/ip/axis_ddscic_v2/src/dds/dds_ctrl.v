/*
 * Multi-channel DDS control. It uses a single-channel Xilinx DDS.
 * Input data contains TDM frequencies and phases. Underlaying DDS
 * is 16-bit for frequency/phase.
 *
 * The control ensures phase coherency. To achieve that, the phase
 * is computed with a counter. The counter relies on tlast to
 * increase its value. This schema ensures the same index n is used
 * on all TDM channels. 
 *
 * NOTE: If tlast does not change, the counter won't neither, and 
 * the DDS won't create the desired wave.
 *
 * DDS Control input format:
 *
 * |----------|------|----------|---------|
 * | 39 .. 33 |32    | 31 .. 16 | 15 .. 0 |
 * |----------|------|----------|---------|
 * | not used | sync | phase    | pinc    |
 * |----------|------|----------|---------|
 *
 */
module dds_ctrl
	(
		// Reset and clock.
		input 	wire 		rstn		,
		input 	wire 		clk			,
	
		// Data input.
		input 	wire [31:0]	din			,
		input 	wire		din_last	,

		// DDS control output.
		output 	wire [39:0]	dout		,
		output 	wire		dout_last	,
		output 	wire		dout_valid
	);

/*************/
/* Internals */
/*************/
// Input pipeline.
reg	 [31:0]	din_r1;

// Input frequency and phase.
wire [15:0] wn,pn;

// Accumulated phase.
wire [15:0] phi;
reg  [15:0] phi_r1;

// Phase pipeline.
reg	 [15:0]	pn_r1;

// Time counter.
reg	 [15:0]	cnt;

// din_last pipeline.
reg			last_r1;
reg			last_r2;

/****************/
/* Architecture */
/****************/
// Input frequency and phase.
assign wn = din_r1[15:0];
assign pn = din_r1[31:16];

// Accumulated phase.
assign phi = cnt*wn;

always @(posedge clk) begin
	if (rstn == 1'b0) begin
		// Input pipeline.
		din_r1	<= 0;

		// Accumulated phase.
		phi_r1	<= 0;

		// Phase pipeline.
		pn_r1	<= 0;

		// Time counter.
		cnt		<= 0;

		// din_last pipeline.
		last_r1	<= 0;
		last_r2	<= 0;
	end
	else begin
		// Input pipeline.
		din_r1	<= din;

		// Accumulated phase.
		phi_r1	<= phi;

		// Phase pipeline.
		pn_r1	<= pn;

		// Time counter.
		if (last_r1 == 1'b1)
			cnt	<= cnt + 1;

		// din_last pipeline.
		last_r1	<= din_last;
		last_r2	<= last_r1;
	end
end

// Assign outputs.
assign dout 		= {1'b1,pn_r1,phi_r1};
assign dout_last	= last_r2;
assign dout_valid	= 1'b1;

endmodule

