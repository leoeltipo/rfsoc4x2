module tb;

parameter NCH	= 7;
parameter BIN  	= 16;
parameter Q		= 3;

// Maximum number of bits for CIC internals: BIN + Q*Log2(D),
// where Q is the number of cascaded stages and D is the 
// maximum decimation factor (pp. 562 Lyons book).
//parameter BCIC	= BIN + Q*$clog2(256);
parameter BCIC = 64;

reg					rstn;
reg 				clk;
reg  [BCIC-1:0]		din;
reg					din_last;
wire [BCIC-1:0]		dout;
wire				dout_last;
wire				dout_valid;
reg					RST_REG;
reg	 [7:0]			D_REG;

// TDM-demux for debugging.
reg					sync_demux;
wire [NCH*BCIC-1:0]	dout_demux;
wire				valid_demux;

wire [BCIC-1:0]		dout_ii [NCH];

genvar i;
generate
	for (i=0; i<NCH; i=i+1) begin
		assign dout_ii[i] = dout_demux[i*BCIC +: BCIC];
	end
endgenerate

cic_3
    #(
        .NCH(NCH	),
        .B	(BCIC	)
    )
    cic_i
	( 
		.rstn		(rstn		),
        .clk   		(clk   		),
        .din    	(din    	),
		.din_last	(din_last	),
        .dout		(dout		),
		.dout_last	(dout_last	),
		.dout_valid	(dout_valid	),
		.RST_REG	(RST_REG	),
		.D_REG		(D_REG		)
    );

tdm_demux
    #(
        .NCH(NCH	),
        .B	(BCIC	)
    )
	tdm_demux_i
	(
		.rstn		(rstn		),
		.clk		(clk		),
		.sync		(sync_demux	),
		.din		(dout		),
		.din_last	(dout_last	),
		.din_valid	(dout_valid	),
		.dout		(dout_demux	),
		.dout_valid	(valid_demux)

	);

// Main TB.
initial begin
	rstn		<= 0;
	RST_REG		<= 1;
	D_REG		<= 4;
	sync_demux	<= 1;

	#300;

	@(posedge clk);
	rstn	<= 1;

	#200;

	@(posedge clk);
	RST_REG		<= 0;
	sync_demux	<= 0;
end

// TDM channels.
initial begin
	// Frequencies.
    real w[NCH];
	for (int i=0; i<NCH; i=i+1) begin
		w[i] = 0;
	end
	w[0] = 2*3.14*0.001;
	w[1] = 2*3.14*0.02;
	w[2] = 0;

	// Init.
	din			<= 0;
	din_last	<= 0;

	// Generate data.
	for (int i=0; i<10000; i = i+1) begin
		for (int j=0; j<NCH; j = j+1) begin
			@(posedge clk);
			din <= (2**(BIN-1))*$cos(w[j]*i);
			if (j == NCH-1)
				din_last <= 1;
			else
				din_last <= 0;
		end
	end
end

always begin
	clk <= 0;
	#5;
	clk <= 1;
	#5;
end

endmodule

