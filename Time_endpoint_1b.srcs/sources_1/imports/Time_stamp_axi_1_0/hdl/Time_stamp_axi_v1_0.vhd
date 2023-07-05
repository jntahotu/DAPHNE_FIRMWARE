library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pdts_defs.all;
use work.pdts_ep_defs.all;
use work.pdts_clock_defs.all;

entity Time_stamp_axi_v1_0 is
	generic (
		-- Users to add parameters here
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here
		
		
		
		
		
		
		pl_sclk0: in std_logic;
		sys_clk: in std_logic; -- System clock is 100MHz
		sys_rst: in std_logic; -- System reset (sclk domain)
        sys_addr: in std_logic_vector(15 downto 0); 
		sys_stat: out std_logic_vector(3 downto 0); -- Status output (sclk domain)
		los: in std_logic := '0'; -- External signal path status (async)
		rxd: in std_logic; -- Timing input (clk domain)
		txd: out std_logic; -- Timing output (clk domain)
		txenb: out std_logic; -- Timing output enable (active low for SFP) (clk domain)
		clk: out std_logic; -- Base clock output is 62.5MHz
		rst: out std_logic; -- Base clock reset (clk domain)
		ready: out std_logic; -- Endpoint ready flag (clk domain)
		tstamp: out std_logic_vector(63 downto 0); -- Timestamp (clk domain)
		
		
		
		
		
		
		
		
		
		
		
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end Time_stamp_axi_v1_0;

architecture Logic of Time_stamp_axi_v1_0 is

	-- component declaration
	component Time_stamp_axi_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic;
		
		sys_clk: in std_logic; -- System clock is 100MHz
		sys_rst: in std_logic; -- System reset (sclk domain)
		pl_clk0 :in std_logic;
		sys_addr: in std_logic_vector(15 downto 0); 
		sys_stat: out std_logic_vector(3 downto 0); -- Status output (sclk domain)
		los: in std_logic := '0'; -- External signal path status (async)
		rxd: in std_logic; -- Timing input (clk domain)
		txd: out std_logic; -- Timing output (clk domain)
		txenb: out std_logic; -- Timing output enable (active low for SFP) (clk domain)
		clk: out std_logic; -- Base clock output is 62.5MHz
		rst: out std_logic; -- Base clock reset (clk domain)
		ready: out std_logic; -- Endpoint ready flag (clk domain)
		tstamp: out std_logic_vector(63 downto 0) -- Timestamp (clk domain)
		);
	end component Time_stamp_axi_v1_0_S00_AXI;
	

begin

-- Instantiation of Axi Bus Interface S00_AXI
Time_stamp_axi_v1_0_S00_AXI_inst : Time_stamp_axi_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready,
		
		
		sys_clk =>sys_clk,
		sys_rst =>sys_rst,
		pl_clk0 =>pl_sclk0,
		sys_addr => sys_addr,
		sys_stat => sys_stat,
		los => los,
		rxd => rxd,
		txd => txd,
		txenb => txenb,
		--		ready => ready,
		tstamp => tstamp
	);

	-- Add user logic here	 
	
	
	
	


	
	
	
	
	
	
	
	
	
	-- User logic ends

end Logic;
